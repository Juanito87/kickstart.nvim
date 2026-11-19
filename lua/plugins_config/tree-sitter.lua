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

    require('nvim-treesitter').setup { install_dir = parser_install_dir }

    -- Install missing parsers asynchronously on first load.
    require('nvim-treesitter').install(parsers)

    ---@param buf integer
    ---@param language string
    local function treesitterTryAttach(buf, language)
      -- The buffer may be gone by the time an async install completes
      if not vim.api.nvim_buf_is_valid(buf) then return end
      if not vim.treesitter.language.add(language) then return end

      vim.treesitter.start(buf, language)

      -- Only use treesitter indentation when the language has an indent query
      if vim.treesitter.query.get(language, 'indents') ~= nil then vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
    end

    local availableParsers = require('nvim-treesitter').get_available()
    Autocmd('FileType', {
      callback = function(args)
        local buf, filetype = args.buf, args.match
        local language = vim.treesitter.language.get_lang(filetype)
        if not language then return end

        local installedParsers = require('nvim-treesitter').get_installed 'parsers'
        if vim.tbl_contains(installedParsers, language) then
          treesitterTryAttach(buf, language)
        elseif vim.tbl_contains(availableParsers, language) then
          -- Auto-install the parser, then attach when it finishes
          require('nvim-treesitter').install(language):await(function() treesitterTryAttach(buf, language) end)
        else
          treesitterTryAttach(buf, language)
        end
      end,
    })
  end,
}
