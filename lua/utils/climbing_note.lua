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
  if vim.fn.filereadable(file_path) == 0 then
    -- Ask which day
    local day = vim.fn.input("Max Bouldering (A) / Power Endurance (B) / Outdoor (C): ")

    local day_label, session_type, template_path
    if day == "A" or day == "a" then
      day_label = "Day A"
      session_type = "Max bouldering"
      template_path = home .. "/personalProject/docs/templates/climbing.md"
    elseif day == "C" or day == "c" then
      day_label = "Outdoor"
      session_type = "Outdoor climbing"
      template_path = home .. "/personalProject/docs/templates/climbing-outdors.md"
    else
      day_label = "Day B"
      session_type = "Power endurance"
      template_path = home .. "/personalProject/docs/templates/climbing.md"
    end

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
