local dap = require("dap")
local M = {}

--- Runs a debug session for the test under the cursor.
-- It currently supports Go, Python (unittest), and Python (Django) tests.
function M.debug_test_under_cursor()
  local full_path = vim.fn.expand("%:p")
  local rel_path = vim.fn.fnamemodify(full_path, ":~:.")
  local ext = vim.fn.expand("%:e")

  -- Handle Go files
  if ext == "go" then
    local test_func = vim.fn.expand("<cword>")
    local current_pkg = vim.fn.fnamemodify(full_path, ":h")
    dap.run({
      type = "go",
      name = "Debug Go Test",
      request = "launch",
      mode = "test",
      program = current_pkg,
      args = { "-test.run", test_func },
    })
    return
  end

  -- Handle Python files
  if ext == "py" then
    local module_path = rel_path:gsub("/", "."):gsub("%.py$", "")
    local function_name = vim.fn.expand("<cword>")

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

    local test_target
    if function_name:match("^test_") then
      if test_class then
        test_target = is_django_test
            and (module_path:gsub("%.", "/") .. ".py::" .. test_class .. "::" .. function_name)
          or (module_path .. "." .. test_class .. "." .. function_name)
      else
        test_target = is_django_test and (module_path:gsub("%.", "/") .. ".py::" .. function_name)
          or (module_path .. "." .. function_name)
      end
    else
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

