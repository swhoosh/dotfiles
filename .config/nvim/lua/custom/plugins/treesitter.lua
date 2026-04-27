return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local ts = require 'nvim-treesitter'

    -- 1. Setup the installation directory
    ts.setup {
      install_dir = vim.fn.stdpath 'data' .. '/site',
    }

    -- 2. Install your desired languages (this is a no-op if already installed)
    local languages = { 'go', 'lua', 'bash', 'c', 'markdown', 'vim', 'vimdoc', 'python', 'javascript', 'typescript', 'rust' }
    ts.install(languages)

    -- 3. Enable Highlighting (Required for this version)
    -- This version does NOT enable highlighting automatically in setup.
    vim.api.nvim_create_autocmd('FileType', {
      pattern = languages,
      callback = function()
        -- You can add logic here to only start for specific filetypes if desired
        vim.treesitter.start()
      end,
    })
  end,
}
