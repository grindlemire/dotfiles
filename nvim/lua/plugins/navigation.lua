-- navigation.lua - switching between files/projects, searching, etc.
--
-- FZF for telescope; very fast, in C, supports FZF syntax
-- Token   Match type                   Description
-- sbtrkt  fuzzy-match                  Items that match sbtrkt
-- 'wild   exact-match (quoted)         Items that include wild
-- ^music  prefix-exact-match           Items that start with music
-- .mp3$   suffix-exact-match           Items that end with .mp3
-- !fire   inverse-exact-match          Items that do not include fire
-- !^music inverse-prefix-exact-match   Items that do not start with music
-- !.mp3$  inverse-suffix-exact-match   Items that do not end with .mp3
-- add telescope-fzf-native
local common = require("common")

local function is_git_repo()
  vim.fn.system("git rev-parse --is-inside-work-tree")
  return vim.v.shell_error == 0
end

local function get_git_root()
  local dot_git_path = vim.fn.finddir(".git", ".;")
  return vim.fn.fnamemodify(dot_git_path, ":h")
end

local function find_or_git_files(builtin)
  return function()
    if is_git_repo() then
      builtin.git_files()
    else
      builtin.find_files()
    end
  end
end

local function live_grep_from_git_root(builtin)
  return function()
    local opts = {}
    if is_git_repo() then
      opts = {
        cwd = get_git_root(),
      }
    end
    -- use customized grep with keybind for chaning the directory
    builtin.live_grep(opts)
  end
end

-- live grep using Telescope inside the current directory under
-- the cursor (or the parent directory of the current file)
local function grep_in()
  local node = require('nvim-tree.api').tree.get_node_under_cursor()
  if not node then
    print("no node")
    return
  end
  local path = node.absolute_path or vim.loop.cwd()
  if node.type ~= 'directory' and node.parent then
    path = node.parent.absolute_path
  end
  require('telescope.builtin').live_grep({
    search_dirs = { path },
    prompt_title = string.format('Grep in [%s]', vim.fs.basename(path)),
  })
end

-- for nvim-tree mappings
local function on_attach_tree(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- load default mappings, can remove any with vim.keymap.del
  api.config.mappings.default_on_attach(bufnr)

  -- my keymaps
  vim.keymap.set("n", "<C-f>", grep_in, opts("grep from current dir"))
end

return {
  -- telescope does navigation
  -- external depends: ripgrep, fd
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "smartpde/telescope-recent-files",
      "natecraddock/telescope-zf-native.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      {
        "nvim-telescope/telescope-smart-history.nvim",
        dependencies = { "kkharji/sqlite.lua" },
      },
      {
        -- https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md
        "nvim-telescope/telescope-live-grep-args.nvim",
      },
    },
    lazy = false,
    priority = 200, -- load after lsp-zero for nvim-cmp
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "-L",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "descending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "bottom",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = true,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        --file_sorter = require("telescope.sorters").get_fuzzy_file,
        file_ignore_patterns = { "node_modules" },
        --generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        path_display = {
          --shorten = { len = 3, exclude = { 1, -1 } },
          truncate = 1,
        },
        dynamic_preview_title = true,
        winblend = 0,
        border = true,
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        --file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        --grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        --qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        history = {
          -- TODO make this portable
          path = "~/.local/share/nvim/databases/telescope_history.sqlite3",
          limit = 100,
        },
      },
      extensions_list = {
        "fzf",
        "recent_files",
        "zf-native",
        "smart_history",
        "live_grep_args",
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = false,
          case_mode = "smart_case",
        },
        ["zf-native"] = {
          file = {
            -- options for sorting file-like items
            enable = true,         -- override default telescope file sorter
            highlight_results = true,
            match_filename = true, -- enable zf filename match priority
          },
          generic = {
            enable = false, -- override default telescope generic item sorter
          },
        },
        recent_files = {
          -- ignore tmp/doc files in the ShaDa
          ignore_patterns = {
            "/tmp/",
            "oil:",
            "/doc/.*%.txt",
            "^%.*$",
            ".git/COMMIT_EDITMSG",
          },
        },
        live_grep_args = {
          auto_quoting = true,
        },
      },
      pickers = {
        file_files = {
          hidden = true,
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local trouble = require("trouble.providers.telescope")
      local lga_actions = require("telescope-live-grep-args.actions")


      -- Mappings that are internal to the Telescope prompt
      opts.defaults.mappings = {
        n = {
          ["<Down>"] = actions.cycle_history_next,
          ["<Up>"] = actions.cycle_history_prev,
          ["cd"] = function(prompt_bufnr)
            local selection = require("telescope.actions.state").get_selected_entry()
            local dir = vim.fn.fnamemodify(selection.path, ":p:h")
            require("telescope.actions").close(prompt_bufnr)
            -- Depending on what you want put `cd`, `lcd`, `tcd`
            vim.cmd(string.format("silent lcd %s", dir))
          end,
          ["<C-f>"] = trouble.open_with_trouble,
        },
        i = {
          ["<C-f>"] = trouble.open_with_trouble,
          ["<C-k>"] = lga_actions.quote_prompt(),
          ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob **/" }),
        },
      }
      telescope.setup(opts)

      -- load extensions
      for _, ext in ipairs(opts.extensions_list) do
        telescope.load_extension(ext)
      end

      local builtin = require("telescope.builtin")
      -- core telescope things
      vim.keymap.set("n", "<leader>?", "<cmd>Telescope<cr>", { desc = "search telecope pickers" })
      vim.keymap.set("n", "<leader>:", builtin.commands, { desc = "execute a command with telescope" })
      vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "currenty buffer fuzzy find" })
      vim.keymap.set("n", "<C-p>", telescope.extensions.recent_files.pick, { desc = "recent files" })
      vim.keymap.set("n", "<leader>fl", builtin.resume, { desc = "resume last search (find last)" })
      -- vim.keymap.set("n", "<C-p>", builtin.resume, {desc = "resume last search (find last)"})

      -- find files, prefer git but fallback if not in a repo
      vim.keymap.set("n", "<leader>ff", find_or_git_files(builtin), { desc = "find files" })

      vim.keymap.set(
        "n",
        "<leader>fa",
        function()
          builtin.find_files({ follow = true, no_ignore = true, hidden = true })
        end,
        -- "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>",
        { desc = "find all files" }
      )

      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "find buffers" })

      -- vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "fild oldfiles" })
      vim.keymap.set("n", "<leader>fo", telescope.extensions.recent_files.pick, { desc = "find recent (old) files" })
      -- vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "git files" })

      -- https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md
      local lga_shortcuts = require("telescope-live-grep-args.shortcuts")
      vim.keymap.set("n", "<leader>fp", telescope.extensions.live_grep_args.live_grep_args,
        { desc = "find pattern (live grep (args))" })
      vim.keymap.set("n", "<leader>fw", lga_shortcuts.grep_word_under_cursor, { desc = "grep word under cursor" })
      vim.keymap.set("v", "<leader>fv", lga_shortcuts.grep_visual_selection, { desc = "grep visual selection" })

      --vim.keymap.set("n", "<leader>fp", builtin.live_grep, { desc = "find pattern (live grep)" })
      --[[
      vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "grep word under cursor" })
      vim.keymap.set( "n", "<leader>fp", live_grep_from_git_root(builtin), { desc = "find pattern (live grep from project git root with fallback)" })
      vim.keymap.set(
        "n",
        "<leader>fpl",
        function() builtin.live_grep({ cwd = vim.loop.cwd() }) end,
        { desc = "find pattern from cwd" }
      )
      ]]
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "find in help pages" })
      vim.keymap.set("n", "<leader>fhl", builtin.highlights, { desc = "find highlights" })

      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "search diagnostics" })

      -- local to file
      vim.keymap.set("n", "<leader>sp", builtin.spell_suggest, { desc = "spelling suggestions for word" })

      -- git
      vim.keymap.set("n", "<leader>gl", builtin.git_commits, { desc = "git log (commits)" })
      vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "git status" })
    end,
  },


  {
    "nvim-tree/nvim-tree.lua",
    lazy = false, -- load for starting edit on file
    opts = {
      filters = {
        dotfiles = false,
        exclude = {},
      },
      disable_netrw = true,
      hijack_netrw = true,
      hijack_cursor = true,
      hijack_unnamed_buffer_when_opening = false,
      sync_root_with_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      on_attach = on_attach_tree, -- mappings
      view = {
        signcolumn = "yes",
        width = 50,
        adaptive_size = false,
        side = "left",
        preserve_window_proportions = true,
      },
      git = {
        enable = true,
        ignore = true,
      },
      filesystem_watchers = {
        enable = true,
      },
      actions = {
        open_file = {
          resize_window = true,
        },
      },
      diagnostics = {
        enable = true,
        show_on_dirs = false,
        show_on_open_dirs = true,
        debounce_delay = 50,
        severity = {
          min = vim.diagnostic.severity.HINT,
          max = vim.diagnostic.severity.ERROR,
        },
        icons = {
          error = common.icons.error,
          warning = common.icons.warning,
          hint = common.icons.hint,
          info = common.icons.info,
        },
      },
      renderer = {
        highlight_git = true,
        root_folder_label = true,
        highlight_opened_files = "none",
        indent_markers = {
          enable = true,
        },
        special_files = {},
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
            modified = false,
          },
          glyphs = {
            default = common.icons.file.default,
            symlink = common.icons.file.symlink,
            folder = common.icons.folder,
            git = {
              unstaged = common.icons.git.unstaged,
              staged = common.icons.git.staged,
              unmerged = common.icons.git.unmerged,
              renamed = common.icons.git.renamed,
              untracked = common.icons.git.untracked,
              deleted = common.icons.git.deleted,
              ignored = common.icons.git.ignored,
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
      vim.g.nvimtree_side = opts.view.side
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeFindFile<CR>", { desc = "(explore) toggle nvimtree to file" })
      vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeToggle <CR>", { desc = "(explore) nvimtree from current file" })
    end,
  },

  {
    "folke/trouble.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
      require("trouble").setup {
        -- these are the default options
        position = "bottom",                     -- position of the list can be: bottom, top, left, right
        height = 10,                             -- height of the trouble list when position is top or bottom
        width = 50,                              -- width of the list when position is left or right
        icons = true,                            -- use devicons for filenames
        mode = "workspace_diagnostics",          -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
        fold_open = common.icons.arrow_open,     -- icon used for open folds
        fold_closed = common.icons.arrow_closed, -- icon used for closed folds
        group = true,                            -- group results by file
        padding = true,                          -- add an extra new line on top of the list
        action_keys = {
          -- map to {} to remove a mapping, for example:
          -- close = {},
          close = "q",                     -- close the list
          cancel = "<esc>",                -- cancel the preview and get back to your last window / buffer / cursor
          refresh = "r",                   -- manually refresh
          jump = { "<cr>", "<tab>" },      -- jump to the diagnostic or open / close folds
          open_split = { "<c-x>" },        -- open buffer in new split
          open_vsplit = { "<c-v>" },       -- open buffer in new vsplit
          open_tab = { "<c-t>" },          -- open buffer in new tab
          jump_close = { "o" },            -- jump to the diagnostic and close the list
          toggle_mode = "m",               -- toggle between "workspace" and "document" diagnostics mode
          toggle_preview = "P",            -- toggle auto_preview
          hover = "K",                     -- opens a small popup with the full multiline message
          preview = "p",                   -- preview the diagnostic location
          close_folds = { "zM", "zm" },    -- close all folds
          open_folds = { "zR", "zr" },     -- open all folds
          toggle_fold = { "zA", "za" },    -- toggle fold of current file
          previous = "k",                  -- previous item
          next = "j"                       -- next item
        },
        indent_lines = true,               -- add an indent guide below the fold icons
        auto_open = false,                 -- automatically open the list when you have diagnostics
        auto_close = false,                -- automatically close the list when you have no diagnostics
        auto_preview = true,               -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
        auto_fold = false,                 -- automatically fold a file trouble list at creation
        auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
        signs = {
          -- icons / text used for a diagnostic
          error = common.icons.error,
          warning = common.icons.warning,
          hint = common.icons.hint,
          information = common.icons.info,
          other = common.icons.other,
        },
        use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
      }
      vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>")
      vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>")
      vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>")
      vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>")
      vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>")
      vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>",
        { desc = "goto references (Trouble)", buffer = true })
      vim.keymap.set("n", "gi", "<cmd>Trouble lsp_implementations<cr>",
        { desc = "goto implementations (Trouble)", buffer = true })
      vim.keymap.set("n", "<leader>n", function() require("trouble").next({ skip_groups = true, jump = true }) end,
        { desc = "next item in trouble list" })
      vim.keymap.set("n", "<leader>N", function() require("trouble").previous({ skip_groups = true, jump = true }) end,
        { desc = "previous item in trouble list" })
    end
  },
}
