return {
  'ThePrimeagen/harpoon',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local dataPath = vim.fn.stdpath 'data'
    local canPersist = vim.fn.isdirectory(dataPath) == 1 and vim.fn.filewritable(dataPath) == 2

    require('harpoon').setup {
      global_settings = {
        save_on_change = canPersist,
        save_on_toggle = canPersist,
      },
    }

    local mark = require 'harpoon.mark'
    local ui = require 'harpoon.ui'
    --
    vim.keymap.set('n', '<leader>a', mark.add_file, { desc = 'Mark a file to be used in harpoon' })
    vim.keymap.set('n', '<M-e>', ui.toggle_quick_menu, { desc = 'Toogle harpoon quick menu' })
    --
    vim.keymap.set('n', '<M-u>', function() ui.nav_file(1) end, { desc = 'Navigate to first marked file' })
    vim.keymap.set('n', '<M-i>', function() ui.nav_file(2) end, { desc = 'Navigate to second marked file' })
    vim.keymap.set('n', '<M-o>', function() ui.nav_file(3) end, { desc = 'Navigate to third marked file' })
    vim.keymap.set('n', '<M-p>', function() ui.nav_file(4) end, { desc = 'Navigate to fourth marked file' })
  end,
}
