return {
  "mfussenegger/nvim-lint",
  opts = function(_, opts)
    -- Configure typos linter
    opts.linters = opts.linters or {}
    opts.linters.typos = {
      cmd = "typos",
      stdin = false,
      append_fname = true,
      args = { "--config", vim.fn.stdpath("config") .. "/typos.toml", "--format", "brief" },
      stream = "stdout",
      ignore_exitcode = true,
      parser = function(output, bufnr)
        local diagnostics = {}

        for line in output:gmatch("[^\r\n]+") do
          -- Handle both stdin format (-:line:col:) and file format (filename:line:col:)
          local row, col, severity, word, suggestion = 
            line:match("^[^:]*:(%d+):(%d+): (%w+): `([^`]+)` should be `([^`]+)`")

          if row and col and word and suggestion then
            table.insert(diagnostics, {
              lnum = tonumber(row) - 1, -- nvim is 0-indexed
              col = tonumber(col) - 1, -- nvim is 0-indexed
              end_col = tonumber(col) - 1 + #word,
              severity = severity == "error" and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
              message = string.format("'%s' should be '%s'", word, suggestion),
              source = "typos",
            })
          end
        end

        return diagnostics
      end,
    }

    -- Configure linters by filetype - extend existing configurations
    opts.linters_by_ft = opts.linters_by_ft or {}
    
    -- Add typos to existing linter lists or create new ones
    local filetypes = {
      "python", "typescript", "typescriptreact", "javascript", "javascriptreact",
      "markdown", "text", "html", "css", "yaml", "json"
    }
    
    for _, ft in ipairs(filetypes) do
      if opts.linters_by_ft[ft] then
        -- Add typos if not already present
        if not vim.tbl_contains(opts.linters_by_ft[ft], "typos") then
          table.insert(opts.linters_by_ft[ft], "typos")
        end
      else
        opts.linters_by_ft[ft] = { "typos" }
      end
    end

    -- Override markdownlint-cli2 to use our config
    opts.linters["markdownlint-cli2"] = {
      cmd = "markdownlint-cli2",
      stdin = false,
      append_fname = true,
      args = { "--config", vim.fn.stdpath("config") .. "/.markdownlint-cli2.jsonc" },
      stream = "stdout",
      ignore_exitcode = true,
      parser = function(output, bufnr)
        local diagnostics = {}
        local lines = vim.split(output, "\n")
        
        for _, line in ipairs(lines) do
          if line:match("^.+:%d+") then
            local file, row, col, rule, msg = line:match("^(.-):(%-?%d+):?(%d*):? (.-%/.+) (.+)")
            if not rule then
              file, row, rule, msg = line:match("^(.-):(%-?%d+) (.-%/.+) (.+)")
              col = 1
            end
            
            if row and rule and msg then
              table.insert(diagnostics, {
                lnum = math.max(0, tonumber(row) - 1),
                col = col and math.max(0, tonumber(col) - 1) or 0,
                end_col = col and math.max(0, tonumber(col) - 1) or 0,
                severity = vim.diagnostic.severity.WARN,
                message = msg,
                code = rule,
                source = "markdownlint-cli2",
              })
            end
          end
        end
        
        return diagnostics
      end,
    }

    return opts
  end,
}
