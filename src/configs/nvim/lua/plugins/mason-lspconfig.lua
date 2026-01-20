return {
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mason-org/mason.nvim",
    },
    opts = {
      ensure_installed = {
        "bashls",
        "lua_ls",
        "clangd",
        "ts_ls",
        "pyright",
        "ruby-lsp",
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "beautysh", -- formatter
        "clang-format", -- formatter
        "stylua", -- formatter
        "prettier", -- formatter
        "black", -- formatter
        "eslint_d", -- linter
        "ruff", -- linter
        "rubocop", -- linter
      },
    },
  },
}
