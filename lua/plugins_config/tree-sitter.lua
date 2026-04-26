return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  branch = 'main',
  build = ':TSUpdate',
  config = function()
    local parsers = {
      'bash',
      'c',
      'diff',
      'dockerfile',
      'go',
      'html',
      'javascript',
      'json',
      'lua',
      'luadoc',
      'make',
      'markdown',
      'markdown_inline',
      'python',
      'query',
      'regex',
      'rust',
      'toml',
      'typescript',
      'vim',
      'vimdoc',
      'yaml',
    }

    local parser_install_dir = vim.fs.joinpath(vim.fn.stdpath 'data', 'site')
    local should_install = #vim.api.nvim_list_uis() > 0
    local has_configs, configs = pcall(require, 'nvim-treesitter.configs')
    local has_install, install = pcall(require, 'nvim-treesitter.install')
    local has_treesitter, treesitter = pcall(require, 'nvim-treesitter')

    if has_configs and type(configs.setup) == 'function' then
      local opts = {
        parser_install_dir = parser_install_dir,
      }
      if should_install then opts.ensure_installed = parsers end

      configs.setup(opts)
    elseif has_treesitter and type(treesitter.setup) == 'function' then
      treesitter.setup { install_dir = parser_install_dir }

      -- Older main-branch layouts exposed parser installation on the root module.
      if should_install and type(treesitter.install) == 'function' then
        treesitter.install(parsers)
      elseif should_install and has_install and type(install.ensure_installed) == 'function' then
        install.ensure_installed(parsers)
      end
    else
      vim.notify('Unable to configure nvim-treesitter: unsupported API shape', vim.log.levels.WARN)
      return
    end

    Autocmd('FileType', {
      callback = function(args)
        local buf, filetype = args.buf, args.match
        local language = vim.treesitter.language.get_lang(filetype)
        if not language then return end

        local ok = pcall(vim.treesitter.language.add, language)
        if not ok then return end

        vim.treesitter.start(buf, language)
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
