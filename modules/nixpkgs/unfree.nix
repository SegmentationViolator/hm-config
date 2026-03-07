{ lib, config, ... }:

{
    config.nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) config.unfreePackages;

    options.unfreePackages = lib.mkOption {
        description = "Name of unfree packages that are to be allowed.";
        type = lib.types.listOf lib.types.str;
        default = [];
    };
}
