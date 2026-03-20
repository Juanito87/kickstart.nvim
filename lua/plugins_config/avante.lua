return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  build = 'make',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  opts = {
    -- Uses the local `claude` CLI (Claude Code), no API key required.
    -- Requires `claude` to be on PATH and already authenticated.
    provider = 'claude_code',
    window = {
      width = 35, -- percentage of editor width
    },
  },
  keys = {
    { '<leader>aa', '<cmd>AvanteAsk<cr>',     mode = { 'n', 'v' }, desc = '[A]I: [A]sk' },
    { '<leader>ae', '<cmd>AvanteEdit<cr>',    mode = 'v',          desc = '[A]I: [E]dit selection' },
    { '<leader>at', '<cmd>AvanteToggle<cr>',  mode = 'n',          desc = '[A]I: [T]oggle panel' },
    { '<leader>ar', '<cmd>AvanteRefresh<cr>', mode = 'n',          desc = '[A]I: [R]efresh' },
  },
}
