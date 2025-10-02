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

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = 8123,
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug-adapter",
          args = { "8123" },
        },
      }

      dap.configurations.typescript = {
        {
          name = "Tile Server",
          type = "pwa-node",
          request = "launch",
          program = "${workspaceFolder}/tile_server/server.ts",
          cwd = "${workspaceFolder}",
          runtimeExecutable = "node",
          runtimeArgs = { "-r", "ts-node/register" },
          sourceMaps = true,
          protocol = "inspector",
          console = "integratedTerminal",
          env = {
            PORT = "3000",
          },
          outFiles = { "${workspaceFolder}/tile_server/dist/**/*.js" },
        },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "V3 - Django",
          program = vim.fn.getcwd() .. "/manage.py",
          args = { "runserver", "0.0.0.0:8000" },
          django = true,
          console = "integratedTerminal",
        },
        {
          type = "python",
          request = "launch",
          name = "V3 - Celery Worker",
          module = "celery",
          args = {
            "-A",
            "badgermapping",
            "worker",
            "-Q",
            "celery,recorddatafetcher,default,export,import-heavy-io,geocoding-heavy-io,routes,general-light-io",
            "-l",
            "INFO",
            "-O",
            "fair",
            "--max-tasks-per-child=400",
            "--pool=solo",
          },
          console = "integratedTerminal",
        },
        {
          type = "python",
          request = "launch",
          name = "SO - Django",
          program = "${workspaceFolder}/manage.py",
          django = true,
          args = { "runserver", "0.0.0.0:7000" },
          env = {
            PYTHONUNBUFFERED = "1",
            DJANGO_SETTINGS_MODULE = "badgermapping.settings_local",
          },
          pytonPath = function()
            return "docker"
          end,
          pythonArgs = {
            "exec",
            "-it",
            "-e",
            "PYTHONUNBUFFERED=1",
            "-e",
            "DJANGO_SETTINGS_MODULE=badgermapping.settings_local",
            "badger-web",
            "python",
          },
        },
        {
          type = "python",
          request = "launch",
          name = "GEO -- Fast API Service",
          args = {
            "src.geocoding.vendors.api.fast_api.main:app",
            "--reload",
            "--port",
            "9001",
          },
          console = "integratedTerminal",
          cwd = "${workspaceFolder}",
          module = "uvicorn",
          pythonPath = python_path,
          justMyCode = false,
        },
        {
          type = "python",
          request = "launch",
          name = "GEO - Celery ",
          console = "integratedTerminal",
          module = "celery",
          args = {
            "-A",
            "src.geocoding.vendors.celery.celery",
            "worker",
            "-Q",
            "heavy-io,light-io",
            "-l",
            "INFO",
            "-O",
            "fair",
            "--max-tasks-per-child=400",
            "--pool=solo", -- so it runs in main thread (for debugging)
          },
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

      vim.keymap.set("n", "<leader>de", function()
        require("dap.ui.widgets").hover()
      end, { noremap = true, silent = true, desc = "Evaluate expression (hover)" })
      vim.keymap.set("n", "<C-S-e>", function()
        require("dap.ui.widgets").hover()
      end, { noremap = true, silent = true, desc = "Evaluate expression (hover)" })

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
