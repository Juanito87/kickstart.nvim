return {
  'CRAG666/code_runner.nvim',
  config = function()
    require('code_runner').setup {
      filetype = {
        python = 'python3 -u',
        typescript = 'deno run',
        rust = {
          'cd $dir &&',
          'rustc $fileName &&',
          '$dir/$fileNameWithoutExt',
        },
      },
    }
  end,
  event = 'VeryLazy', -- or "BufEnter" if we want to load sooner.
}
