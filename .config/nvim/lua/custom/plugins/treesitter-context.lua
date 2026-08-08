-- Sticky "where am I" header: function/method/class context at top of window (Go + other TS langs).
-- See :help treesitter-context
return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    max_lines = 10,
    multiline_threshold = 4,
  },
}
