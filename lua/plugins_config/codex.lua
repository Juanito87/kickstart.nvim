-- [[ Codex CLI integration ]]
-- Opens codex CLI in a vertical terminal split within Neovim.
-- No API key needed here if the Codex CLI is already authenticated.

local codex_buf = nil
local codex_win = nil
local ai_terminal = require 'plugins_config/ai_terminal'
local pr_draft = require 'plugins_config/pr_draft'
local explain_selection = require 'plugins_config/explain_selection'

local function is_valid()
  return codex_buf
    and vim.api.nvim_buf_is_valid(codex_buf)
    and codex_win
    and vim.api.nvim_win_is_valid(codex_win)
end

local function open()
  vim.cmd 'vsplit'
  vim.cmd 'terminal codex'
  codex_buf = vim.api.nvim_get_current_buf()
  codex_win = vim.api.nvim_get_current_win()
  ai_terminal.setup(codex_buf)
  vim.cmd 'startinsert'
end

local function toggle()
  if codex_win and vim.api.nvim_win_is_valid(codex_win) then
    vim.api.nvim_win_close(codex_win, false)
    codex_win = nil
  elseif codex_buf and vim.api.nvim_buf_is_valid(codex_buf) then
    vim.cmd 'vsplit'
    codex_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(codex_win, codex_buf)
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

  if not is_valid() then
    open()
  end

  local chan = vim.bo[codex_buf].channel
  vim.api.nvim_chan_send(chan, text .. '\n')
end

vim.keymap.set('n', '<leader>cot', toggle, { desc = '[C]ode [O]penAI [T]oggle' })
vim.keymap.set('v', '<leader>cos', send_selection, { desc = '[C]ode [O]penAI [S]end' })
vim.keymap.set('n', '<leader>cop', function() pr_draft.generate 'codex' end, { desc = '[C]ode [O]penAI [P]R' })
vim.keymap.set('v', '<leader>coe', function() explain_selection.generate 'codex' end, { desc = '[C]ode [O]penAI [E]xplain' })
