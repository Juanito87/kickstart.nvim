local M = {}
local sessions = {}

local providers = require 'plugins_config.ai_providers'
local ai_explain = require 'plugins_config.ai_explain'
local pr_draft = require 'plugins_config.pr_draft'

function M.setup(bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- Leave terminal-input mode so regular window and buffer navigation works.
  vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], vim.tbl_extend('force', opts, { desc = 'Terminal Normal Mode' }))

  -- Re-enter terminal-input mode quickly after navigating around.
  vim.keymap.set('n', 'i', function() vim.cmd 'startinsert' end, vim.tbl_extend('force', opts, { desc = 'Terminal Insert Mode' }))
end

local function notify(message, level) vim.notify(message, level or vim.log.levels.INFO, { title = 'AI Terminal' }) end

local function get_visual_selection()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"

  if start_pos[2] == 0 or end_pos[2] == 0 then return nil end

  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  if #lines == 0 then return nil end

  lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  lines[1] = string.sub(lines[1], start_pos[3])

  return table.concat(lines, '\n')
end

local function ensure_executable(provider)
  if vim.fn.executable(provider.executable) == 1 then return true end

  notify(provider.label .. ' CLI is not installed or not in PATH', vim.log.levels.WARN)
  return false
end

local function is_valid(session)
  return session.bufnr and vim.api.nvim_buf_is_valid(session.bufnr) and session.winid and vim.api.nvim_win_is_valid(session.winid)
end

local function start_terminal(provider, session)
  if not ensure_executable(provider) then return false end

  vim.cmd 'vsplit'
  local winid = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.fn.termopen(provider.terminal_cmd())
  session.bufnr = bufnr
  session.winid = winid
  M.setup(bufnr)
  vim.cmd 'startinsert'
  return true
end

local function reopen_terminal(session)
  vim.cmd 'vsplit'
  session.winid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(session.winid, session.bufnr)
  vim.cmd 'startinsert'
end

function M.create_session(provider_name)
  if sessions[provider_name] then return sessions[provider_name] end

  local provider = providers.get(provider_name)
  assert(provider, 'Unknown AI provider: ' .. provider_name)

  local state = {
    bufnr = nil,
    winid = nil,
  }

  local session = {}

  function session.open()
    if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) and (not state.winid or not vim.api.nvim_win_is_valid(state.winid)) then
      reopen_terminal(state)
      return true
    end

    return start_terminal(provider, state)
  end

  function session.toggle()
    if state.winid and vim.api.nvim_win_is_valid(state.winid) then
      vim.api.nvim_win_close(state.winid, false)
      state.winid = nil
      return
    end

    if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
      reopen_terminal(state)
      return
    end

    start_terminal(provider, state)
  end

  function session.send_selection()
    local selection = get_visual_selection()
    if not selection or selection == '' then
      notify('Select some text in visual mode first', vim.log.levels.WARN)
      return
    end

    if not is_valid(state) and not session.open() then return end

    local chan = vim.bo[state.bufnr].channel
    vim.api.nvim_chan_send(chan, selection .. '\n')
  end

  sessions[provider_name] = session
  return session
end

function M.register_provider(provider_name)
  local provider = providers.get(provider_name)
  assert(provider, 'Unknown AI provider: ' .. provider_name)

  local session = M.create_session(provider_name)
  local prefix = '<leader>' .. provider.key_prefix
  local desc_prefix = '[C]ode ' .. provider.key_label

  vim.keymap.set('n', prefix .. 't', session.toggle, { desc = desc_prefix .. ' [T]oggle' })
  vim.keymap.set('v', prefix .. 's', session.send_selection, { desc = desc_prefix .. ' [S]end' })
  vim.keymap.set('v', prefix .. 'e', function() ai_explain.explain_visual(provider_name) end, { desc = desc_prefix .. ' [E]xplain' })
  vim.keymap.set('n', prefix .. 'p', function() pr_draft.generate(provider_name) end, { desc = desc_prefix .. ' [P]R' })

  return session
end

return M
