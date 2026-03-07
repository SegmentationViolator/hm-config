{ ... }:

{
    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
    };

    programs.nix-your-shell.enable = true;
}
