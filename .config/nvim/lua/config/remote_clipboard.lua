-- Clipboard for sessions whose yanks may need to reach another machine:
-- every copy is emitted as OSC 52 (inside tmux this becomes a tmux buffer,
-- rebroadcast to every attached client, local or SSH). Paste prefers the
-- local clipboard when one is available -- wl-clipboard on Wayland,
-- pbcopy/pbpaste on macOS -- so content copied in other apps remains
-- pasteable; without one, paste is an OSC 52 query that tmux (or the
-- terminal) answers.
local M = {}

local function proc_lines(pid, file)
  local ok, lines = pcall(vim.fn.readfile, "/proc/" .. pid .. "/" .. file)
  return ok and lines or {}
end

local function proc_ppid(pid)
  for _, line in ipairs(proc_lines(pid, "status")) do
    local ppid = line:match("^PPid:%s+(%d+)")
    if ppid then
      return tonumber(ppid)
    end
  end
end

-- Walks /proc, so this is Linux-only; on macOS every lookup misses and we
-- fall back to the HERDR_PANE_ID environment check alone.
local function ancestor_process_named(name)
  local pid = vim.fn.getpid()

  for _ = 1, 16 do
    local ppid = proc_ppid(pid)
    if not ppid or ppid <= 1 then
      return false
    end

    local comm = proc_lines(ppid, "comm")[1] or ""
    if comm:find(name, 1, true) then
      return true
    end

    pid = ppid
  end

  return false
end

-- The local clipboard tool, when one is reachable. Returns builders for the
-- copy and paste argv, or nil on a headless Linux box where OSC 52 is all
-- we have.
local function local_clipboard()
  local has_wayland = vim.env.WAYLAND_DISPLAY ~= nil
    and vim.fn.executable("wl-copy") == 1
    and vim.fn.executable("wl-paste") == 1

  if has_wayland then
    return {
      copy = function(register)
        local cmd = { "wl-copy", "--sensitive", "--type", "text/plain" }
        if register == "*" then
          cmd[#cmd + 1] = "--primary"
        end
        return cmd
      end,
      paste = function(register)
        local cmd = { "wl-paste", "--no-newline" }
        if register == "*" then
          cmd[#cmd + 1] = "--primary"
        end
        return cmd
      end,
    }
  end

  -- macOS has a single pasteboard and no primary selection, so "*" and "+"
  -- both map onto it.
  local has_pbcopy = vim.fn.has("mac") == 1
    and vim.fn.executable("pbcopy") == 1
    and vim.fn.executable("pbpaste") == 1

  if has_pbcopy then
    return {
      copy = function()
        return { "pbcopy" }
      end,
      paste = function()
        return { "pbpaste" }
      end,
    }
  end
end

function M.setup()
  local in_tmux = vim.env.TMUX ~= nil
  local in_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
  local in_herdr = vim.env.HERDR_PANE_ID ~= nil or ancestor_process_named("herdr")

  if not (in_tmux or in_ssh or in_herdr) then
    return
  end

  local osc52 = require("vim.ui.clipboard.osc52")
  local clipboard = local_clipboard()

  local function copy(register)
    local emit = osc52.copy(register)

    return function(lines)
      if clipboard then
        vim.fn.system(clipboard.copy(register), lines)
      end

      if vim.g.omarchy_remote_clipboard_osc52 ~= false then
        emit(lines)
      end
    end
  end

  local function paste(register)
    if not clipboard then
      return osc52.paste(register)
    end

    return function()
      local lines = vim.fn.systemlist(clipboard.paste(register), "", 1)
      return vim.v.shell_error == 0 and lines or {}
    end
  end

  vim.g.clipboard = {
    name = "OmarchyRemoteClipboard",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
    cache_enabled = 0,
  }
end

return M
