{ config, lib, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.common;
  autoCmd = {
    indentOverride = pattern: expandTab: spaces: {
      inherit pattern;
      event = [ "FileType" ];
      command = lib.concatStringsSep " " [
        "setlocal"
        "tabstop=${toString spaces}"
        "softtabstop=${toString spaces}"
        "shiftwidth=${toString spaces}"
        (if expandTab then "expandtab" else "noexpandtab")
      ];
    };
  };
in
{
  options.olistrik.common = {
    enable = mkEnableOption "common config";
  };

  config = mkIf cfg.enable {
    plugins = {
      # Visual aids.
      colorizer = enabled; # does this: #FF0
      todo-comments = enabled; # NOTE: Does this.

      # Commenting utilities.
      comment = enabled;

      # Brackets? Parentheses? XML Tags? Stuff for that.
      vim-surround = enabled;
      nvim-autopairs = enabled;

      # Pretty <leader>rn windows.
      dressing = {
        enable = true;
        settings = {
          input = {
            insert_only = false;
          };
        };
      };

      render-markdown = {
        enable = true;
        settings = {
          render_modes = true;
          file_types = [ "markdown" "codecompanion" ];
          overrides = {
            filetype = {
              codecompanion = {
                html = {
                  tag = {
                    # Shamelessly copied: https://github.com/olimorris/dotfiles/blob/b7d2f82c8411fa01602018684aa924abaeb5dd40/.config/nvim/lua/plugins/ui.lua
                    buf = { icon = " "; highlight = "CodeCompanionChatIcon"; };
                    file = { icon = " "; highlight = "CodeCompanionChatIcon"; };
                    group = { icon = " "; highlight = "CodeCompanionChatIcon"; };
                    help = { icon = "󰘥 "; highlight = "CodeCompanionChatIcon"; };
                    image = { icon = " "; highlight = "CodeCompanionChatIcon"; };
                    symbols = { icon = " "; highlight = "CodeCompanionChatIcon"; };
                    tool = { icon = "󰯠 "; highlight = "CodeCompanionChatIcon"; };
                    url = { icon = "󰌹 "; highlight = "CodeCompanionChatIcon"; };
                  };
                };
              };
            };
          };
        };
      };

      # luasnip = enabled;
      # harpoon = enabled;
      # abolish = enabled;
      # easy-align = enabled;
      # vim-repeat = enabled;
    };

    ## Misc stuff below.

    colorschemes.ayu = {
      enable = true;
      settings.mirage = true;
    };

    # BUG: Doesn't seem to always work. LSP getting in the way?
    editorconfig.enable = true;

    # merge wayland and nvim clipboards.
    clipboard = {
      register = [ "unnamed" "unnamedplus" ];
      providers.wl-copy.enable = true;
    };

    globals.mapleader = " ";

    keymaps = [
      {
        key = ";";
        action = ":";
        options.noremap = false;
      }
      {
        key = ";;";
        action = ";";
      }
    ];

    opts = {
      number = true;
      relativenumber = true;
      laststatus = 1;
      scrolloff = 5;
      incsearch = true;
      hlsearch = false;
      mouse = "nvchr";
      signcolumn = "yes";

      # TODO: Tabs for indentation, spaces for alignment.
      expandtab = false;
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 4;

      spell = true;
    };

    autoCmd = with autoCmd; [
      (indentOverride [ "nix" ] true 2)
      {
        event = [ "FileType" ];
        pattern = [ "codecompanion" ];
        callback = {
          __raw = '' 
          function(args)
            local clients = vim.lsp.get_clients({bufnr = args.buf})
            for _, client in ipairs(clients) do
              vim.lsp.buf_detach_client(args.buf, client.id)
            end

            vim.keymap.set("i", "<C-CR>", "<CR>", { buffer = true, noremap = true, silent = true })
          end
        '';
        };
      }
    ];
  };

}

