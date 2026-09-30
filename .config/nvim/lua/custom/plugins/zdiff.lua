return {
  'martindur/zdiff.nvim',
  cmd = 'Zdiff',
  keys = {
    { '<leader>zd', '<cmd>Zdiff<cr>', desc = '[Z]diff [d]irty (uncommitted)' },
    { '<leader>zD', '<cmd>Zdiff master<cr>', desc = '[Z]diff vs master' },
  },
  opts = {
    default_branch = 'master',
    default_expanded = true,
  },
}
