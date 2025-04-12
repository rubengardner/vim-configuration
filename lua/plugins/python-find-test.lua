return {
  "nvim-telescope/telescope.nvim",
  config = function()
    local telescope = require("telescope.builtin")

    vim.api.nvim_create_user_command("FindTest", function()
      -- Search for class definition in the current file
      local class_name = vim.fn.search("class \\(\\w\\+\\)", "bn") -- "bn" searches backward, non-wrapping
      if class_name == 0 then
        print("No class found!")
        return
      end

      -- Extract class name
      local line = vim.fn.getline(class_name)
      local match = line:match("class%s+(%w+)")
      if not match then
        print("Couldn't extract class name!")
        return
      end

      local test_class = match .. "TestCase"

      -- Use Telescope's live_grep instead of grep
      telescope.live_grep({
        default_text = test_class, -- Prefill search with class name
      })
    end, {})
  end,
}
