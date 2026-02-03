return {
  "numToStr/FTerm.nvim",
  opts = {
    border = "double",
    dimensions = {
      height = 0.9,
      width = 0.9,
    },
    hl = "NormalFloat",
    blend = 15,
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
