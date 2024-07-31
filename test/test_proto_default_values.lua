return function()
	local proto = {} --[[@as proto]]

	describe("Defold Proto Init", function()
		before(function()
			proto = require("proto.proto")
			proto.init("/resources/proto.json")
		end)

		it("Default values should be set on proto.get", function()
			local game_data = proto.get("game.test") --[[@as game.test]]
			assert(game_data.string_default_value == "default_value_from_proto")
			assert(game_data.uint32_default_value == 42)
			assert(game_data.double_default_value == 3.14)
		end)

		it("Default values should be set on verify if not exists", function()
			local game_data = proto.get("game.test") --[[@as game.test]]
			local verified_data = proto.verify("game.test", game_data)
			assert(verified_data.string_default_value == "default_value_from_proto")
			assert(verified_data.uint32_default_value == 42)
			assert(verified_data.double_default_value == 3.14)
		end)

		it("Default values should not remove existing fields on verify", function()
			local game_data = proto.get("game.test") --[[@as game.test]]
			game_data.string_default_value = "new_value"
			game_data.uint32_default_value = 1
			game_data.double_default_value = 1.1
			local verified_data = proto.verify("game.test", game_data)
			assert(verified_data.string_default_value == "new_value")
			assert(verified_data.uint32_default_value == 1)
			assert(verified_data.double_default_value == 1.1)
		end)
	end)
end
