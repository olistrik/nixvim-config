{ config, pkgs, lib, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.codecompanion;
in
{
  options.olistrik.codecompanion = {
    enable = mkEnableOption "codecompanion config";
  };

  config = mkIf cfg.enable {
    extraPlugins = with pkgs.vimPlugins; [
      codecompanion-nvim
    ];

    plugins = {
      # I need copilot to authenticate for codecompanion to work.
      copilot-vim = {
        enable = true;
        package = pkgs.vimPlugins.copilot-vim;
        settings = {
          filetypes = {
            "*" = false; # disable it because it noisy.
          };
        };
      };
      codecompanion = {
        enable = true;
        settings = {
          strategies = {
            agent = {
              adapter = "copilot";
            };
            chat = {
              adapter = "copilot";
              keymaps = {
                send = {
                  modes = { n = "<CR>"; i = "<CR>"; };
                };
              };
            };
            inline = {
              adapter = "copilot";
            };
          };
          display = {
            chat = {
              window = {
                position = "right";
                width = 0.35;
              };
            };
          };
        };
      };
    };

    keymaps =
      let
        set = mode: key: action: options: {
          inherit mode key action options;
        };
      in
      [
        (set [ "n" "v" ] "<C-a>" "<cmd>CodeCompanionActions<cr>" {
          noremap = true;
          silent = true;
        })
        (set [ "n" "v" ] "<leader>a" "<cmd>CodeCompanionChat Toggle<cr>" {
          noremap = true;
          silent = true;
        })
        (set [ "v" ] "ga" "<cmd>CodeCompanionChat Add<cr>" {
          noremap = true;
          silent = true;
        })
      ];
  };
}
