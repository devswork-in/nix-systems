{ userConfig, lib, ... }:

let
  bots = userConfig.services.bots;
  domain = bots.host;

  # Auto-discover all bot entries (any attrset in bots with enable/endpoint/label)
  botNames = lib.filter
    (name: lib.isAttrs bots.${name} && bots.${name} ? enable)
    (lib.attrNames bots);

  enabledBots = lib.filter (name: bots.${name}.enable) botNames;

  botLinks = lib.concatMapStringsSep "\n                    "
    (name: let bot = bots.${name}; in
      ''<a href="${bot.endpoint}">${bot.label}</a>'')
    enabledBots;
in {
  services.nginx.virtualHosts."${domain}" = {
    enableACME = true;
    forceSSL = true;

    # Dynamic Landing Page — auto-generated from enabled bots
    locations."/" = {
      extraConfig = ''
        allow 100.64.0.0/10;
        allow fd7a:115c:a1e0::/48;
        allow 127.0.0.1;
        allow ::1;
        deny all;

        add_header Content-Type text/html;
        return 200 '
        <!DOCTYPE html>
        <html>
        <head>
            <title>Bot Hub</title>
            <style>
                body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #1e1e2e; color: #cdd6f4; }
                .container { text-align: center; background: #313244; padding: 2rem; border-radius: 1rem; box-shadow: 0 4px 15px rgba(0,0,0,0.3); }
                h1 { margin-bottom: 2rem; color: #89b4fa; }
                .links { display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap; }
                a { text-decoration: none; color: #11111b; background: #a6e3a1; padding: 0.8rem 1.5rem; border-radius: 0.5rem; font-weight: bold; transition: transform 0.2s; }
                a:hover { transform: scale(1.05); background: #94e2d5; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Bot Hub</h1>
                <div class="links">
                    ${botLinks}
                </div>
            </div>
        </body>
        </html>';
      '';
    };
  };
}
