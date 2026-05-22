-- Set up PATH for .NET tools installed via mise. Resolve the install dir
-- dynamically so this works across machines and dotnet versions.
local mise_dotnet = vim.fn.trim(vim.fn.system({ "mise", "where", "dotnet" }))
if vim.v.shell_error == 0 and mise_dotnet ~= "" then
  vim.env.PATH = mise_dotnet .. ":" .. (vim.env.PATH or "")
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
