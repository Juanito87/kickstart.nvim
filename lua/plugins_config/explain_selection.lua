-- [[ Shared code explanation helper for AI CLIs ]]

local M = {}

local providers = {
  claude = {
    cmd = function(repo_root, prompt)
      return { 'claude', '-p', prompt, '--output-format', 'text' }
    end,
  },
  codex = {
    cmd = function(repo_root, prompt)
      return { 'codex', 'exec', '-C', repo_root, '--skip-git-repo-check', prompt }
    end,
  },
  gemini = {
    cmd = function(repo_root, prompt)
      return { 'gemini', '--prompt', prompt, '--output-format', 'text' }
    end,
  },
}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'Explain Selection' })
end

local function system(args, cwd)
  return vim.system(args, { cwd = cwd, text = true }):wait()
end

local function git(args, cwd)
  return system(vim.list_extend({ 'git' }, args), cwd)
end

local function trim(text)
  return (text or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

local function repo_root()
  local result = git({ 'rev-parse', '--show-toplevel' }, vim.loop.cwd())
  if result.code ~= 0 then
    return nil, trim(result.stderr)
  end
  return trim(result.stdout), nil
end

local function get_visual_selection()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  if #lines == 0 then
    return nil
  end

  lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  lines[1] = string.sub(lines[1], start_pos[3])

  return {
    text = table.concat(lines, '\n'),
    start_line = start_pos[2],
    end_line = end_pos[2],
  }
end

local function build_prompt(selection, relative_path)
  return table.concat({
    'Explain the following code selection.',
    'Be concise but useful.',
    'Focus on:',
    '- what it does',
    '- important control flow or data flow',
    '- any notable risks, assumptions, or edge cases',
    '',
    'Return plain markdown only.',
    'Do not ask follow-up questions.',
    'Do not suggest next steps unless they are essential to understanding the code.',
    '',
    'File: ' .. relative_path,
    'Lines: ' .. selection.start_line .. '-' .. selection.end_line,
    '',
    '```',
    selection.text,
    '```',
  }, '\n')
end

local function show_in_telescope(title, content)
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local previewers = require 'telescope.previewers'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  local lines = vim.split(content, '\n', { plain = true })

  pickers
    .new({}, {
      prompt_title = title,
      finder = finders.new_table {
        results = {
          {
            value = content,
            display = 'Explanation',
            ordinal = 'explanation',
          },
        },
      },
      sorter = conf.generic_sorter {},
      previewer = previewers.new_buffer_previewer {
        title = 'Explanation',
        define_preview = function(self, entry)
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(entry.value, '\n', { plain = true }))
          vim.bo[self.state.bufnr].filetype = 'markdown'
          vim.bo[self.state.bufnr].modifiable = false
          vim.bo[self.state.bufnr].readonly = true
        end,
      },
      attach_mappings = function(prompt_bufnr, map)
        local function close_picker()
          actions.close(prompt_bufnr)
        end

        map('i', '<CR>', close_picker)
        map('i', '<Esc>', close_picker)
        map('n', 'q', close_picker)
        map('n', '<Esc>', close_picker)
        map('n', '<CR>', close_picker)

        actions.select_default:replace(function()
          local _ = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
        end)

        return true
      end,
    })
    :find()

  if #lines == 0 then
    notify('Explanation was empty', vim.log.levels.WARN)
  end
end

function M.generate(provider_name)
  local provider = providers[provider_name]
  if not provider then
    notify('Unsupported provider: ' .. provider_name, vim.log.levels.ERROR)
    return
  end

  if vim.fn.executable(provider_name) ~= 1 then
    notify(provider_name .. ' is not installed or not on PATH', vim.log.levels.ERROR)
    return
  end

  local selection = get_visual_selection()
  if not selection or trim(selection.text) == '' then
    notify('No visual selection found', vim.log.levels.ERROR)
    return
  end

  local root, root_err = repo_root()
  if not root then
    notify('Not inside a git repository: ' .. root_err, vim.log.levels.ERROR)
    return
  end

  local file_path = vim.api.nvim_buf_get_name(0)
  local relative_path = vim.fn.fnamemodify(file_path, ':.')
  if relative_path == '' then
    relative_path = '[No Name]'
  end

  local prompt = build_prompt(selection, relative_path)
  local cmd = provider.cmd(root, prompt)

  notify('Generating explanation with ' .. provider_name .. '...')

  vim.system(cmd, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local err = trim(result.stderr)
        if err == '' then
          err = 'provider exited with code ' .. result.code
        end
        notify(provider_name .. ' failed: ' .. err, vim.log.levels.ERROR)
        return
      end

      local explanation = trim(result.stdout)
      if explanation == '' then
        notify(provider_name .. ' returned an empty explanation', vim.log.levels.ERROR)
        return
      end

      show_in_telescope('Explain ' .. relative_path, explanation)
    end)
  end)
end

return M
