local protoc = require("proto.protoc")

local M = {}

--- Use empty function to save a bit of memory
local EMPTY_FUNCTION = function(_, message, context) end

---@type proto.logger
M.empty_logger = {
	trace = EMPTY_FUNCTION,
	debug = EMPTY_FUNCTION,
	info = EMPTY_FUNCTION,
	warn = EMPTY_FUNCTION,
	error = EMPTY_FUNCTION,
}

---@type proto.logger
M.logger = {
	trace = function(_, msg, data) pprint("TRACE: " .. msg, data) end,
	debug = function(_, msg, data) pprint("DEBUG: " .. msg, data) end,
	info = function(_, msg, data) pprint("INFO: " .. msg, data) end,
	warn = function(_, msg, data) pprint("WARN: " .. msg, data) end,
	error = function(_, msg, data) pprint("ERROR: " .. msg, data) end
}


---Load JSON file from game resources folder (by relative path to game.project)
---Return nil if file not found or error
---@param json_path string
---@return table|nil
function M.load_json(json_path)
	local resource, is_error = sys.load_resource(json_path)
	if is_error or not resource then
		return nil
	end

	return json.decode(resource)
end


---Load config from file or table
---@param config_or_path string|table
---@return boolean @True if success
function M.load_config(config_or_path)
	if not config_or_path then
		M.logger:error("No config provided")
		return false
	end

	if type(config_or_path) == "string" then
		local config = M.load_json(config_or_path)
		if not config then
			M.logger:error("Can't load config", config_or_path)
			return false
		end

		config_or_path = config
	end

	local config = config_or_path -- table<string, string[]>
	protoc.include_imports = true
	for folder_path, file_paths in pairs(config) do
		protoc:addpath(folder_path)
		for index = 1, #file_paths do
			local path = file_paths[index]
			M.logger:debug("Load protofile", folder_path .. "/" .. path)
			protoc:loadfile(path)
		end
	end

	return true
end


return M
