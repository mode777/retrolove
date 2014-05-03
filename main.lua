ENGINE_PATH = "engine" --change if you rename the cinemotion folder
local engine = require(ENGINE_PATH) --local is optional here
engine.registerCallbacks() --take over love's callback functions. Declaring your own will break the engine.
