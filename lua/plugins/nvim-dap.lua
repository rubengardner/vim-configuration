return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "theHamsta/nvim-dap-virtual-text",
      "leoluz/nvim-dap-go",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dap_python = require("dap-python")

      local python_path = vim.fn.trim(vim.fn.system("poetry run which python"))

      dap.adapters.python = {
        type = "executable",
        command = python_path,
        args = { "-m", "debugpy.adapter" },
      }
      dap.adapters.go = {
        type = "executable",
        command = "dlv",
        args = { "dap", "exec", "${workspaceFolder}/ui/ui.go" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Monolith",
          program = vim.fn.getcwd() .. "/manage.py",
          args = { "runserver", "0.0.0.0:8000" },
          django = true,
          console = "integratedTerminal",
        },
        {
          type = "python",
          request = "launch",
          name = "Schedule Jobs to Provider",
          program = "${workspaceFolder}/manage.py",
          args = { "schedule_jobs_to_provider" },
          django = true,
          console = "integratedTerminal",
          pythonPath = python_path,
        },
      }

      dap.configurations.go = {
        {
          type = "go",
          name = "Debug ui/ui.go",
          request = "launch",
          program = "${workspaceFolder}/ui/ui.go",
        },
      }
      require("dap-go").setup()
      require("dapui").setup()
      require("nvim-dap-virtual-text").setup()

      dap_python.setup("python3")

      vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointRejected", {
        text = "", -- or "❌"
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapStopped", {
        text = "", -- or "→"
        texthl = "DiagnosticSignWarn",
        linehl = "Visual",
        numhl = "DiagnosticSignWarn",
      })

      -- Automatically open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end

      -- Toggle breakpoint
      vim.keymap.set("n", "<leader>dd", function()
        dap.toggle_breakpoint()
      end, { noremap = true, silent = true, desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<C-S-d>", function()
        dap.toggle_breakpoint()
      end, { noremap = true, silent = true, desc = "Toggle breakpoint" })

      -- Continue / Start
      vim.keymap.set("n", "<leader>dc", function()
        dap.continue()
      end, { noremap = true, silent = true, desc = "Continue" })
      vim.keymap.set("n", "<C-S-c>", function()
        require("dap").continue()
      end, { noremap = true, silent = true, desc = "Continue" })

      -- Step Over
      vim.keymap.set("n", "<leader>do", function()
        dap.step_over()
      end, { noremap = true, silent = true, desc = "Step Over (Control + Shift + o)" })
      vim.keymap.set("n", "<C-S-o>", function()
        require("dap").step_over()
      end, { noremap = true, silent = true, desc = "Step over" })

      -- Step Into
      vim.keymap.set("n", "<leader>di", function()
        dap.step_into()
      end, { noremap = true, silent = true, desc = "Step into (Control + Shift + i)" })
      vim.keymap.set("n", "<C-S-i>", function()
        require("dap").step_into()
      end, { noremap = true, silent = true, desc = "Step Into" })

      -- Keymap to terminate debugging
      vim.keymap.set("n", "<leader>dq", function()
        require("dap").terminate()
        require("dapui").close()
      end, { noremap = true, silent = true, desc = "Terminate" })

      -- Toggle DAP UI
      vim.keymap.set("n", "<leader>du", function()
        dapui.toggle()
      end, { noremap = true, silent = true, desc = "Toggle UI" })
      vim.keymap.set("n", "<C-S-u>", function()
        dapui.toggle()
      end, { noremap = true, silent = true, desc = "Step Into" })

      -- DEBUG TEST UNDER CURSOR
      vim.keymap.set("n", "<leader>dt", function()
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
          require("dap").run({
            type = "python",
            request = "launch",
            name = "Debug Django Test",
            program = vim.fn.getcwd() .. "/manage.py",
            args = { "test", test_target, "--keepdb" },
            django = true,
          })
        else
          require("dap").run({
            type = "python",
            request = "launch",
            name = "Debug unittest",
            module = "unittest",
            args = { test_target },
          })
        end
      end, { noremap = true, silent = true, desc = "Debug test under cursor" })
    end,
  },
}
