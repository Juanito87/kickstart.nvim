-- [[ Shared PR draft helper for AI CLIs ]]

local M = {}

local tmpfile = '/tmp/pr-draft.md'
local providers = require 'plugins_config.ai_providers'

local function notify(msg, level) vim.notify(msg, level or vim.log.levels.INFO, { title = 'PR Draft' }) end

local function system(args, cwd)
  local result = vim.system(args, { cwd = cwd, text = true }):wait()
  return result
end

local function git(args, cwd) return system(vim.list_extend({ 'git' }, args), cwd) end

local function trim(text) return (text or ''):gsub('^%s+', ''):gsub('%s+$', '') end

local function repo_root()
  local result = git({ 'rev-parse', '--show-toplevel' }, vim.loop.cwd())
  if result.code ~= 0 then return nil, trim(result.stderr) end
  return trim(result.stdout), nil
end

local function branch_name(cwd)
  local result = git({ 'rev-parse', '--abbrev-ref', 'HEAD' }, cwd)
  if result.code ~= 0 then return nil, trim(result.stderr) end
  return trim(result.stdout), nil
end

local function build_prompt(branch)
  return table.concat({
    'Draft the body for a GitHub pull request for the current repository.',
    'Inspect the current branch diff, staged and unstaged changes, and recent commits yourself.',
    'The PR title is fixed and must be exactly this branch name: ' .. branch .. '.',
    'Return markdown for the PR body only.',
    'Keep it concise and accurate.',
    'Use exactly these sections:',
    '## Summary',
    '- ...',
    '',
    '## Testing',
    '- ...',
  }, '\n')
end

local function write_draft(branch, body)
  local lines = {
    branch,
    '',
  }

  vim.list_extend(lines, vim.split(trim(body), '\n', { plain = true }))
  vim.fn.writefile(lines, tmpfile)
end

local function open_draft() vim.cmd('edit ' .. vim.fn.fnameescape(tmpfile)) end

function M.generate(provider_name)
  local provider = providers.get(provider_name)
  if not provider then
    notify('Unsupported provider: ' .. provider_name, vim.log.levels.ERROR)
    return
  end

  if vim.fn.executable(provider.executable) ~= 1 then
    notify(provider.label .. ' CLI is not installed or not on PATH', vim.log.levels.ERROR)
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

  local prompt = build_prompt(branch)
  local cmd = provider.pr_cmd(root, prompt)

  notify('Generating PR draft with ' .. provider_name .. '...')

  vim.system(cmd, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local err = trim(result.stderr)
        if err == '' then err = 'provider exited with code ' .. result.code end
        notify(provider_name .. ' failed: ' .. err, vim.log.levels.ERROR)
        return
      end

      local body = trim(result.stdout)
      if body == '' then
        notify(provider_name .. ' returned an empty PR body', vim.log.levels.ERROR)
        return
      end

      write_draft(branch, body)
      open_draft()
      notify('PR draft written to ' .. tmpfile)
    end)
  end)
end

return M
