return {
  "neovim/nvim-lspconfig",
  config = function()
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    local poetry_python = vim.fn.trim(vim.fn.system("poetry env info -p 2>/dev/null"))
    local python_path = ""

    if poetry_python ~= "" then
      python_path = poetry_python .. "/bin/python"
    else
      python_path = vim.fn.trim(vim.fn.system("which python3"))
    end

    require("lspconfig").pyright.setup({
      settings = {
        python = {
          pythonPath = python_path,
        },
      },
    })

    require("lspconfig").tsserver.setup({
      on_attach = on_attach_disable_format,
    })

    require("lspconfig").gopls.setup({
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
          staticcheck = true,
          gofumpt = true,
        },
      },
    })

    require("lspconfig").elixirls.setup({
      cmd = { "elixir-ls" },
      settings = {
        elixirLS = {
          dialyzerEnabled = true,
          fetchDeps = true,
        },
      },
    })
  end,
}
