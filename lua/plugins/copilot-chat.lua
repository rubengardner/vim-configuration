local IS_DEV = false

local prompts = {
  Explain = "Please explain how the following code works.",
  Review = "Please review the following code and provide suggestions for improvement.",
  PythonUnitTest = "Generate unit tests for this file. The name of the test class should be the same as the file name with 'TestCase'. Use Given/When/Then format. Use Given/When/Then format in the name of the test methods. Avoid using patch. If Mocking, use 'Mock' with 'spec_set' to specify the mock object",
  Refactor = "Please refactor the following code to improve its clarity and readability.",
  BetterNamings = "Please provide better names for the following variables and functions.",
}

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "ai", mode = { "n", "v" } },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "diff", "markdown" } },
  },
  {
    dir = IS_DEV and "~/research/CopilotChat.nvim" or nil,
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      question_header = "## User ",
      answer_header = "## Copilot ",
      error_header = "## Error ",
      prompts = prompts,
      model = "claude-3.7-sonnet",
      mappings = {
        -- Use tab for completion
        complete = {
          detail = "Use @<Tab> or /<Tab> for options.",
          insert = "<Tab>",
        },
        -- Close the chat
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        -- Reset the chat buffer
        reset = {
          normal = "<C-x>",
          insert = "<C-x>",
        },
        -- Submit the prompt to Copilot
        submit_prompt = {
          normal = "<CR>",
          insert = "<C-CR>",
        },
        -- Accept the diff
        accept_diff = {
          normal = "<C-y>",
          insert = "<C-y>",
        },
        -- Show help
        show_help = {
          normal = "g?",
        },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")

      local hostname = io.popen("hostname"):read("*a"):gsub("%s+", "")
      local user = hostname or vim.env.USER or "User"
      opts.question_header = "  " .. user .. " "
      opts.answer_header = "  Copilot "
      -- Override the git prompts message
      opts.prompts.Commit = {
        prompt = '> #git:staged\n\nWrite commit message with commitizen convention. Write clear, informative commit messages that explain the "what" and "why" behind changes, not just the "how".',
      }

      chat.setup(opts)

      local select = require("CopilotChat.select")
      vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
        chat.ask(args.args, { selection = select.visual })
      end, { nargs = "*", range = true })

      -- Inline chat with Copilot
      vim.api.nvim_create_user_command("CopilotChatInline", function(args)
        chat.ask(args.args, {
          selection = select.visual,
          window = {
            layout = "float",
            relative = "cursor",
            width = 1,
            height = 0.4,
            row = 1,
          },
        })
      end, { nargs = "*", range = true })

      -- Restore CopilotChatBuffer
      vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
        chat.ask(args.args, { selection = select.buffer })
      end, { nargs = "*", range = true })

      -- Custom buffer for CopilotChat
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true
        end,
      })
    end,
    keys = {
      -- Show prompts actions
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt({
            context = {
              "buffers",
            },
          })
        end,
        desc = "Prompts + all buffers",
      },
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt()
        end,
        mode = "x",
        desc = "Prompts with selected data",
      },
      {
        "<leader>av",
        ":CopilotChatVisual",
        mode = "x",
        desc = "Toggle chat",
      },

      {
        "<leader>ax",
        function()
          local start = vim.fn.getpos("'<")[2]
          local finish = vim.fn.getpos("'>")[2]
          local lines = vim.api.nvim_buf_get_lines(0, start - 1, finish, false)
          local text = table.concat(lines, "\n")

          if text == "" then
            print("No text selected.")
            return
          end

          local input = vim.fn.input("Ask Copilot: ")
          if input ~= "" then
            local combined_input = input .. "\n\n" .. text
            require("CopilotChat").ask(combined_input)
          end
        end,
        mode = "x",
        desc = "Inline Context with Selection + Prompt",
      },

      {
        "<leader>an",
        function()
          local input = vim.fn.input("Ask Copilot (No context): ")
          if input ~= "" then
            vim.cmd("CopilotChat " .. input)
          end
        end,
        desc = "NO context",
      },
      {
        "<leader>ac",
        function()
          local input = vim.fn.input("Ask copilot (Context): ")
          if input ~= "" then
            require("CopilotChat").ask(input, {
              selection = require("CopilotChat.select").buffer,
            })
          end
        end,
        desc = "Context - Current Buffer",
      },
      {
        "<leader>ad",
        function()
          local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
          if #diagnostics == 0 then
            vim.notify("No diagnostics found for current line.", vim.log.levels.INFO)
            return
          end

          local diagnostic_messages = {}
          for _, d in ipairs(diagnostics) do
            table.insert(diagnostic_messages, d.message)
          end

          local diagnostic_text = table.concat(diagnostic_messages, "\n")
          local prompt = "Fix the following error in my code:\n" .. diagnostic_text

          local line_content = vim.api.nvim_get_current_line()
          prompt = prompt .. "\n\nLine content: " .. line_content

          require("CopilotChat").ask(prompt, {
            selection = require("CopilotChat.select").buffer,
          })
        end,
        desc = "Diagnostics",
      },
      -- Clear buffer and chat history
      { "<leader>ar", "<cmd>CopilotChatReset<cr>", desc = "Clear buffer and chat history" },
      -- Toggle Copilot Chat Vsplit
      { "<leader>av", "<cmd>CopilotChatToggle<cr>", desc = "Toggle chat" },
      -- Copilot Chat Models
      { "<leader>a?", "<cmd>CopilotChatModels<cr>", desc = "Select Models" },
      -- Copilot Chat Agents
    },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>gm", group = "Copilot Chat" },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    opts = {
      file_types = { "markdown", "copilot-chat" },
    },
    ft = { "markdown", "copilot-chat" },
  },
}
