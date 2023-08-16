-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins installed from lua/plugins.lua + lua/plugins/*.lua
local common = require("common")
--require("lazy").setup("plugins", {
require("lazy").setup("plugins", {
  defaults = { lazy = true },

  install = { colorscheme = { "nordark" } },
  ui = {
    border = "rounded",
    icons = {
      ft = common.icons.plugin.ft,
      lazy = common.icons.plugin.lazy,
      loaded = common.icons.plugin.loaded,
      not_loaded = common.icons.plugin.not_loaded,
    },
  },
  dev = {
    path = "~",
  },
  performance = {
    rtp = {
      disabled_plugins = {
        -- "2html_plugin",
        -- "tohtml",
        -- "getscript",
        -- "getscriptPlugin",
        -- "gzip",
        -- "logipat",
        -- -- "netrw",
        -- -- "netrwPlugin",
        -- -- "netrwSettings",
        -- -- "netrwFileHandlers",
        -- "matchit",
        -- "tar",
        -- "tarPlugin",
        -- "rrhelper",
        -- "spellfile_plugin",
        -- "vimball",
        -- "vimballPlugin",
        -- "zip",
        -- "zipPlugin",
        -- "tutor",
        -- "rplugin",
        -- "syntax",
        -- "synmenu",
        -- "optwin",
        -- "compiler",
        -- "bugreport",
        --"ftplugin",
      },
    },
  },
})
-- final reload after plugins
-- TODO why is this needed?
vim.cmd([[colorscheme nordark]])
