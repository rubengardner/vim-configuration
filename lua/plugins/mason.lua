return {
  "mason-org/mason.nvim",
  opts = function(_, opts)
    if not opts.ensure_installed then
      opts.ensure_installed = {}
    end
    vim.list_extend(opts.ensure_installed, {
      "marksman",
      "prettierd",
    })
  end,
}
