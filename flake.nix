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

        llama-cpp = {
            url = "github:TheTom/llama-cpp-turboquant";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # whisp = {
        #     url = "github:SegmentationViolator/Whisp";
        #     inputs.nixpkgs.follows = "nixpkgs";
        # };
    };

    outputs =
        { nixpkgs, nur, home-manager, matugen, nix-index-database, nvf-config, llama-cpp/*, whisp */, ... }:
        let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; };
        in
        {
            homeConfigurations."ale" = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;

                modules = [
                    ./home.nix
                    matugen.nixosModules.default
                    nix-index-database.homeModules.default
                    nur.modules.homeManager.default
                    (_: {
                        home.packages = [
                            nvf-config.packages.${system}.default
                            llama-cpp.packages.${system}.cuda
                            # whisp.packages.${system}.default
                        ];
                    })
                ];

                extraSpecialArgs = { inherit nvf-config; };
            };
        };
}
