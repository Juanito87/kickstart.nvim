-- [[ oions  ]]
-- See `:help vim.o`
-- NOTE: You can change these oions as you wish!
--  For more oions, you can see `:help option-list`

-- Set numbers and relativenumber
vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.schedule(function()
--   vim.o.clipboard = 'unnamedplus'
-- end)

-- Set indent currently managed by a plugin.
-- vim.o.tabstop = 4
-- vim.o.softtabstop = 4
-- vim.o.shiftwidth = 4
vim.o.wrap = true -- wrap text after textwidth is reached
vim.o.breakindent = true -- keeps text indented after wrap line
vim.o.expandtab = true -- put the amount of spaces each time tab is used
vim.o.smartindent = true -- autodetect indent when starting a newline

-- Save undo history and specify path to it.
vim.o.undofile = true
vim.o.undodir = os.getenv 'HOME' .. '/.nvim/undodir'

-- Don't create swap or backup, we have undo for it
vim.o.swapfile = false
vim.o.backup = false

-- Set highlight and navigation
vim.o.hlsearch = true -- Highlight partial search
vim.o.incsearch = true -- Incremental search to highlight partial matches
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes' -- Keep signcolumn on by default
vim.o.inccommand = 'split' -- Preview substitutions live, as you type!

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 20

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.o.list = true
vim.o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Show which line your cursor is on
vim.o.cursorline = true

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- set netrw config
vim.g.netrw_banner = 0 -- Remove banner at the top
vim.g.netrw_liststyle = 3 -- Default directory view. Cycle with i
vim.g.netrw_altv = 1 -- Files are opened to the right of netrw
vim.g.netrw_chgwin = -1 -- Files are opened in the netrw window
vim.g.netrw_winsize = 25 -- Window size
vim.g.netrw_list_hide = '.*.swp$, *.pyc$,  *.log$,  *.o$,  *.xmi$,  *.swp$,  *.bak$,  *.pyc$,  *.class$,  *.jar$,  *.war$,  *__pycache__*' -- Hide files with this extensions
