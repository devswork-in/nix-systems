final: prev: {
  gnomeExtensions = prev.gnomeExtensions // {
    panel-free = prev.gnomeExtensions.panel-free.overrideAttrs (oldAttrs: rec {
      version = "10";
      src = prev.fetchzip {
        url = "https://extensions.gnome.org/extension-data/panel-freefthx.v${version}.shell-extension.zip";
        hash = "sha256-Jn5TAU7XZh6C7MK3sSmLMEEL7BF0KTcliTD5LLkgVrM=";
        stripRoot = false;
      };
    });
  };
}
