--ПСЕВДОГРАФИЧЕСКАЯ БИБЛИОТЕКА
local draw={}

--методы текста
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

--методы рисования
function draw:rectangle(_x,_y,_w,_h,_type,_color,_origin_color)
	gpu.setBackground(_color)
	if _type == 1 then
		function d1()
		gpu.fill(_x, _y, _w, _h, ' ')
		gpu.setBackground(_origin_color)
		end
		return d1()
	else
		function d2()
		gpu.fill(_x, _y, _w, 1, ' ')
		gpu.fill(_x, _y, 1, _h, ' ')
		gpu.fill(_x, _y+_h-1, _w, 1, ' ')
		gpu.fill(_x+_w-1, _y, 1, _h, ' ')		
		gpu.setBackground(_origin_color)
		end
		return d2()
	end
end

return draw