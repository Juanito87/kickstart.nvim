local providers = {
  codex = {
    label = 'Codex',
    executable = 'codex',
    key_prefix = 'co',
    key_label = '[O]penAI',
    terminal_cmd = function() return { 'codex' } end,
    explain_cmd = function(prompt) return { 'codex', 'exec', '--skip-git-repo-check', '--color', 'never', prompt } end,
    pr_cmd = function(repo_root, prompt) return { 'codex', 'exec', '-C', repo_root, '--skip-git-repo-check', prompt } end,
  },
  claude = {
    label = 'Claude',
    executable = 'claude',
    key_prefix = 'cc',
    key_label = '[C]laude',
    terminal_cmd = function() return { 'claude' } end,
    explain_cmd = function(prompt) return { 'claude', '-p', prompt } end,
    pr_cmd = function(_, prompt) return { 'claude', '-p', prompt, '--output-format', 'text' } end,
  },
  gemini = {
    label = 'Gemini',
    executable = 'gemini',
    key_prefix = 'cg',
    key_label = '[G]emini',
    terminal_cmd = function() return { 'gemini' } end,
    explain_cmd = function(prompt) return { 'gemini', '-p', prompt } end,
    pr_cmd = function(_, prompt) return { 'gemini', '--prompt', prompt, '--output-format', 'text' } end,
  },
}

local M = vim.tbl_extend('force', {}, providers)

function M.get(name) return providers[name] end

function M.names() return vim.tbl_keys(providers) end

return M
