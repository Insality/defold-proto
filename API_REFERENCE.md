# API Reference

## Table of Contents

- [Proto Function](#proto)
  - [proto.init()](#protoinit)
  - [proto.get()](#protoget)
  - [proto.encode()](#protoencode)
  - [proto.decode()](#protodecode)
  - [proto.verify()](#protoverify)
  - [proto.set_logger()](#protoset_logger)

## Proto

To start using the Proto module in your project, you first need to import it. This can be done with the following line of code:

```lua
local proto = require("proto.proto")
```

## Functions

**proto.init()**
---
```lua
proto.init(config_or_path)
```

This function initializes the Proto module by loading the proto files. You can pass a path to the JSON file with the list of proto files or a lua table with the same data.

- **Usage Example:**

```lua
proto.init("/resources/proto.json")
```

```lua
proto.init({
	["/resources/proto"]: {
		"game.proto"
	}
})
```

**proto.get()**
---
```lua
proto.get(proto_type)
```

This function returns a table with the proto data for the specified proto type.

- **Parameters:**
  - `proto_type`: The proto type to get the data for.

- **Return Value:**
  - A table with the proto data.

- **Usage Example:**

```lua
local proto_data = proto.get("game.data")
pprint(proto_data) -- { id = "", number = 0, flag = false, nested = { id = "", number = 0 } }
```

**proto.encode()**
---
```lua
proto.encode(proto_type, data)
```

This function encodes a table with data to a string.

- **Parameters:**
  - `proto_type`: The proto type to encode the data for.
  - `data`: The table with data to encode.

- **Return Value:**
  - A string with the encoded data.

- **Usage Example:**

```lua
local encoded = proto.encode("game.data", { id = "test", number = 1 })
print(encoded) -- "binary data"
```

**proto.decode()**
---
```lua
proto.decode(proto_type, [data])
```

This function decodes a string to a table with data.

- **Parameters:**
  - `proto_type`: The proto type to decode the data for.
  - `data` (optional): The string with the encoded data.

- **Return Value:**
  - A table with the decoded data.

- **Usage Example:**

```lua
local decoded = proto.decode("game.data", encoded)
pprint(decoded) -- { id = "test", number = 1, flag = false, nested = { id = "", number = 0 } }
```


**proto.verify()**
---
```lua
proto.verify(proto_type, data)
```

This function verifies a table with data to match the protocol buffer definition. If the table data does not match the definition, the missing fields are set to default values, and the extra fields are removed.

- **Parameters:**
  - `proto_type`: The proto type to verify the data for.
  - `data`: The table with data to verify.

- **Return Value:**
  - An updated table to match the protocol buffer definition.

- **Usage Example:**

```lua
local verified = proto.verify("game.data", { id = "test" })
pprint(verified) -- { id = "test", number = 0, flag = false, nested = { id = "", number = 0 } }
```


**proto.set_logger()**
---
Customize the logging mechanism used by proto. You can use **[Defold Log](https://github.com/Insality/defold-log)** library or provide a custom logger.

```lua
proto.set_logger(logger_instance)
```

- **Parameters:**
  - `logger_instance`: A logger object that follows the specified logging interface, including methods for `trace`, `debug`, `info`, `warn`, `error`. Pass `nil` to remove the default logger.

- **Usage Example:**

Using the [Defold Log](https://github.com/Insality/defold-log) module:
```lua
local log = require("log.log")
local proto = require("proto.proto")

proto.set_logger(log.get_logger("proto"))
```

Creating a custom user logger:
```lua
local logger = {
    trace = function(_, message, context) end,
    debug = function(_, message, context) end,
    info = function(_, message, context) end,
    warn = function(_, message, context) end,
    error = function(_, message, context) end
}
proto.set_logger(logger)
```

Remove the default logger:
```lua
proto.set_logger(nil)
```
