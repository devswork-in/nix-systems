"""Refresh only the OpenCode CLI catalog; never run inference or change combos."""
import json
import os
from pathlib import Path
import subprocess
import shutil
import urllib.error
import urllib.request


def free_models(output, catalog):
    models = sorted({line.removeprefix("opencode/") for line in output.splitlines()
                     if line.startswith("opencode/")})
    if not models:
        raise ValueError("OpenCode returned an empty model list; keeping the previous catalog")
    metadata = catalog["opencode"]["models"]
    for model in models:
        cost = metadata[model]["cost"]
        if any(type(cost.get(field)) not in (int, float) or cost[field] != 0
               for field in ("input", "output")):
            raise ValueError(f"Cannot verify zero price for {model}; keeping the previous catalog")
    return models


def provider_update(provider, models):
    if provider.get("adapter") != "opencode-cli":
        raise ValueError("opencode-cli must already be configured with the CLI adapter")
    updated = dict(provider)
    updated.update(models=models, selectedModels=models, liveModels=False)
    if updated.get("defaultModel") not in models:
        updated["defaultModel"] = "glm-5.3-flash-free" if "glm-5.3-flash-free" in models else models[0]
    # The adapter is text-only even when upstream advertises image support.
    capabilities = dict(updated.get("modelCapabilities") or {})
    for model in models:
        capabilities[model] = {**capabilities.get(model, {}), "inputModalities": ["text"]}
    updated["modelCapabilities"] = capabilities
    return updated


def request(port, token, path, body=None):
    req = urllib.request.Request(
        f"http://127.0.0.1:{port}{path}",
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        data=json.dumps(body).encode() if body is not None else None,
        method="POST" if body is not None else "GET",
    )
    try:
        with urllib.request.urlopen(req, timeout=40) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        # Never log upstream bodies: management responses can contain credentials.
        raise RuntimeError(f"Gateway management request failed: HTTP {error.code}") from None


def bundled_opencode():
    # ocx's Nix wrapper adds its pinned CLI to PATH; use that exact CLI, not
    # another nixpkgs version whose model catalog could differ from inference.
    pid = subprocess.check_output(
        ["systemctl", "show", "llm-gateway-hub.service", "--property=MainPID", "--value"],
        text=True, timeout=10,
    ).strip()
    if not pid.isdecimal() or int(pid) <= 0:
        raise ValueError("Gateway hub is not running")
    environment = dict(entry.split(b"=", 1) for entry in
                       Path(f"/proc/{pid}/environ").read_bytes().split(b"\0") if b"=" in entry)
    binary = shutil.which("opencode", path=os.fsdecode(environment.get(b"PATH", b"")))
    if not binary or not binary.startswith("/nix/store/"):
        raise ValueError("Cannot find the hub's bundled OpenCode CLI")
    return binary


def main():
    home = Path(os.environ["HOME"])
    state = Path(os.environ["OPENCODEX_HOME"])
    result = subprocess.run(
        [bundled_opencode(), "models", "opencode", "--refresh", "--pure"],
        cwd=home, text=True, capture_output=True, timeout=90, check=True,
    )
    cache = Path(os.environ.get("XDG_CACHE_HOME", str(home / ".cache")))
    models = free_models(result.stdout, json.loads((cache / "opencode/models.json").read_text()))
    config = json.loads((state / "config.json").read_text())
    provider = config["providers"]["opencode-cli"]
    updated = provider_update(provider, models)
    before = set(provider.get("selectedModels") or provider.get("models") or [])
    token = (state / "admin-api-token").read_text().strip()
    if not token:
        raise ValueError("Missing gateway management token")
    if provider != updated:
        request(os.environ["HUB_PORT"], token, "/api/providers",
                {"name": "opencode-cli", "provider": updated})
    print("OpenCode free catalog:", len(models), "models; added:",
          ", ".join(sorted(set(models) - before)) or "none", "; removed:",
          ", ".join(sorted(before - set(models))) or "none")
    if provider.get("defaultModel") != updated["defaultModel"]:
        print("Default model changed to:", updated["defaultModel"])
    for name, combo in config.get("combos", {}).items():
        for target in combo.get("targets", []):
            if target.get("provider") == "opencode-cli" and target.get("model") not in models:
                print("WARNING: combo", name, "references unavailable model", target.get("model"))


if __name__ == "__main__":
    main()
