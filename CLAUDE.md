# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Modular Neovim configuration built on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), using **lazy.nvim** for plugin management. All configuration is written in Lua.

## Commands

### Formatting
- **Check**: `stylua --check lua/` (run from repo root)
- **Fix**: `stylua lua/`
- **Config**: `.stylua.toml` — 160-char width, 2-space indent, single quotes, no call parens
- **In-editor**: `<leader>f` (runs conform.nvim)

### Linting
- **Markdown**: `markdownlint-cli <file>.md`
- **In-editor**: `:lua require('lint').try_lint()`

### Health Checks
- `:checkhealth` — Comprehensive Neovim/plugin diagnostics
- `:Lazy` — Plugin status, update, clean, profile

### CI
GitHub Actions (`.github/workflows/stylua.yml`) checks Lua formatting on all PRs against `main`.

## Architecture

### Entry Point
`init.lua` sets `<space>` as leader, defines global helpers (`Autocmd`, `Augroup`, `Fugitive`), then requires:
1. `lua/lazy-install.lua` — bootstraps lazy.nvim if absent
2. `lua/lazy-config.lua` — all plugin specs
3. `lua/options.lua` — vim options
4. `lua/keymaps.lua` — keybindings
5. `lua/autocommands.lua` — autocommands

### Plugin Configuration
All plugins are declared in `lua/lazy-config.lua`. Complex plugin setups are extracted to `lua/plugins_config/<plugin>.lua` and referenced via `config = function() require('plugins_config.<name>') end`.

New plugins should follow this pattern:
```lua
return {
  'author/plugin-name',
  event = 'VimEnter',           -- lazy loading trigger
  dependencies = { 'dep1' },
  opts = { setting = value },   -- simple options (no setup() call needed)
  config = function()           -- complex setup
    require('plugin').setup({ config })
  end,
  keys = {
    { '<leader>key', function() end, desc = 'Description' },
  },
}
```

Disabled/experimental plugins live in `lua/plugins_config/disabled/`.

User customizations go in `lua/custom/plugins/init.lua`.

### Key Plugin Groups
- **LSP**: `lsp.lua` — mason.nvim + mason-lspconfig + nvim-lspconfig; install servers with `:Mason`
- **Completion**: `autocomplete.lua` — blink.cmp with LuaSnip
- **Fuzzy finding**: `telescope.lua` — `<leader>s*` bindings
- **Formatting**: `conform.lua` — stylua, prettier, gofmt, black, rustfmt, etc.
- **AI**: `copilot.lua` + `copilot-chat.lua` — inline completions + chat (`<leader>a*`)
- **Git**: `vim-fugitive.lua` + `gitsigns.lua` + `worktree.lua`

## Code Style

### Naming
- Variables/functions: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- Module files: `snake_case`

### Patterns
```lua
-- Safe plugin loading
local ok, plugin = pcall(require, 'plugin.name')
if not ok then vim.notify('Plugin failed: ' .. plugin, vim.log.levels.WARN) return end

-- Keymaps always include desc
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })

-- Autocommands use descriptive augroup names
local augroup = vim.api.nvim_create_augroup('plugin-name-feature', { clear = true })
```

- Prefer `vim.api.nvim_*` over deprecated `vim.*` APIs
- EmmyLua annotations (`---@param`, `---@return`) for documented functions
- Keymaps: use `<leader>` prefix; group related mappings under common prefixes (see which-key groups in `keymaps.lua`)
