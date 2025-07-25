{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixvim = {
      # TODO: Some kind of assertion that this matches the nixpkgs url. 
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # using snowfall for now as it makes it easier to migrate from my system config.
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;

        snowfall = {
          namespace = "olistrik";
          meta = {
            name = "nixvim-config";
            title = "My NixVim Configuration";
          };
        };
      };
    in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
      };

      nixvimModules = lib.snowfall.module.create-modules {
        src = ./modules/nixvim;
      };

      overlays = with inputs; [
        nixvim.overlays.default
      ];

      alias = {
        packages.default = "nixvim";
      };
    };
}
