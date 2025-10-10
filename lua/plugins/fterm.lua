return {
  "numToStr/FTerm.nvim",
  opts = {
    border = "double",
    dimensions = {
      height = 0.9,
      width = 0.9,
    },
  },
  keys = {
    {
      "<leader>ft",
      function()
        require("FTerm").toggle()
      end,
      desc = "Toggle FTerm",
    },
  },
}
