return {
  "nvim-lua/plenary.nvim",
  config = function()
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.py",
      callback = function()
        local file = vim.fn.expand("%:p") -- Get full path of the new file
        local dir = vim.fn.fnamemodify(file, ":h") -- Get directory

        -- Check if __init__.py exists in the directory
        local init_file = dir .. "/__init__.py"
        if vim.fn.filereadable(init_file) == 0 then
          -- Create an empty __init__.py
          vim.fn.writefile({}, init_file)
          print("✅ Created __init__.py in " .. dir)
        end
      end,
    })
  end,
}
