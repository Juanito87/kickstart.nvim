local M = {}

function M.setup(bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- Leave terminal-input mode so regular window and buffer navigation works.
  vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], vim.tbl_extend('force', opts, { desc = 'Terminal Normal Mode' }))

  -- Re-enter terminal-input mode quickly after navigating around.
  vim.keymap.set('n', 'i', function() vim.cmd 'startinsert' end, vim.tbl_extend('force', opts, { desc = 'Terminal Insert Mode' }))
end

return M
