local M = {}

-- Function to apply typos fix at cursor position
function M.apply_typos_fix()
  local diagnostics = vim.diagnostic.get(0, { source = "typos" })
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1 -- Convert to 0-indexed
  local col = cursor[2]

  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.lnum == line and col >= diagnostic.col and col <= diagnostic.end_col then
      local suggestion = diagnostic.message:match("'[^']+' should be '([^']+)'")
      if suggestion then
        -- Replace the word with the suggestion
        local start_col = diagnostic.col
        local end_col = diagnostic.end_col
        local current_line = vim.api.nvim_buf_get_lines(0, line, line + 1, false)[1]
        local new_line = current_line:sub(1, start_col) .. suggestion .. current_line:sub(end_col + 1)
        vim.api.nvim_buf_set_lines(0, line, line + 1, false, { new_line })
        print("Applied fix: " .. suggestion)
        return
      end
    end
  end

  print("No typos suggestion found at cursor position")
end

-- Function to fix all typos in the current buffer
function M.fix_all_typos()
  local diagnostics = vim.diagnostic.get(0, { source = "typos" })

  if #diagnostics == 0 then
    print("No typos found in file")
    return
  end

  -- Sort in reverse order (bottom to top) so line/col offsets remain valid after edits
  table.sort(diagnostics, function(a, b)
    if a.lnum ~= b.lnum then return a.lnum > b.lnum end
    return a.col > b.col
  end)

  local fixed = 0
  for _, diagnostic in ipairs(diagnostics) do
    local suggestion = diagnostic.message:match("'[^']+' should be '([^']+')")
    if suggestion then
      local line = diagnostic.lnum
      local current_line = vim.api.nvim_buf_get_lines(0, line, line + 1, false)[1]
      local new_line = current_line:sub(1, diagnostic.col) .. suggestion .. current_line:sub(diagnostic.end_col + 1)
      vim.api.nvim_buf_set_lines(0, line, line + 1, false, { new_line })
      fixed = fixed + 1
    end
  end

  print("Fixed " .. fixed .. " typo(s)")
end

return M
