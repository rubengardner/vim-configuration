return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      position = "right",
      mappings = {
        ["<Right>"] = "open", -- Right arrow expands
        ["<Left>"] = "close_node", -- Left arrow collapses
      },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false, -- This ensures dotfiles are visible
        hide_gitignored = false,
        hide_by_name = { "__pycache__" },
      },
    },
  },
}
