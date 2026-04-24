return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  branch = 'main',
  build = ':TSUpdate',
  config = function()
    local parsers = {
      'bash', 'c', 'diff', 'dockerfile', 'go', 'html', 'javascript', 'json',
      'lua', 'luadoc', 'make', 'markdown', 'markdown_inline', 'python',
      'query', 'regex', 'rust', 'toml', 'typescript', 'vim', 'vimdoc', 'yaml',
    }

    local parser_install_dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'site')

    require('nvim-treesitter').setup({ install_dir = parser_install_dir })

    -- Install missing parsers asynchronously on first load.
    require('nvim-treesitter').install(parsers)

    Autocmd('FileType', {
      callback = function(args)
        local buf, filetype = args.buf, args.match
        local language = vim.treesitter.language.get_lang(filetype)
        if not language then return end
        if not vim.treesitter.language.add(language) then return end

        vim.treesitter.start(buf, language)
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
