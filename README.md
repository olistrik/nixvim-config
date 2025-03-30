# NixVim à la Oli

This repository describes my personal NeoVim configuration using [NixVim](https://github.com/nix-community/nixvim).

It uses [snowfall-lib](https://github.com/snowfallorg/lib) for similar reasons
as my [nixos-config](https://github.com/olistrik/nixos-config).

Currently, while I've tried to keep my configuration modular, it is mainly for
my benefit than anyone else's.  

If for some reason you'd like to use my configuration as is, this repository
exports both a package which can be run directly using `nix run
github:olistrik/nixvim-config`, and a namespaced overlay that could for example
be used in a shell like so:

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

  # add my repo as an input.
  inputs.olistrik-nixvim = {
    url = "github:olistrik/nixvim-config";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.flake-utils.url = "github:numtide/flake-utils";

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

Alternatively, if you would like to use my NixVim modules in your own configuration:

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  inputs.unstable.url = "github:nixos/nixpkgs/unstable";
  inputs.nixvim.url = "github:nix-community/nixvim/nixos-24.11"; 

  # add my repo as an input.
  inputs.olistrik-nixvim = {
    url = "github:olistrik/nixvim-config";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      # it is wise to also override my unstable and nixvim inputs. 
      unstable.follows = "unstable";
      nixvim.follows = "nixvim";
    };
  };

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { flake-utils, nixpkgs, nixvim, olistrik-nixvim, ... }: 
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {}; # the overlay is not required.
      in {
        devShell = pkgs.mkShell {
         # use it in a shell, environment.systemPackages, etc.
          packages = with pkgs; [ 
            nixvim.makeNixvimModule {
              # import my modules. 
              imports = attrValues olistrik-nixvim.nixvimModules;

              # enable my lsp config.
              olistrik.lsp.enable = true;

              # configure nixvim as usual.
              opts = {
                expandtab = true;
              }
            }
          ];
        };
      };
    );
}
```

I really wouldn't recommend it though. As I don't intend for my personal
modules and configurations to be used by others, they are likely to change
drastically and with very little notice. Maybe in the future I will export a
more stable interface of public modules, but it's more likely that I would try
and get such things merged directly into the upstream NixVim modules. 
