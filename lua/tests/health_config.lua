local M = {}

local function fail(message) error(message, 0) end

local function expect(condition, message)
  if not condition then fail(message) end
end

function M.run()
  package.loaded['plugins_config/health'] = nil
  package.loaded['plugins_config.health'] = nil

  local seen = {
    ok = {},
    warn = {},
  }

  vim.health = {
    start = function() end,
    info = function() end,
    ok = function(message)
      seen.ok[#seen.ok + 1] = message
    end,
    warn = function(message)
      seen.warn[#seen.warn + 1] = message
    end,
    error = function() end,
  }

  local version_fn = function() return { major = 0, minor = 11, patch = 0 } end
  vim.version = setmetatable({}, {
    __call = function()
      return version_fn()
    end,
    __index = {
      ge = function() return true end,
    },
  })
  vim.inspect = function(value) return tostring(value) end
  vim.uv = {
    os_uname = function() return { sysname = 'Linux' } end,
  }

  vim.fn.executable = function(exe)
    if exe == 'staticcheck' then return 0 end
    return 1
  end

  local health = require 'plugins_config/health'
  health.check()

  local warned_staticcheck = false
  for _, message in ipairs(seen.warn) do
    if message:find("staticcheck", 1, true) then
      warned_staticcheck = true
      break
    end
  end

  expect(warned_staticcheck, 'health check did not mention missing staticcheck')
  print 'Health config tests passed'
end

return M
