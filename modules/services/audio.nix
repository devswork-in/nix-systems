# Audio configuration with PipeWire and WirePlumber
# Enables automatic device switching and optimized Bluetooth support

{ config, pkgs, lib, ... }:

{
  # Disable PulseAudio (we're using PipeWire)
  services.pulseaudio.enable = false;

  # Enable PipeWire audio stack
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true; # PulseAudio compatibility

    wireplumber = {
      enable = true;

      extraConfig = {
        # Bluetooth policy and default node behavior
        "10-bluetooth-policy" = {
          "wireplumber.settings" = {
            # Don't auto-switch to low-quality mono headset profile when mic is requested
            "bluetooth.autoswitch-to-headset-profile" = false;
            # Disable restoring saved default sink - always use highest priority device
            "default-nodes.use-persistent-storage" = false;
          };
        };

        # Bluetooth monitor configuration - better codecs and auto-connect
        "10-bluez-monitor" = {
          "monitor.bluez.properties" = {
            # Enable high-quality codecs
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            # Supported roles
            "bluez5.roles" = [
              "a2dp_sink"
              "a2dp_source"
              "bap_sink"
              "bap_source"
              "hsp_hs"
              "hsp_ag"
              "hfp_hf"
              "hfp_ag"
            ];
          };
        };

        # Boost Bluetooth device priority so they become default when connected
        "50-bluetooth-priority" = {
          "monitor.bluez.rules" = [
            {
              matches = [{ "node.name" = "~bluez_output.*"; }];
              actions = {
                update-props = {
                  "priority.driver" = 2000;
                  "priority.session" = 2000;
                };
              };
            }
            {
              matches = [{ "node.name" = "~bluez_input.*"; }];
              actions = {
                update-props = {
                  "priority.driver" = 2000;
                  "priority.session" = 2000;
                };
              };
            }
          ];
        };
      };
    };
  };

  # Realtime scheduling for low-latency audio
  security.rtkit.enable = true;
}
