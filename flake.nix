{
  description = "Nix tool to initialize projects with nix direnv";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ 
        "x86_64-linux" 
        "aarch64-linux"
        "x86_64-darwin" 
        "aarch64-darwin" 
    ];
      
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      nixpkgsFor = system: nixpkgs.legacyPackages.${system};
    in
    {
      packages = forAllSystems (system: let
        pkgs = nixpkgsFor system;
      in {
        default = pkgs.buildGoModule {
          pname = "nix-init";
          version = "0.1.0";
          src = ./.;

          vendorHash = null; 
        };
      });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nix-init";
        };
      });
      
      devShells = forAllSystems (system: let
        pkgs = nixpkgsFor system;
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [ 
            go 
            gopls
          ];
        };
      });
    };
}