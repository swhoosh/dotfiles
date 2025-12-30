return {
  -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command in the config to whatever the name of that colorscheme is.
  --
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  'folke/tokyonight.nvim',
  enabled = true,
  priority = 1000, -- Make sure to load this before all the other start plugins.
  init = function()
    -- Load the colorscheme here.
    -- Like many other themes, this one has different styles, and you could load
    -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
    require('tokyonight').setup {
      -- style = 'night',
      transparent = true,
      on_colors = function(colors)
        colors.bg = '#090d17'
      end,
      on_highlights = function(highlights, colors)
        highlights.NeoTreeNormal = {
          fg = '#FFFFFF',
          bg = colors.bg,
        }
        highlights.NeoTreeNormalNC = {
          fg = '#AAAAAA',
          bg = colors.bg,
        }
      end,
    }

    -- vim.cmd.colorscheme 'tokyonight-night'
    vim.cmd.colorscheme 'tokyonight'

    -- You can configure highlights by doing something like:
    vim.cmd.hi 'Comment gui=none'
  end,
}
