return {
  'tpope/vim-fugitive',

  -- set git status remap
  vim.keymap.set('n', '<leader>gs', vim.cmd.Git, { desc = 'Start git buffer and check status' }),
  vim.keymap.set('n', '<C-g>dv', ':Gvdiffsplit!<CR>', { desc = 'Diff split against HEAD vertical' }),
  vim.keymap.set('n', '<C-g>dh', ':Gdiffsplit!<CR>', { desc = 'Diff split against HEAD horizontal' }),
  vim.keymap.set('n', '<C-g>dt', ':windo diffthis<CR>', { desc = 'Diff files in all windows' }),
  vim.keymap.set('n', '<C-g>dm', ':Gdiff!<CR>', { desc = 'On conflicted file opens a 3-way diff' }),
  vim.keymap.set('n', '<C-g>2', ':diffget //2 | diffupdate<CR>', { desc = 'On the middle file get the diff from Head' }),
  vim.keymap.set('n', '<C-g>3', ':diffget //3 | diffupdate<CR>', { desc = 'On the middle file get the diff from the other branch' }),
  vim.keymap.set('n', '<C-g>do', ':diffo!<CR>', { desc = 'Turn off diff mode' }),

  --
  Autocmd('BufWinEnter', {
    group = Fugitive,
    pattern = '*',
    callback = function()
      if vim.bo.ft ~= 'fugitive' then
        return
      end

      local bufnr = vim.api.nvim_get_current_buf()
      local opts = { buffer = bufnr, remap = false }
      vim.keymap.set('n', '<leader>gc', function()
        vim.cmd.Git 'commit'
      end)
      vim.keymap.set('n', '<leader>p', function()
        vim.cmd.Git 'push'
      end, opts)

      -- rebase always
      vim.keymap.set('n', '<leader>P', function()
        vim.cmd.Git { 'pull', '--rebase' }
      end, opts)

      -- NOTE: It allows me to easily set the branch i am pushing and any tracking
      -- needed if i did not set the branch up correctly
      vim.keymap.set('n', '<leader>t', ':Git push -u origin ', opts)
    end,
  }),
}
