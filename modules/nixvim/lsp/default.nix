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

          pylsp = {
            enable = true;
            settings = {
              plugins = {
                autopep8 = { enabled = true; };
                flake8 = { enabled = false; };
                jedi = {
                  auto_import_modules = [ "numpy" ];
                  extra_paths = [ ];
                  env_vars = null;
                  environment = null;
                };
                jedi_completion = {
                  enabled = true;
                  include_params = true;
                  include_class_objects = false;
                  include_function_objects = false;
                  fuzzy = false;
                  eager = false;
                  resolve_at_most = 25;
                  cache_for = [
                    "pandas"
                    "numpy"
                    "pytorch"
                    "matplotlib"
                  ];
                };
                jedi_definition = {
                  enabled = true;
                  follow_imports = true;
                  follow_builtin_imports = true;
                  follow_builtin_definitions = true;
                };
                jedi_hover = { enabled = true; };
                jedi_references = { enabled = true; };
                jedi_signature_help = { enabled = true; };
                jedi_symbols = {
                  enabled = true;
                  all_scopes = true;
                  include_import_symbols = true;
                };
                mccabe = {
                  enabled = true;
                  threshold = 15;
                };
                preload = {
                  enabled = true;
                  modules = [ ];
                };
                pycodestyle = {
                  enabled = true;
                  exclude = [ ];
                  filename = [ ];
                  select = null;
                  ignore = [ ];
                  hangClosing = true;
                  maxLineLength = 80;
                  indentSize = 4;
                  ropeFolder = null; # This isn't in the docs?
                };
                pydocstyle = {
                  enabled = false;
                  convention = null;
                  addIgnore = [ ];
                  addSelect = [ ];
                  ignore = [ ];
                  select = null;
                  match = "(?!test_).*\\.py";
                  matchDir = "[^\\.].*";
                };
                pyflakes = { enabled = true; };
                pylint = {
                  enabled = false;
                  args = [ ];
                  executable = null;
                };
                rope_autoimport = {
                  enabled = true;
                  completions = { enabled = true; };
                  code_actions = { enabled = true; };
                  memory = false;
                };
                rope_completion = {
                  enabled = false;
                  eager = false;
                };
                yapf = {
                  enabled = true;
                };
              };
              rope = {
                extensionModules = null;
                ropeFolder = null;
              };
            };
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
            enable = true;
          };

          tinymist = {
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
