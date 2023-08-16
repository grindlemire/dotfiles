return {
  {
    "nvim-lua/plenary.nvim",
    lazy = false,
    --priority = 2000,
  },

  -- used by other plugins, needs a nerd font
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
  },

  -- treesitter playground!
  -- undotree

  {
    "twschum/nordark.nvim", -- git repo
    dev = true,
    -- dir = "nordark", -- symlink version to repo
    lazy = false,
    priority = 1000,
    config = function()
      require("nord").setup({
        transparent = false,      -- Enable this to disable setting the background color
        terminal_colors = true,   -- Configure the colors used when opening a `:terminal` in Neovim
        diff = { mode = "fg" },   -- enables/disables colorful backgrounds when used in diff mode. values : [bg|fg]
        borders = true,           -- Enable the border between verticaly split windows visible
        errors = { mode = "fg" }, -- Display mode for errors and diagnostics
        -- values : [bg|fg|none]
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = false },
          keywords = {},
          functions = {},
          variables = {},
          errors = { undercurl = true },
          -- To customize lualine/bufferline
          bufferline = {
            current = {},
            modified = { italic = true },
          },
        },
      })
      vim.cmd([[colorscheme nordark]])
    end,
  },

  -- collection of colorschemes
  --'christianchiarulli/nvcode-color-schemes.vim',

  -- colorizer highlights hex and RGB codes inline
  {
    "norcalli/nvim-colorizer.lua",
    lazy = false,
    config = function()
      require("colorizer").setup({
        user_default_options = {
          names = false,
        },
      })
    end,
  },

  -- Useful plugin to show you pending keybinds.
  {
    "folke/which-key.nvim",
    keys = "<leader>",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 400
      require("which-key").setup({
        opts = {
          icons = {
            breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
            separator = "  ", -- symbol used between a key and it's label
            group = "+",       -- symbol prepended to a group
          },
          popup_mappings = {
            scroll_down = "<c-d>", -- binding to scroll down inside the popup
            scroll_up = "<c-u>",   -- binding to scroll up inside the popup
          },
          window = {
            border = "rounded", -- none/single/double/shadow
          },
          layout = {
            spacing = 6, -- spacing between columns
          },
          hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
          triggers_blacklist = {
            -- list of mode / prefixes that should never be hooked by WhichKey
            i = { "j", "k" },
            v = { "j", "k" },
          },
        },
      })

      vim.keymap.set("n", "<leader>wk", function()
        vim.cmd("WhichKey")
      end, { desc = "which-key all keymaps" })
      vim.keymap.set("n", "<leader>wK", function()
        local input = vim.fn.input("WhichKey: ")
        vim.cmd("WhichKey " .. input)
      end, { desc = "which-key query lookups" })
    end,
  },

  -- Modify surrounding "'{[(<tag></tag>)]}'"
  { "tpope/vim-surround", lazy = false },
  { "tpope/vim-repeat",   lazy = false },
  -- { 'twschum/argtextobj.vim', lazy = false }, covered by treesitter-textobj
  -- { "FooSoft/vim-argwrap" },

  {
    "AckslD/nvim-trevJ.lua",
    lazy = false,
    --keys = { "<leader>" },
    config = function()
      require("trevj").setup()
      vim.keymap.set('n', "<leader>aa", require("trevj").format_at_cursor, { desc = "format args" })
    end,
  },

  {
    "aarondiel/spread.nvim",
    lazy = false,
    dependencies = { "nvim-treesitter" },
    config = function()
      local spread = require("spread")
      vim.keymap.set("n", "<leader>as", spread.out, { desc = "spread args" })
      vim.keymap.set("n", "<leader>ac", spread.combine, { desc = "(spread) combine args" })
    end
  },

  {
    "numToStr/Comment.nvim",
    keys = { "<leader>/" },
    init = function()
      vim.keymap.set("n", "<leader>/", function()
        require("Comment.api").toggle.linewise.current()
      end, { desc = "toggle comment" })
      vim.keymap.set("v", "<leader>/", function()
        require("Comment.api").toggle.linewise(vim.fn.visualmode())
      end, { desc = "toggle comment" })
    end,
    config = function()
      require("Comment").setup({
        mappings = {
          basic = false,
          extra = false,
        },
      })
    end,
  },

  {
    "johmsalas/text-case.nvim",
    lazy = false,
    init = function()
      local prefix = "<leader>c"
      require('textcase').setup({
        prefix = prefix
      })
      local tc = require('textcase')
      -- for some reason, snake case isn't in the presets!
      tc.register_keybindings(prefix, tc.api.to_snake_case,
        {
          prefix = prefix,
          quick_replace = 's',
          operator = 'os',
          lsp_rename = 'S',
        }
      )
    end,
  },
  -- https://github.com/gbprod/substitute.nvim
}
