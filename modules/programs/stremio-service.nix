{ pkgs, ... }:

let
    stremio-service = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/sparky3387/nixpkgs/1955ba843793bdc1812c4eaa7c80aa4800f47e3c/pkgs/by-name/st/stremio-service/package.nix";
        hash = "sha256-FhETg//ABTEIOVQ2ZSrCmGlnFU0d+FO88Ns/6dh4F6k=";
    };
in
{
    home.packages = [ (pkgs.callPackage stremio-service {}) ];

    unfreePackages = [
        "stremio-server"
        "stremio-service"
    ];
}
