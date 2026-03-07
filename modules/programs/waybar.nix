{ ... }:

{
    programs.waybar = {
        enable = true;

        settings = [{
            height = 32;
            layer = "top";
            margin-left = 4;
            margin-right = 4;
            margin-top = 4;
            modules-center = [ "clock" ];
            modules-left = [ "wlr/taskbar" ];
            modules-right = [ "tray" "network" "wireplumber" "battery" ];
            spacing = 0;

            battery = {
                format = "{icon}";
                format-charging = "&#xe55b;";
                format-plugged = "&#xf1e6;";
                format-icons = [ "&#xf243;" "&#xf242;" "&#xf241;" "&#xf240;" ];
                tooltip-format = "{capacity}%";
            };

            clock = {
                 format = "{:%e %B %R}";
                 tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            };

            network = {
                format-disconnected = "&#xf071;";
                format-ethernet = "&#xf796;";
                format-linked = "&#xf071;";
                format-wifi = "&#xf1eb;";
                tooltip-format = "{essid}";
                tooltip-format-disconnected = "Not Connected";
                tooltip-format-ethernet =    "Ethernet";
                tooltip-format-linked = "No Internet";
            };

            tray = { spacing = 10; };

            wireplumber = {
                format = "&#xf6a9;";
                format-icons = builtins.genList (i: if i == 0 then "&#xf026;" else if i <= 50 then "&#xf027;" else "&#xf028;") 100;
                format-muted = "&#xf6a9;";
                format-nonzero = "{icon}";
                states = { nonzero = 1; };
                tooltip-format = "{volume}%";
            };

            "wlr/taskbar" = {
                format = "{icon}";
                on-click = "activate";
                tooltip-format = "{title}";
            };
        }];

        systemd.enable = true;
    };
}
