return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "prettierd" },
      javascriptreact = { "prettierd" },
      typescript = { "prettierd" },
      typescriptreact = { "prettierd" },
      markdown = { "prettierd" },
    },
    formatters = {
      prettierd = {
        prepend_args = function(self, ctx)
          if ctx.filetype == "markdown" then
            return {
              "--prose-wrap", "always",
              "--print-width", "80",
            }
          end
          return {}
        end,
      },
    },
  },
}
