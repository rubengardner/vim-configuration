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

      -- Load configurations from VS Code launch file
      require("utils.dap_helpers").load_vscode_launch_config()

      -- General Adapters
      dap.adapters.python = {
        type = "executable",
        command = "python3", -- Assumes python3 is in your PATH
        args = { "-m", "debugpy.adapter" },
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

      -- Setup plugins
      require("dap-go").setup()
      require("dapui").setup()
      require("nvim-dap-virtual-text").setup()
      require("dap-python").setup("python3")

      -- UI Customizations
      vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointRejected", {
        text = "",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapStopped", {
        text = "",
        texthl = "DiagnosticSignWarn",
        linehl = "Visual",
        numhl = "DiagnosticSignWarn",
      })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end

      -- Keymaps
      vim.keymap.set("n", "<leader>dd", function()
        dap.toggle_breakpoint()
      end, { noremap = true, silent = true, desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<C-S-d>", function()
        dap.toggle_breakpoint()
      end, { noremap = true, silent = true, desc = "Toggle breakpoint" })
      vim.keymap.set("n", "<leader>dc", function()
        dap.continue()
      end, { noremap = true, silent = true, desc = "Continue" })
      vim.keymap.set("n", "<C-S-c>", function()
        require("dap").continue()
      end, { noremap = true, silent = true, desc = "Continue" })
      vim.keymap.set("n", "<leader>do", function()
        dap.step_over()
      end, { noremap = true, silent = true, desc = "Step Over" })
      vim.keymap.set("n", "<C-S-o>", function()
        require("dap").step_over()
      end, { noremap = true, silent = true, desc = "Step over" })
      vim.keymap.set("n", "<leader>di", function()
        dap.step_into()
      end, { noremap = true, silent = true, desc = "Step into" })
      vim.keymap.set("n", "<C-S-i>", function()
        require("dap").step_into()
      end, { noremap = true, silent = true, desc = "Step Into" })
      vim.keymap.set("n", "<leader>dq", function()
        require("dap").terminate()
        require("dapui").close()
      end, { noremap = true, silent = true, desc = "Terminate" })
      vim.keymap.set("n", "<leader>du", function()
        dapui.toggle()
      end, { noremap = true, silent = true, desc = "Toggle UI" })
      vim.keymap.set("n", "<C-S-u>", function()
        dapui.toggle()
      end, { noremap = true, silent = true, desc = "Toggle UI" })
      vim.keymap.set("n", "<leader>de", function()
        require("dap.ui.widgets").hover()
      end, { noremap = true, silent = true, desc = "Evaluate expression (hover)" })
      vim.keymap.set("n", "<C-S-e>", function()
        require("dap.ui.widgets").hover()
      end, { noremap = true, silent = true, desc = "Evaluate expression (hover)" })

      -- DEBUG TEST UNDER CURSOR
      vim.keymap.set("n", "<leader>dt", function()
        require("utils.dap_helpers").debug_test_under_cursor()
      end, { noremap = true, silent = true, desc = "Debug test under cursor" })
    end,
  },
}
