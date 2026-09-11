local lspconfig = require("lspconfig")

-- Register only once
if not lspconfig.configs.luau_ls then
  lspconfig.configs.luau_ls = {
    default_config = {
      cmd = { vim.fn.expand("~/lsps/luau-lsp"), "lsp" },
      filetypes = { "luau" },
      root_dir = lspconfig.util.root_pattern(".git"),
      single_file_support = true,
    },
  }
end

-- Setup
lspconfig.luau_ls.setup {}

-- Detect .luau files
vim.cmd [[autocmd BufRead,BufNewFile *.luau setfiletype luau]]
