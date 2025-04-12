return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      mappings = {
        ["<Right>"] = "open", -- Right arrow expands
        ["<Left>"] = "close_node", -- Left arrow collapses
      },
    },
  },
}
