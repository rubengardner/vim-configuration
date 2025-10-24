return {
  "nvim-telescope/telescope.nvim",
  config = function()
    local telescope = require("telescope.builtin")

    vim.api.nvim_create_user_command("FindTest", function()
      local file_path = vim.api.nvim_buf_get_name(0)
      if file_path == "" then
        print("No file open!")
        return
      end

      local file_name = vim.fn.fnamemodify(file_path, ":t")
      local target_file

      if file_name:match("^test_") then
        target_file = file_name:gsub("^test_", "")
      else
        target_file = "test_" .. file_name
      end

      telescope.find_files({
        default_text = target_file,
      })
    end, {})
  end,
}
