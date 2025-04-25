return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ruff_lsp = false, -- Disables Ruff
    },
  },
  require("lspconfig").pyright.setup({
    settings = {
      python = {
        pythonPath = "/Users/ruben_gardner/Library/Caches/pypoetry/virtualenvs/badger-go-5Azyc4AC-py3.12/bin/python",
        analysis = {
          extraPaths = {
            "/Users/ruben_gardner/Library/Caches/pypoetry/virtualenvs/badger-go-5Azyc4AC-py3.12/lib/python3.12/site-packages",
            "/Users/ruben_gardner/PycharmProjects/badger-app/badger-go/monolith",
          },
          autoImportCompletions = true,
        },
      },
    },
  }),
  require("lspconfig").tsserver.setup({}),
}
