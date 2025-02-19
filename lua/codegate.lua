local curl = require("plenary.curl")
local M = {}

print("Plugin loaded successfully")

-- Default options.
M.opts = {
  base_url = "http://127.0.0.1:8989",
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

--- Single error handling function for API calls.
--- @param operation string: A short description of the operation that failed.
--- @param res table: The curl response object.
--- @param workspace string|nil: The workspace name, if applicable.
local function handle_error(operation, res, workspace)
  local target = workspace and string.format("workspace '%s'", workspace) or "request"
  local detail = nil
  local ok, decoded = pcall(vim.fn.json_decode, res.body)
  if ok and decoded and decoded.detail then
    detail = decoded.detail
  end
  if detail then
    print(string.format("Error %s %s: %s", operation, target, detail))
  else
    print(string.format("Error %s %s. HTTP status: %d", operation, target, res.status))
  end
end

--- API call: GET /api/v1/workspaces.
--- @return table|nil: The decoded JSON response on success or nil on error.
local function api_get_workspaces()
  local url = get_base_url() .. "/api/v1/workspaces"
  local res = curl.get(url, { timeout = 5000 })
  if res.status ~= 200 then
    handle_error("listing", res, nil)
    return nil
  end
  local ok, decoded = pcall(vim.fn.json_decode, res.body)
  if not ok then
    print("Error decoding JSON response")
    return nil
  end
  return decoded
end

--- API call: POST /api/v1/workspaces/active.
--- @param workspace string: The workspace name to activate.
--- @return table: The curl response object.
local function api_set_workspace(workspace)
  local url = get_base_url() .. "/api/v1/workspaces/active"
  local payload = { name = workspace }
  return curl.post(url, {
    headers = { ["Content-Type"] = "application/json" },
    body = vim.fn.json_encode(payload),
    timeout = 5000,
  })
end

--- List workspaces by calling the API and printing the results.
function M.list_workspaces()
  local decoded = api_get_workspaces()
  if not decoded or not decoded.workspaces then
    print("No workspaces found or unexpected response.")
    return
  end
  print("Workspaces:")
  for i, ws in ipairs(decoded.workspaces) do
    local active = ws.is_active and "[active]" or ""
    print(string.format("%d. %s %s", i, ws.name, active))
  end
end

--- Set (activate) a workspace by name.
--- @param workspace string: The workspace name to activate.
function M.set_workspace(workspace)
  local res = api_set_workspace(workspace)
  if res.status ~= 200 and res.status ~= 204 then
    handle_error("setting", res, workspace)
    return
  end
  print(string.format("Workspace '%s' activated successfully.", workspace))
end

--- Telescope integration: fuzzy-search workspaces and activate the selected one.
--- This function requires Telescope to be installed.
function M.telescope_codegate_workspace()
  local has_telescope, pickers = pcall(require, "telescope.pickers")
  if not has_telescope then
    print("Telescope is not installed. Please install telescope to use this feature.")
    return
  end

  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local decoded = api_get_workspaces()
  if not decoded or not decoded.workspaces then
    print("No workspaces found.")
    return
  end

  local entries = {}
  for _, ws in ipairs(decoded.workspaces) do
    table.insert(entries, ws.name)
  end

  pickers.new({}, {
    prompt_title = "Select CodeGate Workspace",
    finder = finders.new_table({ results = entries }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        M.set_workspace(selection[1])
      end)
      return true
    end,
  }):find()
end

return M
