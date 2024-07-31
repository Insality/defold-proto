return function()
	local proto = {} --[[@as proto]]

	describe("Defold Proto", function()
		before(function()
			proto = require("proto.proto")
			proto.init("/resources/proto.json")
		end)

		it("Should proto.get return default table", function()
			local data = proto.get("game.test")
			assert(data)
			assert(data.id == "")
			assert(data.number == 0)
			assert(data.inner)
			assert(data.inner.inner_inner)
			assert(data.inner.inner_inner.id)
		end)

		it("Should proto.encode return encoded string", function()
			local data = proto.get("game.test")
			local encoded = proto.encode("game.test", data)
			assert(encoded)
			assert(#encoded > 0)
		end)

		it("Should proto.decode return decoded table", function()
			local data = proto.get("game.test")
			local encoded = proto.encode("game.test", data)
			local decoded = proto.decode("game.test", encoded)
			assert(decoded)
			assert(decoded.id == "")
			assert(decoded.number == 0)
			assert(decoded.inner)
			assert(decoded.inner.inner_inner)
			assert(decoded.inner.inner_inner.id)
		end)

		it("Should proto.verify return fully match to the proto message", function()
			local dirty_table = {
				id = "test",
				number = 1,
				some_value = "some_value",
				inner = {
					inner_inner = {
					}
				},
				repeated_inner = {
					{
						id = "repeated_inner_1",
						should_be_removed = "should_be_removed"
					},
					{
						id = "repeated_inner_2",
						should_be_removed = "should_be_removed"
					}
				},
				map_inner = {
					["first"] = {
						id = "map_inner_1",
						should_be_removed = "should_be_removed"
					},
					["second"] = {
						id = "map_inner_2",
						should_be_removed = "should_be_removed"
					}
				}
			}
			local verified = proto.verify("game.test", dirty_table)
			assert(verified)
			assert(verified.id == "test")
			assert(verified.number == 1)
			assert(not verified.some_value)
			assert(verified.inner)
			assert(verified.inner.inner_inner)
			assert(verified.inner.inner_inner.id)
			assert(verified.repeated_inner)
			assert(#verified.repeated_inner == 2)
			assert(verified.repeated_inner[1].id == "repeated_inner_1")
			assert(not verified.repeated_inner[1].should_be_removed)
			assert(verified.repeated_inner[2].id == "repeated_inner_2")
			assert(verified.repeated_inner[2].number == 0)
			assert(not verified.repeated_inner[2].should_be_removed)
			assert(verified.repeated_inner[2].number)

			assert(verified.map_inner)
			assert(verified.map_inner["first"])
			assert(verified.map_inner["first"].id == "map_inner_1")
			assert(verified.map_inner["first"].number == 0)
			assert(not verified.map_inner["first"].should_be_removed)
			assert(verified.map_inner["second"])
			assert(verified.map_inner["second"].id == "map_inner_2")
			assert(verified.map_inner["second"].number == 0)
			assert(not verified.map_inner["second"].should_be_removed)
		end)

		it("Should set custom logger", function()
			local is_called_error = false
			local logger = {
				trace = function() end,
				debug = function() end,
				info = function() end,
				warn = function() end,
				error = function() is_called_error = true end,
			}
			proto.set_logger(logger)
			proto.init("/resources/non_exist.json")
			assert(is_called_error)
		end)
	end)
end
