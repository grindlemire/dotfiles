vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- handled via lsp -> null-ls
-- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
--     pattern = { "*.go" },
--     callback = function()
--         vim.cmd.call("LanguageClient#textDocument_formatting_sync()")
--     end,
-- })
