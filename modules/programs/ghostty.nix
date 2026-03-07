{ ... }:

{
    programs.ghostty = {
        enable = true;

        settings = {
            background-opacity = 0.8;
            font-feature = "+calt, +ss01, +ss02, +ss03, +ss04, +ss05, +ss06, +ss07, +ss08, +ss09, +liga";
            quit-after-last-window-closed = true;
            quit-after-last-window-closed-delay = "5m";
            theme = "TokyoNight";
        };
    };
}
