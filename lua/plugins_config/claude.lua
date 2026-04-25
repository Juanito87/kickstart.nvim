-- [[ Claude Code CLI integration ]]
-- Opens claude CLI in a vertical terminal split within Neovim.
-- No API key needed — uses the Claude Code CLI directly.

local claude_buf = nil
local claude_win = nil
local ai_explain = require 'plugins_config.ai_explain'
local ai_terminal = require 'plugins_config/ai_terminal'
local pr_draft = require 'plugins_config/pr_draft'
local explain_selection = require 'plugins_config/explain_selection'

local function is_valid() return claude_buf and vim.api.nvim_buf_is_valid(claude_buf) and claude_win and vim.api.nvim_win_is_valid(claude_win) end

local function open()
  vim.cmd 'vsplit'
  vim.cmd 'terminal claude'
  claude_buf = vim.api.nvim_get_current_buf()
  claude_win = vim.api.nvim_get_current_win()
  ai_terminal.setup(claude_buf)
  vim.cmd 'startinsert'
end

local function toggle()
  if claude_win and vim.api.nvim_win_is_valid(claude_win) then
    vim.api.nvim_win_close(claude_win, false)
    claude_win = nil
  elseif claude_buf and vim.api.nvim_buf_is_valid(claude_buf) then
    vim.cmd 'vsplit'
    claude_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(claude_win, claude_buf)
    vim.cmd 'startinsert'
  else
    open()
  end
end

local function send_selection()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  if #lines > 0 then
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
    lines[1] = string.sub(lines[1], start_pos[3])
  end
  local text = table.concat(lines, '\n')

  if not is_valid() then open() end

  local chan = vim.bo[claude_buf].channel
  vim.api.nvim_chan_send(chan, text .. '\n')
end

vim.keymap.set('n', '<leader>cct', toggle, { desc = '[C]ode [C]laude [T]oggle' })
vim.keymap.set('v', '<leader>ccs', send_selection, { desc = '[C]ode [C]laude [S]end' })
vim.keymap.set('v', '<leader>cce', function() ai_explain.explain_visual 'claude' end, { desc = '[C]ode [C]laude [E]xplain' })
vim.keymap.set('n', '<leader>ccp', function() pr_draft.generate 'claude' end, { desc = '[C]ode [C]laude [P]R' })
vim.keymap.set('v', '<leader>cce', function() explain_selection.generate 'claude' end, { desc = '[C]ode [C]laude [E]xplain' })
