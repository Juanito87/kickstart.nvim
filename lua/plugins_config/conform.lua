return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  lazy = false,
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      -- Conform can also run multiple formatters sequentially
      python = { 'isort', 'black' },
      yaml = { 'yamlfix' },
      go = { 'gofmt' },
      rust = { 'rustfmt' },
      toml = { 'taplo' },
      jinja2 = { 'djlint' },
      javascript = { 'prettierd', 'prettier' },
      bash = { 'beautysh', 'shellcheck' },
      terraform = { 'terraform_fmt' },
      ansible = { 'ansible-lint' },
      hcl = { 'hcl' },
      markdown = { 'markdownlint' },
      -- You can use a sub-list to tell conform to run *until* a formatter
      -- is found.
    },
  },
}
