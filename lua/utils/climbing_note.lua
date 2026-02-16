local M = {}

M.open_training_note = function()
  local home = vim.fn.expand("~")
  local base_path = home .. "/personalProject/docs/climbing"
  local date = os.date("%Y-%m-%d")
  local year = os.date("%Y")
  local month = os.date("%m")

  local folder = string.format("%s/%s/%s", base_path, year, month)
  if vim.fn.isdirectory(folder) == 0 then
    vim.fn.mkdir(folder, "p")
  end

  local file_path = string.format("%s/%s.md", folder, date)
  local template_path = home .. "/personalProject/docs/templates/climbing.md"

  if vim.fn.filereadable(file_path) == 0 then
    -- Ask which day
    local day = vim.fn.input("Max Bouldering (A) / Power Endurance (B): ")
    local day_label = (day == "A" or day == "a") and "Day A" or "Day B"

    local session_type = (day == "A" or day == "a") and "Max bouldering" or "Power endurance"

    vim.fn.writefile(vim.fn.readfile(template_path), file_path)

    local lines = vim.fn.readfile(file_path)
    for i, line in ipairs(lines) do
      line = line:gsub("{{date}}", date)
      line = line:gsub("{{day}}", day_label)
      line = line:gsub("{{session_type}}", session_type)
      lines[i] = line
    end
    vim.fn.writefile(lines, file_path)
  end

  vim.cmd("edit " .. file_path)
end

return M
