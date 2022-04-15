
--local event = require('event')
local keyboard = require('keyboard')

local pap_keyboard = {}
function pap_keyboard:get_key(_code)

	
	local code_key = tonumber(string.format("%s%X","0x", _code))
	local symbol = tostring(keyboard.keys[code_key])
	
	if string.len(symbol) > 1 then
	if symbol == "space" then symbol = " "
	elseif symbol == "lshift" then symbol = ""
	elseif symbol == "lcontrol" then symbol = ""
	elseif symbol == "rshift" then symbol = ""
	elseif symbol == "rcontrol" then symbol = ""
	elseif symbol == "comma" then symbol = ","
	elseif symbol == "period" then symbol = "."
	elseif symbol == "back" then symbol = "back"
	else symbol = ""
	end
	end
	
	
	return symbol
	
end

return pap_keyboard