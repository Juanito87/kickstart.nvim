-- [[ Claude Code CLI integration ]]
-- Opens claude CLI in a vertical terminal split within Neovim.
-- No API key needed — uses the Claude Code CLI directly.

local claude_buf = nil
local claude_win = nil

local function is_valid()
  return claude_buf
    and vim.api.nvim_buf_is_valid(claude_buf)
    and claude_win
    and vim.api.nvim_win_is_valid(claude_win)
end

local function open()
  vim.cmd 'vsplit'
  vim.cmd 'terminal claude'
  claude_buf = vim.api.nvim_get_current_buf()
  claude_win = vim.api.nvim_get_current_win()
  vim.cmd 'startinsert'
end

local function toggle()
  if is_valid() then
    vim.api.nvim_win_close(claude_win, false)
    claude_win = nil
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

  local chan = vim.bo[claude_buf].channel
  vim.api.nvim_chan_send(chan, text .. '\n')
end

vim.keymap.set('n', '<leader>cct', toggle, { desc = '[C]ode [C]laude [T]oggle' })
vim.keymap.set('v', '<leader>ccs', send_selection, { desc = '[C]ode [C]laude [S]end' })
