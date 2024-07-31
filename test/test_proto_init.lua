return function()
	local proto = {} --[[@as proto]]

	describe("Defold Proto Init", function()
		before(function()
			proto = require("proto.proto")
		end)

		it("Should log error if no config specified", function()
			local is_error = false
			local logger = {
				trace = function() end,
				debug = function() end,
				info = function() end,
				warn = function() end,
				error = function() is_error = true end,
			}
			proto.set_logger(logger)
			proto.init()

			assert(is_error)
		end)
	end)
end
