return {
  "nvim-lua/plenary.nvim",
  name = "copy-file-path",

  config = function()
    vim.api.nvim_create_user_command("GitCopyPath", function()
      local current_file = vim.fn.expand("%:p")
      local file_dir = vim.fn.expand("%:p:h")

      -- Get the git root directory
      local git_root_cmd = "git -C " .. vim.fn.shellescape(file_dir) .. " rev-parse --show-toplevel"
      local git_root = vim.fn.system(git_root_cmd):gsub("%s+$", "")

      if vim.v.shell_error ~= 0 then
        vim.notify("Not in a git repository", vim.log.levels.ERROR)
        return
      end

      -- Get the relative path
      local relative_path = current_file:sub(#git_root + 2)

      -- Copy to clipboard
      vim.fn.setreg("+", relative_path)
      vim.notify("Copied to clipboard: " .. relative_path, vim.log.levels.INFO)
    end, {})
  end,
}
