--- Proto module for encoding/decoding protobuf messages
--- The module parses proto files and provides functions to encode/decode messages
--- The module also provides a way to get a new instance of the message with default values
--- This also can "verify" a table to match the proto message

local proto_internal = require("proto.proto_internal")

local MAP = "map"
local VALUE = "value"
local MESSAGE = "message"
local REPEATED = "repeated"
local OPTIONAL = "optional"
local SKIP_DEFAULT_NEST_MESSAGES = sys.get_config_int("proto.skip_default_nest_messages", 0) == 1

---@class proto
local M = {}


---Loads proto files from the specified paths in the game.project
---Under the "proto.proto_paths" key in the game.project
---@param proto_config_or_path table|string Lua table or path to proto list config. Example: "/resources/proto.json"
function M.init(proto_config_or_path)
	proto_internal.load_config(proto_config_or_path)
end


---Set the logger instance
---@param logger_instance proto.logger|nil
function M.set_logger(logger_instance)
	proto_internal.logger = logger_instance or proto_internal.empty_logger
end


---Create a new instance of the proto message
---@param proto_type string @The full proto message name (e.g. "game.data", where game is package and data is message name)
---@return table
function M.get(proto_type)
	return M.decode(proto_type, nil)
end


---Encode data to bytes
---@param proto_type string @The full proto message name (e.g. "game.data", where game is package and data is message name)
---@param data table @The data to encode
---@return string
function M.encode(proto_type, data)
	return pb.encode(proto_type, data)
end


---Decode bytes to lua table
---@param proto_type string @The full proto message name (e.g. "game.data", where game is package and data is message name)
---@param bytes string|nil @The bytes to decode
---@return table
function M.decode(proto_type, bytes)
	local data = pb.decode(proto_type, bytes)

	-- Fill nested messages with default values
	-- Add default fields even in repeated and map fields
	if not SKIP_DEFAULT_NEST_MESSAGES then
		M.update_with_default_messages(proto_type, data)
	end

	return data
end


---Verify data to match the proto_type. Return data with all default values according to proto_type, remove extra fields
---@param proto_type string @The full proto message name (e.g. "game.data", where game is package and data is message name)
---@param data table @The data to verify
---@return table
function M.verify(proto_type, data)
	local encoded = M.encode(proto_type, data)
	return M.decode(proto_type, encoded)
end


---Update data to match the proto_type.
---  - All default values will be added to the data if they are not present
---  - All extra fields will be removed from the data
---@param proto_type string @The full proto message name (e.g. "game.data", where game is package and data is message name)
---@param data table @The data to update
function M.update_with_default_messages(proto_type, data)
	for name in pb.fields(proto_type) do
		local _, _, type, _, label = pb.field(proto_type, name)
		local _, _, field_type = pb.type(type)

		if field_type == MESSAGE then
			-- Nest messages
			if label == OPTIONAL then
				if not data[name] then
					data[name] = M.get(type)
				else
					data[name] = M.decode(type, M.encode(type, data[name]))
				end
			end

			-- Repeated list
			if label == REPEATED then
				for k, v in pairs(data[name]) do
					data[name][k] = M.decode(type, M.encode(type, v))
				end
			end
		end

		-- Repeated map (key-value)
		-- In repeated map we should get value inside Entry
		if field_type == MAP then
			if label == REPEATED then
				for k, v in pairs(data[name]) do
					local _, _, repeated_type = pb.field(type, VALUE)
					local _, _, field_repeated_type = pb.type(repeated_type)

					if field_repeated_type == MESSAGE then
						data[name][k] = M.decode(repeated_type, M.encode(repeated_type, v))
					end
				end
			end
		end
	end
end


return M
