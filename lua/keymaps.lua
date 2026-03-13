-- [[ Basic Keymaps ]]
-- NOTE: See `:help vim.keymap.set()`
-- vim.keymap.set(<mode/s> required, <keymap> required, <command> required, <optoins> not required)

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Remove higlight after search is done' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function() vim.diagnostic.goto({ direction = 'prev', float = false }) end, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', function() vim.diagnostic.goto({ direction = 'next', float = false }) end, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- netrw remaps
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex, { desc = 'Open netrw' }) -- open netrw

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- TIP: Disable arrow keys in normal mode, i don use them
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  NOTE: Use CTRL+<hjkl> to switch between windows
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- copy pasting
vim.keymap.set('n', 'Y', 'y$', { desc = 'Yank till the end of the line' })
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Marks the point (mz), joins the lines (J) and gets back to the marked place (`z)' })
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Prefix y with leader to send to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>Y', '"+Y', { desc = 'Prefix Y with leader to send to system clipboard' })
vim.keymap.set('x', '<leader>p', '"+p', { desc = 'Paste from clipboard over the selection, without chaging the clipboard registry("+).' })
vim.keymap.set('x', '<leader>P', '"_dP', { desc = 'Deletes to void registry("_) to avoid changing registry("0) content, and then pastes from clipboard' })

-- Search remaps
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'n = next search, zz = center cursor on screen, zv = open fold if exist' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'N = previous search, zz = center cursor on screen, zv = open fold if exist' })

-- Add additional undo breakpoints on these simbols, makes undo more granular
vim.keymap.set('i', ',', ',<c-g>u', { desc = 'Add undo breakpoint on a ,' })
vim.keymap.set('i', '.', '.<c-g>u', { desc = 'Add undo breakpoint on a .' })
vim.keymap.set('i', '!', '!<c-g>u', { desc = 'Add undo breakpoint on a !' })
vim.keymap.set('i', '?', '?<c-g>u', { desc = 'Add undo breakpoint on a ?' })

-- Moving text around
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down in visual mode' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up in visual mode' })
vim.keymap.set('i', '<C-k>', '<esc>:m .-2<CR>==', { desc = 'Move line up in insert mode' })
vim.keymap.set('i', '<C-j>', '<esc>:m .+1<CR>==', { desc = 'Move line down in insert mode' })
vim.keymap.set('n', '<leader>j', ':m .+1<CR>==', { desc = 'Move line up in in normal mode' })
vim.keymap.set('n', '<leader>k', ':m .-2<CR>==', { desc = 'Move line down in in normal mode' })

-- Window management
vim.keymap.set('n', '<C-C>', '<C-W><C-C>', { desc = 'Close window with ctrl+c' })

-- Save file
vim.keymap.set({ 'i', 'v', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })

-- Function and remap to toggle relative numbers.
vim.keymap.set('n', '<leader>nr', function() vim.o.nu = false vim.opt.relativenumber = false end, { desc = 'Disable number and relative number' })
vim.keymap.set('n', '<leader>rn', function() vim.o.nu = true vim.opt.relativenumber = true end, { desc = 'Enable number and relative number' })

-- Clean up
vim.keymap.set('n', '<leader>dw', ':%s/\\s\\+$//e<CR>', { desc = 'Clean trailing whitespace in the document' })
vim.keymap.set('n', '<leader>dn', ':%s/\\n\\+\\%$//e<CR>', { desc = 'Clean trailing newlines in the document' })
vim.keymap.set('n', '<leader>ds', ':%s/\\^\\[\\+\\%$//e<CR>', { desc = 'Clean trailing escape sequences in the document' })

-- Code runner keymaps
vim.keymap.set('n', '<leader>rr', ':RunCode<CR>', { noremap = true, silent = false, desc = 'Run code based on file type.' })
vim.keymap.set('n', '<leader>rf', ':RunFile<CR>', { noremap = true, silent = false, desc = 'Run code in current file.'  })
vim.keymap.set('n', '<leader>rft', ':RunFile tab<CR>', { noremap = true, silent = false, desc = 'Run code in current file on a tab.'  })
vim.keymap.set('n', '<leader>rp', ':RunProject<CR>', { noremap = true, silent = false, desc = 'Run code in project.'  })
vim.keymap.set('n', '<leader>rc', ':RunClose<CR>', { noremap = true, silent = false, desc = 'Close runner.'  })
vim.keymap.set('n', '<leader>crf', ':CRFiletype<CR>', { noremap = true, silent = false, desc = 'Open json with supported files.'  })
vim.keymap.set('n', '<leader>crp', ':CRProjects<CR>', { noremap = true, silent = false, desc = 'Open json with list of projects.'  })

-- Testing remaps and functions

-- better indenting
-- vim.keymap.set('v', '<', '<gv')
-- vim.keymap.set('v', '>', '>gv')

-- Markdown preview haven't setup this plugin
-- vim.keymap.set('n', '<leader>mp', ':Glow<CR>', { desc = 'Remap glow to show markdown preview' })
-- vim.keymap.set('n', '<leader>mq', ':Glow!<CR>', { desc = 'Remap glow to close markdown preview' })
