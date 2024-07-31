local M = {}

local number_types = {1, 2, 3, 4, 5, 6, 7, 13, 15, 16, 17, 18}
local bool_types = {8}
local string_types = {9, 12}
local message_types = {11}
local enum_types = {14}

local map_mapping = {}


local function contains(t, value)
	for i = 1, #t do
		if t[i] == value then
			return true
		end
	end

	return false
end


local function get_sorted_keys(t)
	local keys = {}

	for key, _ in pairs(t) do
		table.insert(keys, key)
	end

	table.sort(keys)

	return keys
end


local function get_map_mapping(map_fields)
	local data = {}

	for i = 1, #map_fields do
		local field = map_fields[i]

		if field.name == "key" then
			data.key = field.field_type
		end

		if field.name == "value" then
			data.value = field.field_type
		end
	end

	return data
end


local function get_field_type(field)
	if contains(number_types, field.type) then
		return "number"
	end

	if contains(bool_types, field.type) then
		return "boolean"
	end

	if contains(string_types, field.type) then
		return "string"
	end

	if contains(enum_types, field.type) then
		return "enum"
	end

	if contains(message_types, field.type) then
		local type_name = field.type_name
		if type_name:sub(1, 1) == "." then
			type_name = type_name:sub(2, #type_name)
		end
		return type_name
	end

	return "unknown"
end


local function append_fields(fields_data, fields)
	if not fields then
		return
	end

	for i = 1, #fields do
		local field = fields[i]
		local field_type = get_field_type(field)
		local is_repeated = field.label == 3
		table.insert(fields_data, {
			name = field.name,
			field_type = field_type,
			default = field.default_value,
			is_repeated = is_repeated
		})
	end
end


local function append_class(filedata, prototypes, package)
	package = package or ""

	for i = 1, #prototypes do
		local class = prototypes[i]
		local class_package = package .. class.name

		filedata[class_package] = { name = class_package, fields = {}}
		append_fields(filedata[class_package].fields, class.field)

		if class.options and class.options.map_entry then
			local map_fields = filedata[class_package].fields
			map_mapping[class_package] = get_map_mapping(map_fields)
			filedata[class_package] = nil
		end

		if class.nested_type then
			append_class(filedata, class.nested_type, class_package .. ".")
		end
	end
end


local function generate_annotations_data(loaded)
	local files = {}

	for filename, prototypes in pairs(loaded) do
		files[filename] = {}

		local package = ""
		if prototypes.package then
			package = prototypes.package .. "."
		end
		append_class(files[filename], prototypes.message_type, package)
	end

	return files
end


local function format_annotation_data(files)
	local s = ""

	local sorted_files = get_sorted_keys(files)

	for i = 1, #sorted_files do
		local filename = sorted_files[i]
		local data = files[filename]
		s = s .. "\n--======== File: " .. filename .. " ========--\n"

		local sorted_class = get_sorted_keys(data)
		for j = 1, #sorted_class do
			local class_name = sorted_class[j]
			local class_data = data[class_name]
			s = s .. "---@class " .. class_name .. "\n"

			table.sort(class_data.fields, function(a, b) return a.name < b.name end)
			for k = 1, #class_data.fields do
				local field = class_data.fields[k]

				local field_type = field.field_type
				-- Field type: Map
				if map_mapping[field_type] then
					local d = map_mapping[field_type]
					field_type = "table<" .. d.key .. ", " .. d.value .. ">"
				else
					-- Field type: Array of field_type
					if field.is_repeated then
						field_type = field_type .. "[]"
					end
				end

				local comment = ""
				if field.default then
					comment = " Default: " .. field.default
				end

				s = s .. "---@field " .. field.name .. " " .. field_type .. comment .. "\n"
			end
			s = s .. "\n"
		end
	end

	-- Remove first empty line
	s = s:sub(2, #s)

	return s
end


function M.generate(loaded)
	local data = generate_annotations_data(loaded)
	return format_annotation_data(data)
end


return M
