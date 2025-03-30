# NixVim à la Oli

This repository describes my personal NeoVim configuration using [NixVim](https://github.com/nix-community/nixvim).

It uses [snowfall-lib](https://github.com/snowfallorg/lib) for similar reasons
as my [nixos-config](https://github.com/olistrik/nixos-config).

Currently, while I've tried to keep my configuration modular, it is mainly for
my benefit than anyone elses.

If for some reason you'd like to use my configuration as is, this repository
exports both a package which can be run directly using `nix run
github:olistrik/nixvim-config`, and a namespaced overlay that can be used as
follows:

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # add my repo as an input.
  inputs.olistrik-nixvim.url = "github:olistrik/nixvim-config";

  outputs = { flake-utils, nixpkgs, olistrik-nixvim, ... }: 
    flake-utils.lib.eachDefaultSystem (
        system: let
            pkgs = import nixpkgs {
                inherit system; 
                overlays = [ 
                    olistrik-nixvim.overlays.default 
                ];
            }; 
        in {
            devShell = pkgs.mkShell {
                # use it in a shell, environment.systemPackages, etc.
                packages = with pkgs; [ olistrik.nixvim ];
            };
        };
    );
}
```

