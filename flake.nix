{
  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    devenv.url = "github:Atry/devenv";
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs_24_11 = {
      url = "nixpkgs/nixos-24.11";
    };

    nix-ml-ops = {
      url = "github:Atry/nix-ml-ops";
      inputs.devenv-root.follows = "devenv-root";
      inputs.devenv.follows = "devenv";
      inputs.systems.follows = "systems";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs =
    inputs:
    inputs.nix-ml-ops.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.nix-ml-ops.flakeModules.devcontainer
        inputs.nix-ml-ops.flakeModules.nixIde
        inputs.nix-ml-ops.flakeModules.nixLd
        inputs.nix-ml-ops.flakeModules.ldFallbackManylinux
      ];
      perSystem =
        {
          pkgs,
          config,
          lib,
          system,
          ...
        }:
        {
          nixpkgs.config.allowUnfree = true;
          ml-ops.devcontainer = {
            nixago.requests = {
              ".vscode/extensions.json".data = {
                "recommendations" = [
                  "esbenp.prettier-vscode"
                  "vivaxy.vscode-conventional-commits"
                ];
              };
            };
            devenvShellModule = {
              packages = [
                # pkgs.meteor
                inputs.nixpkgs_24_11.legacyPackages.${system}.meteor
                # pkgs.mongodb
              ];
              # services.mongodb = {
              #   enable = true;
              # };
              dotenv.disableHint = true;
              languages = {
                python = {
                  enable = true;
                  venv = {
                    enable = true;
                  };
                };
                # javascript = {
                #   enable = true;
                #   package = inputs.nixpkgs_24_11.legacyPackages.${system}.nodejs_18;
                #   npm = {
                #     enable = true;
                #     install.enable = true;
                #   };
                # };
              };
            };
          };

        };
    };
}
