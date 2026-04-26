local M = {}

local function fail(message) error(message, 0) end

local function expect(condition, message)
  if not condition then fail(message) end
end

local function clear_modules()
  package.loaded['plugins_config.tree-sitter'] = nil
  package.loaded['nvim-treesitter'] = nil
  package.loaded['nvim-treesitter.configs'] = nil
  package.loaded['nvim-treesitter.install'] = nil
  package.preload['nvim-treesitter'] = nil
  package.preload['nvim-treesitter.configs'] = nil
  package.preload['nvim-treesitter.install'] = nil
end

local function stub_runtime()
  _G.Autocmd = function(_, opts) expect(type(opts) == 'table' and type(opts.callback) == 'function', 'tree-sitter autocommand callback missing') end

  vim.treesitter = vim.treesitter or {}
  vim.treesitter.language = vim.treesitter.language or {}
  vim.treesitter.language.get_lang = function(filetype) return filetype end
  vim.treesitter.language.add = function() return true end
  vim.treesitter.start = function() end
end

local function set_headless(enabled)
  vim.api.nvim_list_uis = function()
    if enabled then return {} end

    return { { chan = 1 } }
  end
end

local function run_master_shape()
  clear_modules()
  set_headless(false)

  local calls = {
    setup = nil,
    ensure_installed = nil,
  }

  package.preload['nvim-treesitter.configs'] = function()
    return {
      setup = function(opts) calls.setup = opts end,
    }
  end

  package.preload['nvim-treesitter.install'] = function()
    return {
      ensure_installed = function(parsers) calls.ensure_installed = parsers end,
    }
  end

  local spec = require 'plugins_config.tree-sitter'
  spec.config()

  expect(type(calls.setup) == 'table', 'master tree-sitter path did not call configs.setup')
  expect(type(calls.setup.ensure_installed) == 'table', 'master tree-sitter path did not pass ensure_installed')
  expect(type(calls.ensure_installed) == 'nil', 'master tree-sitter path should not call install.ensure_installed directly')
end

local function run_main_shape()
  clear_modules()
  set_headless(false)

  local calls = {
    setup = nil,
    install = nil,
  }

  package.preload['nvim-treesitter'] = function()
    return {
      setup = function(opts) calls.setup = opts end,
      install = function(parsers) calls.install = parsers end,
    }
  end

  local spec = require 'plugins_config.tree-sitter'
  spec.config()

  expect(type(calls.setup) == 'table', 'main tree-sitter path did not call nvim-treesitter.setup')
  expect(type(calls.install) == 'table', 'main tree-sitter path did not call nvim-treesitter.install')
end

local function run_headless_master_shape()
  clear_modules()
  set_headless(true)

  local calls = {
    setup = nil,
  }

  package.preload['nvim-treesitter.configs'] = function()
    return {
      setup = function(opts) calls.setup = opts end,
    }
  end

  package.preload['nvim-treesitter.install'] = function()
    return {
      ensure_installed = function() fail 'headless tree-sitter path should not auto-install parsers' end,
    }
  end

  local spec = require 'plugins_config.tree-sitter'
  spec.config()

  expect(type(calls.setup) == 'table', 'headless tree-sitter path did not call configs.setup')
  expect(calls.setup.ensure_installed == nil, 'headless tree-sitter path should skip ensure_installed')
end

function M.run()
  stub_runtime()
  run_master_shape()
  run_main_shape()
  run_headless_master_shape()
  print 'Tree-sitter config tests passed'
end

return M
