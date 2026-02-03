return {
  "vim-test/vim-test",
  config = function()
    -- Python/Django configuration
    local python_path = vim.fn.trim(vim.fn.system("poetry run which python"))
    vim.fn.setenv("DJANGO_SETTINGS_MODULE", "badgermapping.settings_local")
    local cwd = vim.fn.getcwd()

    local project_root = cwd
    while
      not vim.fn.filereadable(project_root .. "/pyproject.toml")
      and not vim.fn.filereadable(project_root .. "/setup.py")
    do
      project_root = vim.fn.fnamemodify(project_root, ":h")
      if project_root == "/" then
        break
      end
    end

    vim.fn.setenv("PYTHONPATH", project_root)
    vim.fn.setenv("PYTHONUNBUFFERED", "1")
    vim.g["test#python#python_path"] = python_path
    vim.g["test#python#runner"] = "pytest"
    
    -- Set test transformation strategy
    vim.g["test#strategy"] = "neovim"
    
    -- Global test runners
    vim.g["test#javascript#runner"] = "vitest"
    vim.g["test#typescript#runner"] = "vitest"
    
    -- Define custom transforms for vitest
    vim.g["test#custom_transformations"] = {
      vitest = function(cmd)
        return "npx vitest " .. cmd
      end
    }
    
    -- Override test detection for TypeScript files
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*.test.ts,*.test.tsx,*.spec.ts,*.spec.tsx",
      callback = function()
        vim.b.test_runner = "vitest"
      end,
    })
  end,
}
