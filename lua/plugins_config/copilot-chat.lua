return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'nvim-lua/plenary.nvim', branch = 'master' },
    },
    build = 'make tiktoken',
    opts = {
      -- Model to use. Requires Copilot Business/Enterprise for claude models.
      -- Fall back to 'gpt-4o' if you are on a free/individual plan.
      model = 'claude-sonnet-4.5',
      auto_follow_cursor = true,
      show_help = true,
      window = {
        layout = 'vertical',
        width = 0.35, -- fraction of editor width
      },
    },
    keys = {
      -- Toggle the chat window
      { '<leader>aa', '<cmd>CopilotChatToggle<cr>', mode = { 'n', 'v' }, desc = '[A]I: Toggle chat' },

      -- Quick inline prompt (opens chat with a custom user question)
      {
        '<leader>aq',
        function()
          local input = vim.fn.input 'Quick chat: '
          if input ~= '' then
            require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
          end
        end,
        mode = { 'n', 'v' },
        desc = '[A]I: [Q]uick chat',
      },

      -- Context-aware quick actions (work on visual selection or current buffer)
      { '<leader>ac', '<cmd>CopilotChatExplain<cr>',  mode = { 'n', 'v' }, desc = '[A]I: [C]omment / Explain' },
      { '<leader>af', '<cmd>CopilotChatFix<cr>',      mode = { 'n', 'v' }, desc = '[A]I: [F]ix bug' },
      { '<leader>at', '<cmd>CopilotChatTests<cr>',    mode = { 'n', 'v' }, desc = '[A]I: Generate [T]ests' },
      { '<leader>ar', '<cmd>CopilotChatOptimize<cr>', mode = { 'n', 'v' }, desc = '[A]I: [R]efactor / Optimize' },
      { '<leader>aD', '<cmd>CopilotChatDocs<cr>',     mode = { 'n', 'v' }, desc = '[A]I: Generate [D]ocs' },

      -- Git commit message (uses staged diff; run `git add` first)
      { '<leader>am', '<cmd>CopilotChatCommit<cr>', mode = 'n', desc = '[A]I: [M]ake commit message' },
    },
  },
}
