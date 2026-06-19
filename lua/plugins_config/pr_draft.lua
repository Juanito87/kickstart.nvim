-- [[ Shared PR draft helper for AI CLIs ]]

local M = {}

local function draft_path(branch)
  return '/tmp/pr-' .. branch:gsub('/', '-') .. '.md'
end

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
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'PR Draft' })
end

local function system(args, cwd)
  local result = vim.system(args, { cwd = cwd, text = true }):wait()
  return result
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

local function branch_name(cwd)
  local result = git({ 'rev-parse', '--abbrev-ref', 'HEAD' }, cwd)
  if result.code ~= 0 then
    return nil, trim(result.stderr)
  end
  return trim(result.stdout), nil
end

local function build_prompt()
  return table.concat({
    'Draft a GitHub pull request for the current repository.',
    'Inspect the current branch diff, staged and unstaged changes, and recent commits yourself.',
    'Return exactly this format — no code fences, no preamble, nothing else:',
    '',
    '<Title>',
    '',
    '## Summary',
    '- ...',
    '',
    '## Testing',
    '- ...',
    '',
    'Where <Title> is a single concise human-readable PR title: sentence case, imperative mood,',
    'no trailing punctuation, at most 70 characters, not the raw branch name.',
    'Keep the body concise and accurate.',
  }, '\n')
end

local function write_draft(path, content)
  local lines = vim.split(trim(content), '\n', { plain = true })
  -- Guard: if the AI skipped the title and started with a heading, we'd have
  -- no plain-text first line for `ghpr` to use as --title. Detect and warn.
  local first = trim(lines[1] or '')
  if first == '' or first:sub(1, 1) == '#' then
    notify('PR draft title missing — first line should be a plain-text title', vim.log.levels.WARN)
  end
  vim.fn.writefile(lines, path)
end

local function open_draft(path)
  vim.cmd('edit ' .. vim.fn.fnameescape(path))
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

  local root, root_err = repo_root()
  if not root then
    notify('Not inside a git repository: ' .. root_err, vim.log.levels.ERROR)
    return
  end

  local branch, branch_err = branch_name(root)
  if not branch then
    notify('Unable to resolve branch name: ' .. branch_err, vim.log.levels.ERROR)
    return
  end

  local path = draft_path(branch)
  local prompt = build_prompt()
  local cmd = provider.cmd(root, prompt)

  notify('Generating PR draft with ' .. provider_name .. '...')

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

      local content = trim(result.stdout)
      if content == '' then
        notify(provider_name .. ' returned an empty PR draft', vim.log.levels.ERROR)
        return
      end

      write_draft(path, content)
      open_draft(path)
      notify('PR draft written to ' .. path)
    end)
  end)
end

return M
