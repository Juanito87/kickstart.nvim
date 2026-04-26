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

  print 'AI config tests passed'
end

return M
