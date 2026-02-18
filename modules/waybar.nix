{ config, pkgs, ... }:

{
  # Waybar - Gruvbox status bar for SwayFX

  home.packages = with pkgs; [
    waybar
    brightnessctl  # backlight control
    pavucontrol    # audio control (pulseaudio on-click)
  ];

  xdg.configFile."waybar/config".text = builtins.toJSON {
    layer = "top";
    position = "top";
    height = 48;
    margin-top = 10;
    margin-left = 16;
    margin-right = 16;
    spacing = 10;

    modules-left = [ "sway/workspaces" "sway/window" ];
    modules-center = [ "clock" ];
    modules-right = [
      "tray" "pulseaudio" "network" "battery"
    ];

    "sway/workspaces" = {
      disable-scroll = false;
      all-outputs = true;
      format = "{name}";
    };

    "sway/window" = {
      format = "{}";
      max-length = 50;
    };

    clock = {
      format = "  {:%I:%M %p}    {:%a %b %d}";
      format-alt = "  {:%Y-%m-%d %I:%M:%S %p}";
      tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
    };

    battery = {
      format = "{icon}  {capacity}%";
      format-charging = "  {capacity}%";
      format-plugged = "  {capacity}%";
      format-icons = [ "" "" "" "" "" ];
      states = {
        warning = 30;
        critical = 15;
      };
      tooltip-format = "{timeTo}\nPower: {power}W";
    };

    network = {
      format-wifi = "󰤨  {essid} ({signalStrength}%)";
      format-ethernet = "󰈀  {ifname}";
      format-disconnected = "󰤭  Disconnected";
      tooltip-format = "{ifname}: {ipaddr}/{cidr}";
      interval = 2;
    };

    pulseaudio = {
      format = "{icon}  {volume}%";
      format-muted = "󰖁  {volume}%";
      format-icons = {
        headphone = "󰋋";
        default = [ "󰕿" "󰖀" "󰕾" ];
      };
      on-click = "pavucontrol";
    };

    tray = {
      icon-size = 18;
      spacing = 8;
    };

  };

  xdg.configFile."waybar/style.css".text = ''
    * {
        font-family: "DankMono Nerd Font", "Font Awesome 6 Free";
        font-size: 17px;
        font-weight: 500;
        border: none;
        border-radius: 0;
        min-height: 0;
        margin: 0;
        padding: 0;
    }

    window#waybar {
        background: transparent;
        color: #fbf1c7;
    }

    #workspaces,
    #window,
    #clock,
    #battery,
    #network,
    #pulseaudio,
    #tray {
        padding: 6px 16px;
        margin: 4px 2px;
        background: linear-gradient(135deg, #282828 0%, #3c3836 100%);
        color: #fbf1c7;
        border-radius: 12px;
        border: 2px solid #504945;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
    }

    #workspaces:hover,
    #window:hover,
    #clock:hover,
    #battery:hover,
    #network:hover,
    #pulseaudio:hover,
    #tray:hover {
        background: linear-gradient(135deg, #3c3836 0%, #504945 100%);
        border-color: #ffd040;
        box-shadow: 0 4px 12px rgba(250, 189, 47, 0.3);
    }

    #workspaces button {
        padding: 0 8px;
        color: #a09080;
        border: none;
        border-radius: 8px;
        background: transparent;
    }

    #workspaces button.focused {
        background: linear-gradient(135deg, #ffd040 0%, #e8a50e 100%);
        color: #1d2021;
        font-weight: bold;
    }

    #workspaces button.urgent {
        background: linear-gradient(135deg, #ff5050 0%, #d42020 100%);
        color: #1d2021;
    }

    #window {
        color: #60c0ff;
        font-style: italic;
    }

    #clock {
        background: linear-gradient(135deg, #60c0ff 0%, #4f96c8 100%);
        color: #1d2021;
        font-weight: bold;
        padding: 6px 20px;
        border-color: #60ff90;
    }

    #battery { color: #ffd040; }

    #battery.charging {
        background: linear-gradient(135deg, #d0f020 0%, #a8b020 100%);
        color: #1d2021;
    }

    #battery.warning:not(.charging) {
        background: linear-gradient(135deg, #ff9030 0%, #e86420 100%);
        color: #1d2021;
        animation: blink 2s linear infinite;
    }

    #battery.critical:not(.charging) {
        background: linear-gradient(135deg, #ff5050 0%, #d42020 100%);
        color: #1d2021;
        animation: blink 1s linear infinite;
    }

    #network { color: #60c0ff; }

    #network.disconnected {
        background: linear-gradient(135deg, #801010 0%, #d42020 100%);
        color: #fbf1c7;
    }

    #pulseaudio { color: #ff60d0; }

    #pulseaudio.muted {
        background: linear-gradient(135deg, #3c3836 0%, #504945 100%);
        color: #a09080;
    }

    #tray { padding: 6px 12px; }
    #tray > .passive { opacity: 0.7; }
    #tray > .needs-attention {
        background-color: #ff5050;
        animation: blink 1s linear infinite;
    }

    @keyframes blink {
        0% { opacity: 1.0; }
        49% { opacity: 1.0; }
        50% { opacity: 0.7; }
        100% { opacity: 0.7; }
    }

    tooltip {
        background: #1d2021;
        border: 2px solid #ffd040;
        border-radius: 12px;
        padding: 8px 12px;
    }

    tooltip label {
        color: #fbf1c7;
        font-family: "DankMono Nerd Font";
    }
  '';
}
