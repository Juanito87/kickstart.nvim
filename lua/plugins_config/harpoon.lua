return {
  'ThePrimeagen/harpoon',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    require('harpoon').setup {}
    -- local harpoon = require('harpoon')
    local mark = require 'harpoon.mark'
    local ui = require 'harpoon.ui'
    --
    vim.keymap.set('n', '<leader>a', mark.add_file, { desc = 'Mark a file to be used in harpoon' })
    vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu, { desc = 'Toogle harpoon quick menu' })
    --
    vim.keymap.set('n', '<C-u>', function()
      ui.nav_file(1)
    end, { desc = 'Navigate to first marked file' })
    vim.keymap.set('n', '<C-i>', function()
      ui.nav_file(2)
    end, { desc = 'Navigate to first marked file' })
    vim.keymap.set('n', '<C-o>', function()
      ui.nav_file(3)
    end, { desc = 'Navigate to first marked file' })
    vim.keymap.set('n', '<C-p>', function()
      ui.nav_file(4)
    end, { desc = 'Navigate to first marked file' })
  end,
}
