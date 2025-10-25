{ lib, pkgs, config, ... }:
with lib;
with lib.olistrik;
let
  cfg = config.olistrik.lsp;
in
{
  options.olistrik.lsp = {
    enable = mkEnableOption "lsp config";
  };
  config = mkIf cfg.enable {
    plugins = {
      # TODO: Move to it's own module?
      none-ls = {
        enable = true;
        sources.diagnostics = {
          glslc = {
            enable = true;
            settings = {
              extra_args = [ "--target-env=opengl" ];
            };
          };
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatOnSave = {
            timeoutMs = 500;
            lspFallback = true;
          };
          formattersByFt = {
            "javascript" = [ "prettier" ];
            "typescript" = [ "prettier" ];
          };
        };
        luaConfig.post = ''
          require("conform").setup({
            format_on_save = function(bufnr)
              -- Disable with a global or buffer-local variable
              if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
              end
              return { timeout_ms = 500, lsp_format = "fallback" }
            end,
          })

          vim.api.nvim_create_user_command("FormatDisable", function(args)
            if args.bang then
              -- FormatDisable! will disable formatting just for this buffer
              vim.b.disable_autoformat = true
            else
              vim.g.disable_autoformat = true
            end
          end, {
            desc = "Disable autoformat-on-save",
            bang = true,
          })
          vim.api.nvim_create_user_command("FormatEnable", function()
            vim.b.disable_autoformat = false
            vim.g.disable_autoformat = false
          end, {
            desc = "Re-enable autoformat-on-save",
          })
        '';
      };

      typescript-tools = {
        enable = true;
      };

      lsp = {
        enable = true;
        servers = {
          # TODO: Extract to seperate locations.
          nil_ls = {
            enable = true;
            extraOptions.settings.nil = {
              formatting.command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
            };
          };

          # matlab-ls = {
          #   enable = true;
          #   settings = {
          #     installPath = "${pkgs.matlab}"; # _without_ /bin/matlab, the lsp adds that.
          #   };
          # };

          ltex =
            {
              enable = true;
            };

          pyright = {
            enable = true;
          };

          cmake = {
            enable = true;
          };

          clangd = {
            enable = true;
          };

          arduino_language_server = {
            # enable = true;
          };

          eslint = {
            enable = true;
          };

          ts_ls = {
            # Use typescript-tools instead.
            # enable = true; 
          };

          tinymist = {
            enable = true;
            package = null;
          };

          gopls = {
            enable = true;
          };
        };

        keymaps = {
          silent = true;
          lspBuf = {
            "gd" = "definition";
            "gD" = "implementation";
            "gk" = "signature_help";
            "0gD" = "type_definition";
            "gr" = "references";
            "g-1" = "document_symbol";
            "ga" = "code_action";
            "K" = "hover";
            "<C-]>" = "declaration";
            "<leader>fm" = "format";
            "<leader>rn" = "rename";
          };
          diagnostic = {
            "g[" = "goto_prev";
            "g]" = "goto_next";
          };
        };
      };

      clangd-extensions = {
        enable = true;
        enableOffsetEncodingWorkaround = true; # clangd and copilot fight apparently.
      };

      cmp = {
        enable = true;

        settings = {
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";

          mapping = {
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.close()";
            "<CR>" = "cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert })";
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
          };

          sources = [
            { name = "nvim_lsp"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
        };
      };

      lsp-format.enable = true;
      luasnip.enable = true;
    };
  };
}
