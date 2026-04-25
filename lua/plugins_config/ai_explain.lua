local M = {}

local function get_visual_selection()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"

  if start_pos[2] == 0 or end_pos[2] == 0 then
    return nil
  end

  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  if #lines == 0 then
    return nil
  end

  lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  lines[1] = string.sub(lines[1], start_pos[3])

  return table.concat(lines, '\n')
end

local function strip_ansi(line)
  return line:gsub('\27%[[0-9;]*[A-Za-z]', '')
end

local function render_lines(state)
  if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
    return
  end

  vim.bo[state.bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, state.lines)
  vim.bo[state.bufnr].modifiable = false
end

local function append_output(state, data, prefix)
  if not data then
    return
  end

  local incoming = {}
  for _, line in ipairs(data) do
    if line and line ~= '' then
      local clean = strip_ansi(line)
      if prefix then
        clean = prefix .. clean
      end
      table.insert(incoming, clean)
    end
  end

  if #incoming == 0 then
    return
  end

  if not state.has_output then
    state.lines = {}
    state.has_output = true
  end

  vim.list_extend(state.lines, incoming)
  vim.schedule(function() render_lines(state) end)
end

local function open_popup(title)
  local ok, pickers = pcall(require, 'telescope.pickers')
  if not ok then
    vim.notify('Telescope is required for AI explain popups', vim.log.levels.ERROR)
    return nil
  end

  local finders = require 'telescope.finders'
  local previewers = require 'telescope.previewers'
  local conf = require('telescope.config').values
  local themes = require 'telescope.themes'

  local state = {
    title = title,
    lines = { 'Waiting for response...' },
    has_output = false,
    bufnr = nil,
  }

  local picker = pickers.new(themes.get_dropdown {
    previewer = true,
    layout_strategy = 'horizontal',
    layout_config = { width = 0.95, height = 0.85, preview_width = 0.8 },
  }, {
    prompt_title = title,
    results_title = false,
    finder = finders.new_table {
      results = { { value = title, display = title, ordinal = title } },
    },
    sorter = conf.generic_sorter {},
    previewer = previewers.new_buffer_previewer {
      title = 'Explanation',
      define_preview = function(self)
        state.bufnr = self.state.bufnr
        vim.bo[state.bufnr].filetype = 'markdown'
        render_lines(state)
      end,
    },
    attach_mappings = function(_, map)
      local actions = require 'telescope.actions'

      actions.select_default:replace(function() end)
      map('n', 'q', actions.close)
      map('i', '<C-q>', actions.close)
      return true
    end,
  })

  picker:find()
  return state
end

local providers = {
  codex = {
    label = 'Codex',
    command = function(prompt)
      return { 'codex', 'exec', '--skip-git-repo-check', '--color', 'never', prompt }
    end,
  },
  claude = {
    label = 'Claude',
    command = function(prompt)
      return { 'claude', '-p', prompt }
    end,
  },
  gemini = {
    label = 'Gemini',
    command = function(prompt)
      return { 'gemini', '-p', prompt }
    end,
  },
}

local function build_prompt(selection)
  return table.concat({
    'Explain the following selected code or text.',
    'Focus on:',
    '1. What it does.',
    '2. Important context and assumptions.',
    '3. Anything risky, surprising, or non-obvious.',
    'Keep the explanation concise but useful.',
    '',
    '<selection>',
    selection,
    '</selection>',
  }, '\n')
end

function M.explain_visual(provider_name)
  local provider = providers[provider_name]
  if not provider then
    vim.notify('Unknown AI provider: ' .. provider_name, vim.log.levels.ERROR)
    return
  end

  local selection = get_visual_selection()
  if not selection or selection == '' then
    vim.notify('Select some text in visual mode first', vim.log.levels.WARN)
    return
  end

  local executable = provider.command('')[1]
  if vim.fn.executable(executable) ~= 1 then
    vim.notify(provider.label .. ' CLI is not installed or not in PATH', vim.log.levels.ERROR)
    return
  end

  local state = open_popup(provider.label .. ' Explain Selection')
  if not state then
    return
  end

  local job_id = vim.fn.jobstart(provider.command(build_prompt(selection)), {
    -- These CLIs may read from stdin even when a prompt argument is present.
    -- Close stdin immediately so they execute instead of waiting for EOF.
    stdin = 'null',
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data)
      append_output(state, data)
    end,
    on_stderr = function(_, data)
      append_output(state, data, '[stderr] ')
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if not state.has_output then
          state.lines = { 'No explanation was returned.' }
        end

        if code ~= 0 then
          table.insert(state.lines, '')
          table.insert(state.lines, 'Command exited with code ' .. code .. '.')
        end

        render_lines(state)
      end)
    end,
  })

  if job_id <= 0 then
    state.lines = { 'Failed to start ' .. provider.label .. ' CLI.' }
    render_lines(state)
  end
end

return M
