local M = {}

local function fail(message) error(message, 0) end

local function expect(condition, message)
  if not condition then fail(message) end
end

local function keymap_rhs(mode, lhs)
  local map = vim.fn.maparg(lhs, mode, false, true)
  if type(map) ~= 'table' then return nil end

  return map.rhs or ''
end

local function keymap_desc(mode, lhs)
  local map = vim.fn.maparg(lhs, mode, false, true)
  if type(map) ~= 'table' then return nil end

  return map.desc
end

local function assert_provider(provider)
  expect(type(provider) == 'table', 'provider entry must be a table')
  expect(type(provider.label) == 'string' and provider.label ~= '', 'provider label is required')
  expect(type(provider.executable) == 'string' and provider.executable ~= '', 'provider executable is required')
  expect(type(provider.key_prefix) == 'string' and provider.key_prefix ~= '', 'provider key_prefix is required')
  expect(type(provider.terminal_cmd) == 'function', 'provider terminal_cmd must be a function')
  expect(type(provider.explain_cmd) == 'function', 'provider explain_cmd must be a function')
  expect(type(provider.pr_cmd) == 'function', 'provider pr_cmd must be a function')
end

local function assert_tab_local_toggle_state()
  local savedProviders = package.loaded['plugins_config.ai_providers']
  local savedExplain = package.loaded['plugins_config.ai_explain']
  local savedPrDraft = package.loaded['plugins_config.pr_draft']
  local savedTerminal = package.loaded['plugins_config.ai_terminal']
  local savedExecutable = vim.fn.executable
  local savedTermopen = vim.fn.termopen

  package.loaded['plugins_config.ai_providers'] = {
    get = function(name)
      if name ~= 'test' then return nil end
      return {
        label = 'Test',
        executable = 'test-ai',
        key_prefix = 'ct',
        key_label = '[T]est',
        terminal_cmd = function() return { 'test-ai' } end,
        explain_cmd = function() return { 'test-ai', 'explain' } end,
        pr_cmd = function() return { 'test-ai', 'pr' } end,
      }
    end,
  }
  package.loaded['plugins_config.ai_explain'] = { explain_visual = function() end }
  package.loaded['plugins_config.pr_draft'] = { generate = function() end }
  package.loaded['plugins_config.ai_terminal'] = nil

  vim.fn.executable = function(exe)
    if exe == 'test-ai' then return 1 end
    return savedExecutable(exe)
  end
  vim.fn.termopen = function() return 1 end

  local ok, err = pcall(function()
    vim.cmd 'tabonly'
    vim.cmd 'only'

    local aiTerminal = require 'plugins_config.ai_terminal'
    local session = aiTerminal.create_session 'test'

    local firstTab = vim.api.nvim_get_current_tabpage()
    session.toggle()

    expect(#vim.api.nvim_tabpage_list_wins(firstTab) == 2, 'first tab should open a split when toggled')

    vim.cmd 'tabnew'
    local secondTab = vim.api.nvim_get_current_tabpage()
    expect(#vim.api.nvim_tabpage_list_wins(secondTab) == 1, 'second tab should start with one window')

    session.toggle()

    expect(#vim.api.nvim_tabpage_list_wins(secondTab) == 2, 'second tab toggle should open its own split')
    expect(#vim.api.nvim_tabpage_list_wins(firstTab) == 2, 'toggling in another tab should not close the first tab split')
  end)

  vim.fn.executable = savedExecutable
  vim.fn.termopen = savedTermopen
  package.loaded['plugins_config.ai_providers'] = savedProviders
  package.loaded['plugins_config.ai_explain'] = savedExplain
  package.loaded['plugins_config.pr_draft'] = savedPrDraft
  package.loaded['plugins_config.ai_terminal'] = savedTerminal

  if not ok then error(err, 0) end
end

function M.run()
  package.loaded['plugins_config.codex'] = nil
  package.loaded['plugins_config.claude'] = nil
  package.loaded['plugins_config.gemini'] = nil

  local providers = require 'plugins_config.ai_providers'
  assert_provider(providers.codex)
  assert_provider(providers.claude)
  assert_provider(providers.gemini)

  require 'plugins_config.codex'
  require 'plugins_config.claude'
  require 'plugins_config.gemini'

  expect(keymap_desc('v', '<leader>coe') == '[C]ode [O]penAI [E]xplain', 'codex explain keymap description changed')
  expect(keymap_desc('v', '<leader>cce') == '[C]ode [C]laude [E]xplain', 'claude explain keymap description changed')
  expect(keymap_desc('v', '<leader>cge') == '[C]ode [G]emini [E]xplain', 'gemini explain keymap description changed')

  expect(not keymap_rhs('v', '<leader>coe'):find('explain_selection', 1, true), 'codex explain keymap still points at explain_selection')
  expect(not keymap_rhs('v', '<leader>cce'):find('explain_selection', 1, true), 'claude explain keymap still points at explain_selection')
  expect(not keymap_rhs('v', '<leader>cge'):find('explain_selection', 1, true), 'gemini explain keymap still points at explain_selection')

  assert_tab_local_toggle_state()

  print 'AI config tests passed'
end

return M
