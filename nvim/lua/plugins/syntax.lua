return {
  {
    "nvim-treesitter/nvim-treesitter",
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/playground",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "comment", -- NOTE: enables TODO, FIXME, etc
          "vim",
          "lua",
          "html",
          "css",
          "javascript",
          "typescript",
          "tsx",
          "c",
          "markdown",
          "markdown_inline",
          "go",
          "gomod",
        },
        highlight = {
          enable = true,
          use_languagetree = true,
        },
        indent = { enable = true },

        playground = {
          enable = true,
          updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = "o",
            toggle_hl_groups = "i",
            toggle_injected_languages = "t",
            toggle_anonymous_nodes = "a",
            toggle_language_display = "I",
            focus_language = "f",
            unfocus_language = "F",
            update = "R",
            goto_node = "<cr>",
            show_help = "?",
          },
        },

        textobjects = {
          select = {
            enable = true,
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects#built-in-textobjects
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["aa"] = "@parameter.outer",   -- "argument" -like argtextobj.vim
              ["ia"] = "@parameter.inner",
              ["ac"] = "@conditional.outer", -- "conditional"
              ["ic"] = "@conditional.inner",
              ["aC"] = { query = "@class.outer", desc = "Select outer part of a class region" },
              ["iC"] = { query = "@class.inner", desc = "Select inner part of a class region" },
              ["as"] = { query = "@block.outer", desc = "Select language scope" },
              ["is"] = { query = "@block.inner", desc = "Select language scope" },
              ["al"] = { query = "@loop.outer", desc = "Select loop" },
              ["il"] = { query = "@loop.inner", desc = "Select around loop" },
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = { query = "@class.outer", desc = "Next class start" },
              ["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
              --
              -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
              ["]o"] = "@loop.*",
              -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
              --
              -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
              -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
              ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[a"] = { query = "@parameter.inner", desc = "Previous argument start" },
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {
              ["]f"] = "@function.outer",
              ["]c"] = "@conditional.outer",
            },
            goto_previous = {
              ["[f"] = "@function.outer",
              ["[c"] = "@conditional.outer",
            }
          },

        },
      })
    end,
  },


}
