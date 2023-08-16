-- --[[
-- Lua ref: https://learnxinyminutes.com/docs/lua/

-- Neovim lua API:
-- vim.opt is equivalent to set
-- vim.g for let g:
-- vim.fn is a table of functions. Can refer to using vim.fn.myFunc or vim.fn["myFunc"]
-- vim.api for the neovim api

-- UNDERCURL WITH COLOR
-- https://ryantravitz.com/blog/2023-02-18-pull-of-the-undercurl/

-- TODO:
-- - [] Ripgrep args?

-- ]]
-- -------------------------------------- globals -----------------------------------------
-- -- have an initial colorscheme
vim.opt.termguicolors = true
vim.cmd.colorscheme("nordark_bootstrap")

-- -- Set <space> as the leader key
-- -- See :help mapleader
-- -- before lazy so plugin mappings are correct
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
-- -- set before nvim-cmp gets setup
-- vim.opt.completeopt = { "menu", "menuone", "preview" }

-- -- Disable language providers that aren't needed
-- vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- -------------------------------------- options ------------------------------------------
-- vim.opt.mouse = "" -- no mouse in this house

-- -- UI Config
vim.opt.number = false          -- show line numbers
vim.opt.relativenumber = false -- show relative line numbers
vim.opt.cursorline = true      -- highlight current line
vim.opt.showmatch = true       -- highlight matching [{()}]
vim.opt.scrolloff = 8

vim.opt.laststatus = 3 -- sets a global status line instead of each window (lualine)

vim.opt.errorbells = false
vim.opt.visualbell = false
--vim.opt.fillchars:append { 'vert:―' }

-- change default :sh command shell to brew's zsh
-- set shell=/usr/local/bin/zsh
-- use the mac default zsh
vim.opt.shell = "/bin/zsh"

-- -- adds I to disable splash, since lualine's redraw is causing flicker
vim.opt.shortmess = "filnxtToOFI"

-- -- change default split orientation to maintain current
-- vim.opt.splitright = true
-- vim.opt.splitbelow = true
-- --vim.opt.signcolumn = "auto:1-3"
-- vim.opt.signcolumn = "yes"
-- --vim.opt.colorcolumn = "-1" -- relative to textwidth

-- -- Searching
vim.opt.incsearch = true  -- search as characters are entered
vim.opt.ignorecase = true -- case insensitive searching
vim.opt.smartcase = true  -- case sensitive if not all lower case

-- Spaces and tabs - defaults regardless of tiletype
vim.opt.expandtab = true           -- tabs are spaces
vim.opt.tabstop = 4                -- number of visual spaces per TAB
vim.opt.softtabstop = 4            -- number of spaces in tab when editing
vim.opt.shiftwidth = 4             -- sets width of auto-indented tabs
vim.opt.backspace = "indent,start" -- only backspace auto indenting
-- vim.opt.listchars = { tab = "» ", trail = "·", precedes = "·" }
-- vim.opt.list = true
-- -- vim.opt.fillchars = {
-- --     horiz     = "─",
-- --     horizup   = "┴",
-- --     horizdown = '┬',
-- --     vert      = '│',
-- --     vertleft  = '┤',
-- --     vertright = '├',
-- --     verthoriz = '┼',
-- --     fold      = '·',
-- --     foldopen  = '-',
-- --     foldclose = '+',
-- --     foldsep   = '│',
-- --     diff      = '-',
-- --     msgsep    = ' ',
-- --     eob       = '~',
-- --     -- lastline  = '@',
-- -- -- }
-- --vim.keymap.set('n',  '<leader>l', ':set list!<CR>') -- toggle list mode

-- Formatting (wrap lines sensibly)
-- --set wrap linebreak
-- vim.opt.textwidth = 101 -- my default, but filetypes will change it

-- -- netrw - the builtin file browser
-- vim.opt.wildignore = "*.swp,*.bak,*.pyc,*.class" -- ignore when tabcompleting files
-- vim.g.netrw_liststyle = 1                        -- tree view, cycle with i
-- vim.g.netrw_banner = 0                           -- the banner is mostly useless, toggle with I
-- vim.g.netrw_winsize = 25                         -- 25% width on open

-- -------------------------------------- mappings - core -----------------------------------
-- -- Essential core keymaps
-- -- use jk for escape
-- vim.keymap.set("i", "jk", "<Esc>")

-- -- move display lines when wrapped
-- vim.keymap.set("n", "j", "gj")
-- vim.keymap.set("n", "k", "gk")

-- -- Editing shortcuts
-- vim.keymap.set("n", "<leader>d", "^d$")
vim.keymap.set("n", "<leader>p", "$p")
vim.keymap.set("n", "<leader>P", "^P")
-- vim.keymap.set("n", "<leader>b", "^")
-- vim.keymap.set("n", "<leader>e", "$")
vim.keymap.set("n", "<leader>y", "y$")
vim.keymap.del("n", "Y") -- remove default mapping

-- -- Easy window split navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
-- -- turns off search highlighting with <Esc>
-- vim.keymap.set("n", "<Esc>", "<cmd>nohls<CR>", { silent = true, desc = "clear search highlight" })

-- -------------------------------------- mappings - util -----------------------------------
-- --vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>") -- git blame
-- --vim.keymap.set('n', '<leader>ga', '<cmd>w<bar>silent Git add %<cr>') -- git add

-- -- macro to copy the current line and file to a GH link
-- vim.keymap.set(
--   "n",
--   "<leader>gk",
--   "<cmd>call setreg('*', 'https://github.com/<repo_name>' . expand('%') . '#L' . line('.'))<CR>",
--   { desc = "copy github link to clipboard" }
-- )
-- -- copy the filename to the unnamed register
-- -- map <leader>cf :let @" = expand("%")<CR>

-- -- move lines around in visual mode with J and K
-- vim.keymap.set("v", "K", "<cmd>m '>-2<cr>gv=gv")
-- vim.keymap.set("v", "J", "<cmd>m '>+1<cr>gv=gv")

-- -- leave cursor where it is when using Join lines - kinda janky with lsp stuff
-- -- vim.keymap.set("n", "J", "mzJ`z")

-- -- center cursor on half-page jumps
-- vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- -- make word change case
-- vim.keymap.set("n", "<leader>U", "lbveU<ESC>")
-- vim.keymap.set("n", "<leader>u", "lbveu<ESC>")

-- -- align visual selection as a table
-- vim.keymap.set("v", "<leader>t", ":%!column -t <bar> sed 's/\\( *\\) /\\1/g'<esc>", { desc = "table align selected" })

-- -- Spellcheck shortcuts
-- --vim.keymap.set('n', '<leader>s', '<cmd>setlocal spell spelllang=en_us<CR>')
-- --vim.keymap.set('n', '<leader>S', '<cmd>setlocal nospell<CR>')

-- -- replace current word under cursor TODO maybe s instead? (substitue)
-- vim.keymap.set("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
--   { desc = "replace word under cursor" })
-- -- replace "spaces in string" to "spaces_in_string"
-- vim.keymap.set("v", "<leader>r<space>", [[<cmd>s/\%V /_/g<cr>]], { desc = [[replace spaces in "string" with _]] })

-- -- modify current file to be executible - TODO as a user func
-- -- vim.api.nvim_create_user_command
-- -- vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- -------------------------------------- autocmds -----------------------------------------
require("autocmds")

-- -------------------------------------- plugins ------------------------------------------
require("load_lazy")
