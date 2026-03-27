return { -- Copilot inline completions
    'github/copilot.vim',
    init = function()
      -- Disable the default Tab mapping so nvim-cmp can use Tab normally
      vim.g.copilot_no_tab_map = true
      -- Disable Copilot in certain buffer types
      vim.g.copilot_filetypes = {
        TelescopePrompt = false,
        ['*'] = true,
      }
    end,
    keys = {
      -- Accept suggestion
      { '<C-y>', 'copilot#Accept("")', mode = 'i', expr = true, replace_keycodes = false, desc = 'Copilot: [A]ccept suggestion' },
      -- Cycle suggestions
      { '<M-]>', '<Plug>(copilot-next)', mode = 'i', desc = 'Copilot: [N]ext suggestion' },
      { '<M-[>', '<Plug>(copilot-previous)', mode = 'i', desc = 'Copilot: [P]revious suggestion' },
      -- Dismiss
      { '<C-]>', '<Plug>(copilot-dismiss)', mode = 'i', desc = 'Copilot: [D]ismiss suggestion' },
      -- Enable / disable per buffer
      { '<leader>ae', '<cmd>Copilot enable<cr>', mode = 'n', desc = 'Copilot: [E]nable' },
      { '<leader>ad', '<cmd>Copilot disable<cr>', mode = 'n', desc = 'Copilot: [D]isable' },
    },
  }
