local M = {}

local coreModules = {
  'options',
  'keymaps',
  'autocommands',
  'plugins_config/pr_draft',
  'plugins_config/explain_selection',
  'plugins_config/claude',
  'plugins_config/codex',
  'plugins_config/gemini',
}

local pluginSpecModules = {
  'plugins_config/autocomplete',
  'plugins_config/code_runner',
  'plugins_config/colortheme',
  'plugins_config/conform',
  'plugins_config/gitsigns',
  'plugins_config/harpoon',
  'plugins_config/indent_line',
  'plugins_config/lint',
  'plugins_config/lsp',
  'plugins_config/mini',
  'plugins_config/telescope',
  'plugins_config/tree-sitter',
  'plugins_config/vim-fugitive',
  'plugins_config/which-key',
  'plugins_config/worktree',
}

local function pushFailure(failures, message)
  failures[#failures + 1] = message
end

local function expect(failures, condition, message)
  if not condition then
    pushFailure(failures, message)
  end
end

local function safeRequire(failures, moduleName)
  local ok, result = pcall(require, moduleName)
  if not ok then
    pushFailure(failures, string.format("require('%s') failed: %s", moduleName, result))
    return nil
  end
  return result
end

local function isPluginTarget(spec)
  return (type(spec[1]) == 'string' and spec[1] ~= '') or (type(spec.import) == 'string' and spec.import ~= '')
end

local function isPluginSpecList(spec)
  return type(spec[1]) == 'table'
end

local function validatePluginSpec(failures, moduleName)
  local spec = safeRequire(failures, moduleName)
  if type(spec) ~= 'table' then
    pushFailure(failures, string.format("module '%s' did not return a table plugin spec", moduleName))
    return
  end

  if isPluginTarget(spec) then
    return
  end

  if isPluginSpecList(spec) then
    expect(failures, #spec > 0, string.format("plugin spec list '%s' is empty", moduleName))
    for index, childSpec in ipairs(spec) do
      expect(
        failures,
        type(childSpec) == 'table' and isPluginTarget(childSpec),
        string.format("plugin spec list '%s' has an invalid entry at index %d", moduleName, index)
      )
    end
    return
  end

  pushFailure(failures, string.format("plugin spec '%s' is missing a repository or import target", moduleName))
end

function M.run()
  local failures = {}

  expect(failures, vim.g.mapleader == ' ', 'mapleader was not initialized to <space>')

  local lazyConfig = safeRequire(failures, 'lazy.core.config')
  if lazyConfig then
    expect(failures, type(lazyConfig.plugins) == 'table' and next(lazyConfig.plugins) ~= nil, 'lazy did not register any plugins')
  end

  for _, moduleName in ipairs(coreModules) do
    safeRequire(failures, moduleName)
  end

  local health = safeRequire(failures, 'plugins_config/health')
  if health then
    expect(failures, type(health.check) == 'function', "health module does not expose a 'check' function")
  end

  local healthTests = safeRequire(failures, 'tests.health_config')
  if healthTests then
    local ok, err = pcall(healthTests.run)
    expect(failures, ok, string.format("health config tests failed: %s", err))
  end

  local treeSitterTests = safeRequire(failures, 'tests.tree_sitter_config')
  if treeSitterTests then
    local ok, err = pcall(treeSitterTests.run)
    expect(failures, ok, string.format("tree-sitter config tests failed: %s", err))
  end

  local aiTests = safeRequire(failures, 'tests.ai_config')
  if aiTests then
    local ok, err = pcall(aiTests.run)
    expect(failures, ok, string.format("ai config tests failed: %s", err))
  end

  for _, moduleName in ipairs(pluginSpecModules) do
    validatePluginSpec(failures, moduleName)
  end

  if #failures > 0 then
    vim.api.nvim_err_writeln('Test failures:')
    for _, failure in ipairs(failures) do
      vim.api.nvim_err_writeln('- ' .. failure)
    end
    vim.cmd('cquit ' .. #failures)
    return
  end

  print(string.format('All tests passed (%d core modules, %d plugin specs)', #coreModules, #pluginSpecModules))
end

return M
