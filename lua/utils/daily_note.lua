local M = {}

M.open_daily_note = function()
  local home = vim.fn.expand("~") -- or wherever you want docs repo
  local base_path = home .. "/personalProject/docs/daily"
  local date = os.date("%Y-%m-%d")
  local year = os.date("%Y")
  local month = os.date("%m")

  -- Folder structure: daily/YYYY/MM/
  local folder = string.format("%s/%s/%s", base_path, year, month)
  if vim.fn.isdirectory(folder) == 0 then
    vim.fn.mkdir(folder, "p")
  end

  local file_path = string.format("%s/%s.md", folder, date)
  local template_path = home .. "/personalProject/docs/templates/daily.md"

  -- If file doesn't exist, copy template
  if vim.fn.filereadable(file_path) == 0 then
    vim.fn.writefile(vim.fn.readfile(template_path), file_path)
    -- Replace {{date}} placeholder with today
    local lines = vim.fn.readfile(file_path)
    for i, line in ipairs(lines) do
      lines[i] = line:gsub("{{date}}", date)
    end
    vim.fn.writefile(lines, file_path)
  end

  -- Open the file
  vim.cmd("edit " .. file_path)
end

return M
