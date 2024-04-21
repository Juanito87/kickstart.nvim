-- [[ Options  ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Set numbers and relativenumber
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Set indent
-- vim.opt.tabstop = 4
-- vim.opt.softtabstop = 4
-- vim.opt.shiftwidth = 4
vim.opt.wrap = true
vim.opt.breakindent = true -- keeps text indented after wrap line
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Save undo history and specify path to it.
vim.opt.undofile = true
vim.opt.undodir = os.getenv 'HOME' .. '/.nvim/undodir'

-- Don't create swap or backup, we have undo for it
vim.opt.swapfile = false
vim.opt.backup = false

-- Set highlight and navigation
vim.opt.hlsearch = true -- Highlight partial search
vim.opt.incsearch = true -- Incremental search to highlight partial matches
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes' -- Keep signcolumn on by default
vim.opt.inccommand = 'split' -- Preview substitutions live, as you type!

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 20

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Show which line your cursor is on
vim.opt.cursorline = true
--
-- set netrw config
vim.g.netrw_banner = 0 -- Remove banner at the top
vim.g.netrw_liststyle = 3 -- Default directory view. Cycle with i
vim.g.netrw_altv = 1 -- Files are opened to the right of netrw
vim.g.netrw_chgwin = -1 -- Files are opened in the netrw window
vim.g.netrw_winsize = 25 -- Window size
vim.g.netrw_list_hide = '.*.swp$, *.pyc$,  *.log$,  *.o$,  *.xmi$,  *.swp$,  *.bak$,  *.pyc$,  *.class$,  *.jar$,  *.war$,  *__pycache__*' -- Hide files with this extensions
