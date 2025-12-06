{ pkgs, ... }:

let
  bluez = pkgs.bluez.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [ "--enable-experimental" ];
  });
in

{

  hardware = {
    # If no audio,check output devices in pavucontrol
    bluetooth = {
      enable = true;
      package = bluez;
      powerOnBoot = true;
      settings = {
        General = {
          Name = "Hello";
          ControllerMode = "dual";
          FastConnectable = "true";
          Experimental = "true";
        };
        Policy = {
          AutoEnable = "true";
        };
      };
    };
  };

  services = {
    blueman.enable = true;
    dbus = {
      enable = true;
      packages = [ pkgs.bluez ];
    };
  };

  systemd.services = {
    bluetooth = {
      description = "Bluetooth service";
      serviceConfig = {
        Type = "dbus";
        BusName = "org.bluez";
        ExecStart = [
          ""
          "${pkgs.bluez}/bin/bluetoothd --noplugin=sap,vcp,mcp,bap"
        ];
      };
      wantedBy = [ "bluetooth.target" ];
    };
    bluetoothUnblock = {
      description = "Unblock Bluetooth on startup";
      serviceConfig = {
        ExecStart = "/run/current-system/sw/bin/rfkill unblock all";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
