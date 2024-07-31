--======== File: /resources/proto/game.proto ========--
---@class game.data
---@field feature_a feature_a.data
---@field id string
---@field number number

---@class game.test
---@field bool_default_value boolean Default: true
---@field double_default_value number Default: 3.14
---@field double_number number
---@field flag boolean
---@field id string
---@field inner game.test.inner_table
---@field map_inner table<string, game.test.inner_table>
---@field number number
---@field repeated_inner game.test.inner_table[]
---@field string_default_value string Default: default_value_from_proto
---@field uint32_default_value number Default: 42

---@class game.test.inner_table
---@field double_number number
---@field flag boolean
---@field id string
---@field inner_inner game.test.inner_table.inner_inner_table
---@field number number

---@class game.test.inner_table.inner_inner_table
---@field id string
---@field number number


--======== File: feature_a.proto ========--
---@class feature_a.data
---@field time number

