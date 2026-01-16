-- Disable none-ls markdownlint to avoid conflicts with our custom nvim-lint config
return {
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      -- Remove markdownlint-cli2 from none-ls sources to avoid conflict
      if opts.sources then
        opts.sources = vim.tbl_filter(function(source)
          -- Check if it's the markdownlint-cli2 source
          return not (source and source.name == "markdownlint-cli2")
        end, opts.sources)
      end
      return opts
    end,
  },
}