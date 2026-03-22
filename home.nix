{ config, lib, pkgs, nvf-config, ... }:

let

    backdrop = pkgs.runCommand "backdrop.png" { buildInputs = [ pkgs.imagemagick ]; } ''
        ${lib.getExe' pkgs.imagemagick "magick"} ${wallpaper} -blur 0x8 -fill black -colorize 40% $out
    '';

    icon-theme = pkgs.papirus-icon-theme.override {
        color = "violet";
    };

    wallpaper = pkgs.fetchurl {
        url = "https://w.wallhaven.cc/full/1q/wallhaven-1q83qg.jpg";
        hash = "sha256-QPmG4QTRvubuX6Fy5rmMwYKw4aQdBiH/zGL/PMmUZOk=";
    };
in
{
    home.username = "ale";
    home.homeDirectory = "/home/ale";

    home.stateVersion = "26.05";

    imports = [
        ./modules/nixpkgs/unfree.nix
        ./modules/programs/direnv.nix
        ./modules/programs/gh.nix
        ./modules/programs/ghostty.nix
        ./modules/programs/waybar.nix
        ./modules/programs/stremio-service.nix
        ./modules/programs/zsh.nix
        ./modules/services/mako.nix
    ];

    fonts.fontconfig.enable = true;

    gtk = {
        enable = true;
        colorScheme = "dark";
        gtk4.theme = config.gtk.theme;

        iconTheme = {
            name = "Papirus";
            package = icon-theme;
        };

        theme = {
            name = "Arc";
            package = pkgs.arc-theme;
        };
    };

    home.packages = with pkgs; [
        codex
        devenv
        element-desktop
        feishin
        halloy
        mpv
        nautilus
        nur.repos.forkprince.helium-nightly
        nvf-config.packages.${pkgs.stdenv.hostPlatform.system}.default
        obs-studio
        overskride
        swaybg
        vesktop
        wl-clipboard
        xdg-utils
        zulip

        font-awesome
        monaspace
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
    ];

    home.pointerCursor =
        let
            getFrom = url: hash: name: {
                inherit name;

                enable = true;
                dotIcons.enable = false;
                gtk.enable = true;

                size = 24;
                package =
                pkgs.runCommand name {} ''
                    mkdir -p $out/share/icons
                    ln -s ${pkgs.fetchzip { inherit url hash; }} $out/share/icons/${name}
                '';
            };
        in
            getFrom
                "https://github.com/SegmentationViolator/kafka-cursors/releases/download/v1.0/Kafka.tar.gz"
                "sha256-9EKH8A66VrF20S9uSp9+e/qUfXOmBQF6GyycMFaWgiI="
                "Kafka";

    home.preferXdgDirectories = true;

    programs.fuzzel = {
        enable = true;

        settings = {
            main = {
                icon-theme = "Papirus";
                terminal = "${lib.getExe' pkgs.ghostty "ghostty"} -e {cmd}";
            };

            colors = {
                background = "${config.programs.matugen.theme.colors.background.default.color}ff";
                text = "${config.programs.matugen.theme.colors.on_surface.default.color}ff";
                prompt = "${config.programs.matugen.theme.colors.secondary.default.color}ff";
                placeholder = "${config.programs.matugen.theme.colors.tertiary.default.color}ff";
                input = "${config.programs.matugen.theme.colors.primary.default.color}ff";
                match = "${config.programs.matugen.theme.colors.tertiary.default.color}ff";
                selection = "${config.programs.matugen.theme.colors.primary.default.color}ff";
                selection-text = "${config.programs.matugen.theme.colors.on_surface.default.color}ff";
                selection-match = "${config.programs.matugen.theme.colors.on_primary.default.color}ff";
                counter = "${config.programs.matugen.theme.colors.secondary.default.color}ff";
                border = "${config.programs.matugen.theme.colors.primary.default.color}ff";
            };
        };
    };

    programs.ghostty.settings.font-family = "Monaspace Neon";

    programs.git = {
        enable = true;

        settings = {
            init.defaultBranch = "main";
            user = {
                name = "Segmentation Violator";
                email = "segmentationviolator@proton.me";
            };
        };

        signing.signByDefault = true;
    };

    programs.home-manager.enable = true;

    programs.hyfetch = {
        enable = true;

        settings = {
            preset = "transbian";
            mode = "rgb";
            light_dark = "dark";
            lightness = 0.65;
            backend = "fastfetch";
            color_align = { mode = "horizontal"; };
            pride_month_disable = false;
        };
    };

    programs.matugen = {
        inherit wallpaper;
        enable = true;

        templates = {
            niri = {
                input_path = "${./niri.kdl}";
                output_path = "~/niri.kdl";
            };
            waybar = {
                input_path = "${./waybar.css}";
                output_path = "~/waybar.css";
            };
        };
    };

    programs.nix-index.enable = true;

    programs.waybar.style = builtins.readFile (config.programs.matugen.theme.files + "/waybar.css");

    services.mako.settings = {
        background-color = "#${config.programs.matugen.theme.colors.on_primary.default.color}";
        border-color = "#${config.programs.matugen.theme.colors.tertiary_container.default.color}";
        icon-path = "${icon-theme}/share/icons/Papirus";
        text-color = "#${config.programs.matugen.theme.colors.tertiary.default.color}";

        "urgency=high" = {
            border-color = "#${config.programs.matugen.theme.colors.error_container.default.color}";
        };
    };

    services.swww = {
        enable = true;
        extraArgs = [ "--no-cache" ];
    };

    systemd.user.services.set-wallpaper = {
        Install = {
            WantedBy = [ "graphical-session.target" ];
        };

        Unit = {
            ConditionEnvironment = "WAYLAND_DISPLAY";
            Description = "Set Wallpaper Using swww";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
        };

        Service = {
            ExecStart = "${lib.getExe' pkgs.swww "swww"} img --resize stretch --transition-type center ${wallpaper}";
            Restart = "on-failure";
        };
    };

    systemd.user.services.set-backdrop = {
        Install = {
            WantedBy = [ "graphical-session.target" ];
        };

        Unit = {
            ConditionEnvironment = "WAYLAND_DISPLAY";
            Description = "Set Backdrop Using swaybg";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
        };

        Service = {
            ExecStart = "${lib.getExe' pkgs.swaybg "swaybg"} -m stretch -i ${backdrop}";
            Restart = "on-failure";
        };
    };

    xdg.enable = true;

    xdg.desktopEntries = {
        bottom = {
            name = "bottom";
            noDisplay = true;
        };

        nixos-manual = {
            name = "NixOS Manual";
            noDisplay = true;
        };
    };

    xdg.configFile."autostart/com.stremio.service.desktop" = {
        force = true;
        text = "";
    };

    xdg.configFile."niri/config.kdl".source = config.programs.matugen.theme.files + "/niri.kdl";
}
