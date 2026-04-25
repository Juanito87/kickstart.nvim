-- [[ Gemini CLI integration ]]
-- Opens gemini CLI in a vertical terminal split within Neovim.
-- No API key needed — uses the Gemini CLI directly.

local gemini_buf = nil
local gemini_win = nil
local ai_explain = require 'plugins_config.ai_explain'

local function is_valid()
  return gemini_buf
    and vim.api.nvim_buf_is_valid(gemini_buf)
    and gemini_win
    and vim.api.nvim_win_is_valid(gemini_win)
end

local function open()
  vim.cmd 'vsplit'
  vim.cmd 'terminal gemini'
  gemini_buf = vim.api.nvim_get_current_buf()
  gemini_win = vim.api.nvim_get_current_win()
  vim.cmd 'startinsert'
end

local function toggle()
  if is_valid() then
    vim.api.nvim_win_close(gemini_win, false)
    gemini_win = nil
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

  local chan = vim.bo[gemini_buf].channel
  vim.api.nvim_chan_send(chan, text .. '\n')
end

vim.keymap.set('n', '<leader>cgt', toggle, { desc = '[C]ode [G]emini [T]oggle' })
vim.keymap.set('v', '<leader>cgs', send_selection, { desc = '[C]ode [G]emini [S]end' })
vim.keymap.set('v', '<leader>cge', function() ai_explain.explain_visual 'gemini' end, { desc = '[C]ode [G]emini [E]xplain' })
