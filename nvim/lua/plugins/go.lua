return {
  {
    "ray-x/go.nvim",
    enabled = true,  -- breaking godo definition!
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      --"neovim/nvim-lspconfig",
      --"nvim-treesitter/nvim-treesitter",
    },
    -- TODO todo go interfaces implemented by struct
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", 'gomod' },
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  }
}
