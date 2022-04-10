--ПСЕВДОГРАФИЧЕСКАЯ БИБЛИОТЕКА
local draw={}

function draw:text(_x,_y,_text)
	return gpu.set(_x,_y,_text)
end

function draw:text_align(_x,_y,_p1,_p2,_text)
	local m_w, m_h = gpu.getResolution()
	local text_len = #_text
	local position_x = _x
	local position_y = _y
	if _p1 == 1 then
		position_x = math.ceil((m_w - text_len)/2)
	end
	if _p2 == 1 then 
		position_y = math.ceil(m_h/2)
	end
	return gpu.set(position_x, position_y, _text)
end



return draw