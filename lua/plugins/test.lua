return {
  "vim-test/vim-test",
  config = function()
    -- Path to the Poetry-managed Python interpreter
    local python = vim.fn.expand("~/Library/Caches/pypoetry/virtualenvs/badger-go-5Azyc4AC-py3.12/bin/python")

    -- Set environment variables for Django TestCase
    vim.fn.setenv("PYTHONUNBUFFERED", "1")
    vim.fn.setenv("DJANGO_SETTINGS_MODULE", "badgermapping.settings_local")

    -- Set the Python interpreter to the Poetry virtualenv for both unit and Django tests
    vim.g["test#python#python_path"] = python

    -- Set test runner to pytest for unit tests (if using pytest)
    vim.g["test#python#runner"] = "pytest"
  end,
}
