return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "marilari88/neotest-vitest",
    "nvim-neotest/neotest-python",
    "nvim-neotest/neotest-go",
    "fredrikaverpil/neotest-golang", -- Alternative Go adapter
  },
  config = function()
    -- Try to use neotest-golang as it's more stable with complex test structures
    local go_adapter
    local golang_ok, golang_adapter = pcall(require, "neotest-golang")
    if golang_ok then
      go_adapter = golang_adapter({
        go_test_args = { "-v", "-race", "-count=1" },
        dap_go_enabled = false,
      })
    else
      -- Fallback to neotest-go with minimal config
      go_adapter = require("neotest-go")({
        experimental = {
          test_table = true,
        },
        args = { "-v" },
      })
    end

    require("neotest").setup({
      adapters = {
        require("neotest-vitest"),
        require("neotest-python")({
          dap = { justMyCode = false },
          runner = "pytest",
        }),
        go_adapter,
      },
      discovery = {
        enabled = true,
      },
      running = {
        concurrent = true,
      },
      summary = {
        enabled = true,
        expand_errors = true,
      },
    })

    -- Enhanced key mappings with debug support
    vim.keymap.set("n", "<leader>tt", function()
      require("neotest").run.run()
    end, { desc = "Run nearest test" })

    vim.keymap.set("n", "<leader>tf", function()
      require("neotest").run.run(vim.fn.expand("%"))
    end, { desc = "Run test file" })

    vim.keymap.set("n", "<leader>tl", function()
      require("neotest").run.run_last()
    end, { desc = "Run last test" })

    vim.keymap.set("n", "<leader>ts", function()
      require("neotest").summary.toggle()
    end, { desc = "Toggle test summary" })

    -- DEBUG INTEGRATION FOR NEOTEST
    vim.keymap.set("n", "<leader>td", function()
      require("neotest").run.run({ strategy = "dap" })
    end, { desc = "Debug nearest test" })

    vim.keymap.set("n", "<leader>tD", function()
      require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" })
    end, { desc = "Debug test file" })

    -- Stop test runs
    vim.keymap.set("n", "<leader>tS", function()
      require("neotest").run.stop()
    end, { desc = "Stop test runs" })
  end,
}
