--[[ОПИСАНИЕ
Программа программируемой автоматизации - Programmable Automation program (PAP)
Ver 0.0
	]]
	
--БЛОК ПОДКЛЮЧЕНИЯ БИБЛИОТЕК
c = require("component")
term = require("term")
e_pull = require('event').pull
unicode = require("unicode")
draw = require('draw')
computer = require('computer')
--


--БЛОК СТАНДАРТНЫХ ПЕРЕМЕННЫХ
gpu = c.gpu --подключаем видеокарту
m_weight, m_height = gpu.getResolution() --записываем длину и ширину монитора
general_status = 0 --статус активного окна
--


--БЛОК ЦВЕТОВОЙ ПАЛИТРЫ
white = 0x000000 
black = 0xffffff
--

--ПЕРВИЧНАЯ НАСТРОЙКА ИНТЕРФЕЙСА

gpu.setForeground(white)
gpu.setBackground(black)
  
if term.clear() ~= nil then --ОЧИСТКА ОКНА
	term.clear()
end
--

--БЛОК СОЗДАНИЯ ПСЕВДОКЛАССОВ
function class_ini () 
	function class_button()
		button={}
		button.__index = button
		
		local visible = false
		local x,y,w,h
		local b_color, t_color = black, white
		local text = "button "
		local action 
		--local general_status

		function button:new(_id,_x,_y,_w,_h,_text)
			local obj = {id = _id}
			setmetatable(obj,self)
			text = _text
			x,y,w,h = _x,_y,_w,_h
			return obj
		end
		
		function button:draw_button()
			gpu.setBackground(t_color)
			gpu.setForeground(b_color)
			gpu.fill(x,y,w,h," ")
			gpu.set(x+w/2-(#text)/2,y+h/2,text)
			gpu.setBackground(b_color)
			gpu.setForeground(t_color)
		end
		
		function button:get_x()
			return x;
		end
		
		function button:get_y()
			return y;
		end
		
		function button:get_w()
			return w;
		end
		
		function button:get_h()
			return h;
		end
		

	end
	
-- ПОДКЛЮЧЕНИЕ ВСЕХ КЛАССОВ - ДУБЛИРВОАНИЕ ИМЁН ФУНКЦИЙ
	class_button()
	
end
--

--ИНИЦИАЛИЗАЦИЯ ВСЕХ КЛАССОВ
class_ini() 
--

--БЛОК СОЗДАНИЯ ОБЪЕКТОВ
--[[  ГАЙД ПО КНОПКАМ
для корректного выравнивания кнопок:
высота -- НЕЧЁТНАЯ > 1
ширина -- >= ДЛИНА СЛОВА, НЕЧЁТНОЕ СЛОВО - ЧЁТНАЯ ДЛИНА И НАОБОРОТ  
]]
--button_exit = button:new(1)
button_start = button:new(2,3,3,11,3,"START") 

button_start.visible = true
button_start.action = function()
	computer.shutdown(true)
end

--


--ОСНОВНОЕ ТЕЛО ПРОГРАММЫ
while true do
--energy = c.solar_panel.getEnergyStored()
--max_energy = c.solar_panel.getMaxEnergyStored()

if general_status == 0 then
draw:text_align(1, 1, 1, 1, "WELCOME TO PAP!")
button_start.draw_button()
end
local tEvent = {e_pull('touch')}
if tEvent[3] >= button_start.get_x() and tEvent[3] <= button_start.get_x()+button_start.get_w() and tEvent[4] >= button_start.get_y() and tEvent[4] <= button_start.get_y()+button_start.get_h() then 
button_start.action()
end

end