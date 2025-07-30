return {
  "rubengardner/neovim-ollama",
  config = function()
    local cwd = vim.fn.getcwd()
    local project_root = cwd
    while not vim.fn.filereadable(project_root .. "/go.mod") and project_root ~= "/" do
      project_root = vim.fn.fnamemodify(project_root, ":h")
    end

    local binary = project_root .. "/neovim-ollama"
    if vim.fn.filereadable(binary) == 0 then
      vim.fn.system("go build -o " .. binary .. " " .. project_root)
    end

    local function open_popup()
      local buf = vim.api.nvim_create_buf(false, true)
      local width = math.floor(vim.o.columns * 0.7)
      local height = math.floor(vim.o.lines * 0.7)
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)

      local opts = {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "rounded",
      }

      vim.api.nvim_open_win(buf, true, opts)
      vim.fn.termopen(binary)
      vim.cmd("startinsert")
    end

    vim.api.nvim_create_user_command("OllamaPopup", open_popup, {})
  end,
}
