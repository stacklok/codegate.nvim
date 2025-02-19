local curl = require("plenary.curl")
local M = {}

print("Plugin loaded successfully")

-- Default options.
M.opts = {
  base_url = "http://127.0.0.1:8989"
}

--- Setup function to allow user configuration.
--- @param opts table: A table containing configuration options.
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

--- Helper function to get the base URL.
local function get_base_url()
  return M.opts.base_url
end

--- List workspaces by performing a GET request to /api/v1/workspaces.
function M.list_workspaces()
  local url = get_base_url() .. "/api/v1/workspaces"
  local res = curl.get(url, { timeout = 5000 })

  if res.status ~= 200 then
    print("Error fetching workspaces. HTTP status: " .. res.status)
    return
  end

  local ok, decoded = pcall(vim.fn.json_decode, res.body)
  if not ok then
    print("Error decoding JSON response")
    return
  end

  if decoded and decoded.workspaces then
    print("Workspaces:")
    for i, ws in ipairs(decoded.workspaces) do
      local active = ws.is_active and "[active]" or ""
      print(string.format("%d. %s %s", i, ws.name, active))
    end
  else
    print("Unexpected response format. Response was:")
    print(res.body)
  end
end

--- Set (activate) the workspace via a POST request to /api/v1/workspaces/active.
--- @param workspace string: The workspace name to activate.
function M.set_workspace(workspace)
  local url = get_base_url() .. "/api/v1/workspaces/active"
  local payload = { name = workspace }
  local res = curl.post(url, {
    headers = { ["Content-Type"] = "application/json" },
    body = vim.fn.json_encode(payload),
    timeout = 5000,
  })

  if res.status ~= 200 and res.status ~= 204 then
    print(string.format("Error setting workspace '%s'. HTTP status: %d", workspace, res.status))
    print(string.format("Response for workspace '%s': %s", workspace, res.body))
    return
  end

  print(string.format("Workspace '%s' activated successfully.", workspace))
end

return M
