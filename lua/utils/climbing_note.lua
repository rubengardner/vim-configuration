local M = {}

local SEND_DB = vim.fn.expand("~") .. "/personalProject/send-db/.venv/bin/send-db"

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

-- Sync board data for a given date (defaults to today) into the session note.
-- Runs send-db async so Neovim stays responsive; reloads the buffer on success.
M.sync_board_data = function(date_str)
  date_str = date_str or os.date("%Y-%m-%d")

  if vim.fn.executable(SEND_DB) == 0 then
    vim.notify("send-db not found at " .. SEND_DB, vim.log.levels.ERROR)
    return
  end

  vim.notify("Syncing board data for " .. date_str .. "…", vim.log.levels.INFO)

  local output = {}
  vim.fn.jobstart({ SEND_DB, "sync", "--date", date_str }, {
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then table.insert(output, line) end
      end
    end,
    on_stderr = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          vim.notify(line, vim.log.levels.WARN)
        end
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        -- Reload the buffer so the injected table appears immediately
        vim.schedule(function()
          vim.cmd("checktime")
          local summary = table.concat(output, " | ")
          vim.notify("✓ " .. summary, vim.log.levels.INFO)
        end)
      else
        vim.notify("send-db sync failed (exit " .. code .. ")", vim.log.levels.ERROR)
      end
    end,
  })
end

-- Open today's note AND sync board data in one shot.
M.open_and_sync = function()
  M.open_training_note()
  M.sync_board_data()
end

return M
