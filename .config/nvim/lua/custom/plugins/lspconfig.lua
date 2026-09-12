return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', opts = {} }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- LSP stands for Language Server Protocol. A "server" (gopls, ruff, ty, ...)
      -- understands one language and talks to Neovim, the "client". That gives you
      -- go-to-definition, completion, diagnostics, and so on. Servers are separate
      -- programs, which is what `mason` installs for you.
      --
      -- See `:help lsp-vs-treesitter` for how this differs from treesitter.

      --  Runs every time a language server attaches to a buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Highlight other references to the word under the cursor while it rests there.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Ruff and ty both attach to Python buffers. Ruff owns lint/format, ty owns
      -- types and hover, so silence Ruff's hover to avoid two competing popups.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == 'ruff' then
            client.server_capabilities.hoverProvider = false
          end
        end,
        desc = 'LSP: Disable hover capability from Ruff',
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp_biome_format_and_imports', { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= 'biome' then
            return
          end

          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format { async = false }
            end,
            desc = 'Biome format on save',
          })

          vim.keymap.set('n', '<leader>oi', function()
            vim.lsp.buf.code_action {
              context = { only = { 'source.organizeImports' } },
              apply = true,
            }
          end, { buffer = args.buf, desc = 'Biome: Organize Imports' })
        end,
      })

      -- Neovim doesn't advertise every LSP feature by default; nvim-cmp adds
      -- some. Broadcast the extended set to every server.
      vim.lsp.config('*', {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })

      --  Add/remove language servers here. They are installed automatically.
      --  See `:help lspconfig-all` for every pre-configured server, and
      --  `:help vim.lsp.Config` for the keys each table below accepts.
      local servers = {
        clangd = {},
        gopls = {},
        buf_ls = {},
        jsonnet_ls = {},
        ts_ls = {},
        terraformls = {},

        -- Python linting, import sorting and formatting.
        ruff = {},

        -- Python type checking and completion. ty picks the interpreter from
        -- $VIRTUAL_ENV, else a `.venv` in the project root.
        ty = {
          init_options = {
            -- Resolve environments through uv, which also covers PEP 723
            -- script headers. Needs uv >= 0.12.3.
            experimental = { useUv = 'on' },
          },
          settings = {
            ty = {
              diagnosticMode = 'openFilesOnly',
              inlayHints = {
                variableTypes = true,
                callArgumentNames = true,
              },
              completions = {
                autoImport = true,
              },
            },
          },
        },

        biome = {
          -- No project root means no biome config, so don't attach at all.
          root_dir = function(bufnr, on_dir)
            local root = vim.fs.root(bufnr, { 'biome.json', 'biome.jsonc', 'package.json', '.git' })
            if root then
              on_dir(root)
            end
          end,
        },

        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = {
                globals = { 'vim' },
                disable = { 'missing-fields' },
              },
            },
          },
        },
      }

      for name, config in pairs(servers) do
        vim.lsp.config(name, config)
      end

      -- Non-LSP tools (formatters, linters, debuggers) that Mason should keep installed.
      require('mason-tool-installer').setup {
        ensure_installed = {
          'stylua',
        },
      }

      -- Installs the servers above and enables each one via `vim.lsp.enable()`.
      -- It enables *every* installed server that lspconfig knows about, which now
      -- includes `stylua --lsp`. conform already runs stylua, so keep it out.
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = { exclude = { 'stylua' } },
      }
    end,
  },
}
