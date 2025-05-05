return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      mappings = {
        ["<Right>"] = "open", -- Right arrow expands
        ["<Left>"] = "close_node", -- Left arrow collapses
      },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false, -- This ensures dotfiles are visible
        hide_gitignored = false,
      },
    },
  },
}
