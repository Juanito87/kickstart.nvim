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
    { '<leader>tf', '<cmd>FormatToggle<cr>', desc = '[T]oggle [F]ormat-on-save' },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Manual override: :FormatDisable[!] / :FormatEnable / <leader>tf
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return nil
      end
      -- Never rewrite generated/locked files.
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name:match '%.terraform%.lock%.hcl$' then
        return nil
      end
      -- Languages without a well standardized coding style: skip on save.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      end
      return {
        timeout_ms = 500,
        lsp_format = 'fallback',
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      -- yaml: yamlfmt instead of yamlfix — lighter touch (2-space, keeps quotes/line breaks)
      yaml = { 'yamlfmt' },
      -- ansible YAML: use ansible-lint --fix so it respects the repo's .ansible-lint profile
      -- instead of running through yamlfmt and doing a second unrelated reformat pass
      ['yaml.ansible'] = { 'ansible-lint' },
      ansible = { 'ansible-lint' },
      go = { 'gofmt' },
      rust = { 'rustfmt' },
      toml = { 'taplo' },
      jinja2 = { 'djlint' },
      javascript = { 'prettierd', 'prettier' },
      -- sh filetype (most shell scripts) was previously uncovered
      sh = { 'beautysh' },
      -- shellcheck is a linter not a formatter — it lives in nvim-lint/none-ls
      bash = { 'beautysh' },
      -- tofu fmt matches the rpcpool/terraform toolchain (tofu fmt == terraform fmt output)
      terraform = { 'tofu_fmt' },
      ['terraform-vars'] = { 'tofu_fmt' },
      -- nomad_fmt (nomad fmt -) replaces the broken 'hcl' entry (hclfmt binary was missing)
      hcl = { 'nomad_fmt' },
      markdown = { 'markdownlint' },
    },
    formatters = {
      -- Light, low-churn YAML: 2-space, sequences indented, preserve quotes and existing
      -- line breaks. include_document_start keeps the leading --- on files that have it.
      -- Matches the infra repos' de-facto style without heavy reflow.
      yamlfmt = {
        prepend_args = {
          '-formatter',
          'indent=2,retain_line_breaks_single=true,scan_folded_as_literal=true,trim_trailing_whitespace=true,include_document_start=true',
        },
      },
    },
  },
  init = function()
    -- :FormatDisable    -> turn off autoformat globally
    -- :FormatDisable!   -> turn off autoformat for the current buffer only
    --                      (skip reformatting THIS file on the next save)
    vim.api.nvim_create_user_command('FormatDisable', function(args)
      if args.bang then
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, { desc = 'Disable autoformat-on-save', bang = true })

    vim.api.nvim_create_user_command('FormatEnable', function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, { desc = 'Re-enable autoformat-on-save' })

    vim.api.nvim_create_user_command('FormatToggle', function()
      vim.g.disable_autoformat = not vim.g.disable_autoformat
      vim.notify('Format-on-save ' .. (vim.g.disable_autoformat and 'disabled' or 'enabled'))
    end, { desc = 'Toggle autoformat-on-save' })
  end,
}
