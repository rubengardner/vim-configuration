local dap = require("dap")
local M = {}

--- Gets the Go test function name under cursor or nearest
function M.get_go_test_function_name()
  local current_line = vim.fn.line(".")
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Look for test function on current line or above
  for i = current_line, 1, -1 do
    local line = lines[i]
    if line then
      local test_func = line:match("^%s*func%s+(Test%w+)%s*%(")
      if test_func then
        return test_func
      end
    end
  end

  -- If no test function found, try the word under cursor
  local word = vim.fn.expand("<cword>")
  if word:match("^Test%w+") then
    return word
  end

  return nil
end

--- Runs a debug session for the test under the cursor.
-- It currently supports Go, Python (unittest), and Python (Django) tests.
function M.debug_test_under_cursor()
  local full_path = vim.fn.expand("%:p")
  -- Use path relative to current working directory, assuming it's the project root
  local rel_path = vim.fn.expand("%:.")
  local ext = vim.fn.expand("%:e")

  -- Handle Go files
  if ext == "go" then
    local test_func = M.get_go_test_function_name()
    local current_pkg = vim.fn.fnamemodify(full_path, ":h")

    if test_func then
      dap.run({
        type = "go",
        name = "Debug Go Test",
        request = "launch",
        mode = "test",
        program = current_pkg,
        args = { "-test.run", "^" .. test_func .. "$" },
        buildFlags = "-v",
      })
    else
      -- Debug all tests in the file
      dap.run({
        type = "go",
        name = "Debug Go Tests in File",
        request = "launch",
        mode = "test",
        program = current_pkg,
        buildFlags = "-v",
      })
    end
    return
  end

  -- Handle Python files
  if ext == "py" then
    local module_path = rel_path:gsub("/", "."):gsub("%.py$", "")
    local function_name = vim.fn.expand("<cword>")

    -- Kept your original logic for determining a Django test
    local is_django_test = false
    for line in io.lines(full_path) do
      if string.match(line, "from django.test import TestCase") then
        is_django_test = true
        break
      end
    end

    local test_class = nil
    local current_line = vim.fn.line(".")
    for i = current_line, 1, -1 do
      local line = vim.fn.getline(i)
      local class_name = line:match("^%s*class%s+([%w_]+)%s*%b():")
      if class_name then
        test_class = class_name
        break
      end
    end
    is_django_test = true

    local test_target
    if function_name:match("^test_") then
      if test_class then
        -- Django's test runner and unittest both use dotted paths
        test_target = module_path .. "." .. test_class .. "." .. function_name
      else
        test_target = module_path .. "." .. function_name
      end
    else
      -- If the cursor is not on a specific test function, run all tests in the file
      test_target = module_path
    end

    if is_django_test then
      dap.run({
        type = "python",
        request = "launch",
        name = "Debug Django Test",
        program = vim.fn.getcwd() .. "/manage.py",
        args = { "test", test_target, "--keepdb" },
        django = true,
        justMyCode = false,
      })
    else
      dap.run({
        type = "python",
        request = "launch",
        name = "Debug unittest",
        module = "unittest",
        args = { test_target },
      })
    end
  end
end

--- Debug integration with neotest
function M.debug_neotest()
  local neotest = require("neotest")
  neotest.run.run({ strategy = "dap" })
end

--- Debug nearest test with neotest (for Go files specifically)
function M.debug_go_test_with_neotest()
  local ext = vim.fn.expand("%:e")
  if ext ~= "go" then
    vim.notify("This function is only for Go test files", vim.log.levels.WARN)
    return
  end

  local neotest = require("neotest")
  neotest.run.run({ strategy = "dap" })
end

--- Loads DAP configurations from .vscode/launch.json
function M.load_vscode_launch_config()
  local launch_json_path = vim.fn.findfile(".vscode/launch.json", ".;")
  if launch_json_path == "" or launch_json_path == nil then
    return
  end

  local f = io.open(launch_json_path, "r")
  if not f then
    return
  end
  local content = f:read("*a")
  f:close()

  -- VSCode's launch.json allows comments, which are not valid JSON.
  -- This is a simple attempt to remove single-line comments.
  local clean_content = content:gsub("//.*", "")

  local ok, launch_config = pcall(vim.fn.json_decode, clean_content)
  if not ok then
    -- If parsing fails, try with original content.
    ok, launch_config = pcall(vim.fn.json_decode, content)
    if not ok then
      vim.notify(
        "Error parsing .vscode/launch.json. It might contain unsupported comments or be invalid.",
        vim.log.levels.WARN
      )
      return
    end
  end

  if launch_config and launch_config.configurations then
    dap.configurations = dap.configurations or {}
    for _, config in ipairs(launch_config.configurations) do
      local config_type = config.type
      if config_type then
        dap.configurations[config_type] = dap.configurations[config_type] or {}
        table.insert(dap.configurations[config_type], config)
      end
    end
  end
end

return M
