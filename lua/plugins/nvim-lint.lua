return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      python = { "mypy" },
      typescript = { "eslint" },
      typescriptreact = { "eslint" },
      javascript = { "eslint" },
      javascriptreact = { "eslint" },
    },
  },
}
