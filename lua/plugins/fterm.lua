return {
  "numToStr/FTerm.nvim",
  opts = {
    border = "double",
    dimensions = {
      height = 1,
      width = 1,
    },
    hl = "NormalFloat",
    blend = 0,
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
