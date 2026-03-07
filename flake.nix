{
    description = "Home Manager configuration of ale";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        nur = {
            url = "github:nix-community/NUR";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        matugen = {
            url = "github:InioX/Matugen";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nix-index-database = {
            url = "github:nix-community/nix-index-database";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nvf-config = {
            url = "github:SegmentationViolator/nvf-config";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        { nixpkgs, nur, home-manager, matugen, nix-index-database, nvf-config, ... }:
        let
            system = "x86_64-linux";
            pkgs = nixpkgs.legacyPackages.${system};
        in
        {
            homeConfigurations."ale" = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;

                modules = [
                    ./home.nix
                    matugen.nixosModules.default
                    nix-index-database.homeModules.default
                    nur.modules.homeManager.default
                ];

                extraSpecialArgs = { inherit nvf-config; };
            };
        };
}
