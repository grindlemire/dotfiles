local common = require("common")

local function border(hl_name)
  return {
    { "╭", hl_name },
    { "─", hl_name },
    { "╮", hl_name },
    { "│", hl_name },
    { "╯", hl_name },
    { "─", hl_name },
    { "╰", hl_name },
    { "│", hl_name },
  }
end

-- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance
--
local function cmp_fmt(entry, item)
  if vim.tbl_contains({ "path" }, entry.source.name) then
    local icon, hl_group = require("nvim-web-devicons").get_icon(entry:get_completion_item().label)
    if icon then
      item.kind = icon
      item.kind_hl_group = hl_group
      return item
    end
  end
  local icon = common.icons.lspkind[item.kind] or "◌"
  item.kind = icon .. " " .. item.kind
  -- update along with additional sources
  if entry.source then
    item.menu = "󰳞 " .. ({
      buffer = "buf",
      path = "path",
      nvim_lsp = "lsp",
      luasnip = "snip",
      nvim_lua = "nvlua",
    })[entry.source.name]
  end
  return item
end

-- https://github.com/neovim/nvim-lspconfig/issues/115
local function org_imports()
  local clients = vim.lsp.buf_get_clients()
  for _, client in pairs(clients) do
    local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
    params.context = { only = { "source.organizeImports" } }

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 5000)
    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end
  end
end

-- vim.api.nvim_create_autocmd("BufWritePre", {
-- pattern = { "*.go" },
-- callback = vim.lsp.buf.format,
-- })

-- vim.api.nvim_create_autocmd("BufWritePre", {
-- pattern = { "*.go" },
-- callback = org_imports,
-- })

return {
  {
    -- Keymap docs: https://github.com/VonHeikemen/lsp-zero.nvim/tree/v2.x#keybindings
    -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#default_keymapsopts
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    lazy = false,
    priority = 500, -- MUST be loaded before treesitter https://github.com/VonHeikemen/lsp-zero.nvim/discussions/147
    dependencies = {
      -- LSP Support
      { "neovim/nvim-lspconfig" }, -- Required
      {
        -- Optional
        "williamboman/mason.nvim",
        build = function()
          pcall(vim.cmd, "MasonUpdate")
        end,
        init = function()
          -- use for formatting and linting servers
          local servers = {
            -- "stylua",
            -- "prettier",
          }
          local registry = require("mason-registry")
          for _, pkg_name in ipairs(servers) do
            local ok, pkg = pcall(registry.get_package, pkg_name)
            if ok then
              if not pkg:is_installed() then
                pkg:install()
              end
            end
          end
        end,
      },
      { "williamboman/mason-lspconfig.nvim" }, -- Optional

      -- Autocompletion
      { "hrsh7th/nvim-cmp" },         -- Required
      { "hrsh7th/cmp-nvim-lsp" },     -- Required
      { "L3MON4D3/LuaSnip" },         -- Required
      -- cmp_luasnip: it shows snippets loaded by luasnip in the suggestions. This is useful when you install an external collection of snippets like friendly-snippets (See autocomplete docs for more details).
      { "saadparwaiz1/cmp_luasnip" }, -- integrates luasnip with cmp
      { "hrsh7th/cmp-buffer" },       -- suggestions based on the current file
      { "hrsh7th/cmp-path" },         -- source for filesystem paths
      { "hrsh7th/cmp-nvim-lua" },     -- source for neovim-speciric lua
    },
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
        }
      })
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#configurations
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "gopls",
          "pylsp",
        }
      })

      -- "recommended" preset, but expanded values
      local lsp = require("lsp-zero").preset({
        float_border = 'rounded',
        call_servers = 'local',
        configure_diagnostics = true,
        setup_servers_on_start = true,
        set_lsp_keymaps = {
          preserve_mappings = false,
          omit = {},
        },
        manage_nvim_cmp = {
          set_sources = 'recommended',
          set_basic_mappings = true,
          set_extra_mappings = false,
          use_luasnip = true,
          set_format = true,
          documentation_window = true,
        },
      })

      local fmt_servers = {
        ["gopls"] = { "go" },
        ["lua_ls"] = { "lua", "luau" },
      }

      lsp.on_attach(function(client, bufnr) -- p1 is `client`
        lsp.default_keymaps({ buffer = bufnr })
        vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>",
          { desc = "goto references (Telescope)", buffer = true })
        vim.keymap.set("n", "<leader>i", org_imports, { desc = "update/organize imports", buffer = true })
        --vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "goto definition", buffer = true })
        -- TODO todo golang interfaces implemented by struct
        -- vim.keymap.set("n", "<leader>fm", function()
        -- vim.lsp.buf.format({ async = true })
        -- end, { desc = "lsp formatting", buffer = true })

        -- Disable semantic tokens, and just use treesitter instead
        client.server_capabilities.semanticTokensProvider = nil
      end)

      -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#format_on_saveopts
      lsp.format_mapping("<leader>fm", {
        servers = fmt_servers
      })
      lsp.format_on_save({
        servers = fmt_servers
      })

      lsp.set_sign_icons({
        error = common.icons.error,
        warn = common.icons.warning,
        hint = common.icons.hint,
        info = common.icons.info,
      })

      -- LSP Server configurations

      -- lua specficially for nvim
      -- > make sure you don't call lspconfig in another part of your neovim config.
      -- > lspconfig can override everything lsp-zero does.
      --local lspconfig = require("lspconfig")
      --lspconfig.lua_ls.setup(lsp.nvim_lua_ls())
      lsp.configure("lua_ls", lsp.nvim_lua_ls())
      -- Golang setup
      lsp.configure("gopls", {
        settings = {
          gopls = {
            gofumpt = false, -- stricter formatter
            --local = "github.com/panther-labs",
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
      })

      lsp.configure("pylsp")


      --lsp.nvim_workspace()
      lsp.setup()

      -- Make sure you setup `cmp` after lsp-zero
      local cmp = require("cmp")
      local cmp_opt = {
        completion = {
          -- h: completeopt
          completeopt = "menu,menuone,preview",
          --autocomplete = true,
        },
        -- preselect = true,
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        sources = {
          { name = "path" },
          { name = "nvim_lsp" },
          { name = "luasnip", keyword_length = 2 },
          { name = "nvim_lua" },
          { name = "buffer",  keyword_length = 3 },
        },
        mapping = {
          -- Regular tab complete
          --["<C-Space>"] = cmp.mapping.complete(),
          -- TODO test out these mappings
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<Up>"] = cmp.mapping.select_prev_item(),
          ["<Down>"] = cmp.mapping.select_next_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif require("luasnip").expand_or_jumpable() then
              vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif require("luasnip").jumpable(-1) then
              vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        window = {
          completion = {
            side_padding = 1,
            winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:PmenuSel",
            border = border("CmpBorder"),
            scrollbar = true,
            scrolloff = 3,
          },
          documentation = {
            border = border("CmpDocBorder"),
            winhighlight = "Normal:CmpDoc",
          },
        },
        formatting = {
          fields = { "abbr", "kind", "menu" },
          format = cmp_fmt,
        },
      }
      cmp.setup(cmp_opt)
      --print(vim.inspect(cmp_opt))
    end,
  },

  {
    -- handles linting beyond what an LSP might provide
    "mfussenegger/nvim-lint",
    ft = { "go" },
    config = function()
      require("lint").linters_by_ft = {
        go = { 'golangcilint' },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end
  },
}
