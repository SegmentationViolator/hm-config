{ ... }:

{
    programs.matugen = {
        enable = true;

        templates = {
            niri = {
                input_path = "${./templates/niri.kdl}";
                output_path = "~/niri.kdl";
            };

            waybar = {
                input_path = "${./templates/waybar.css}";
                output_path = "~/waybar.css";
            };
        };
    };
}
