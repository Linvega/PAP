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
origin_backcolor = gpu.getForeground() --сохраняем стандартные цвета консоли
origin_textcolor = gpu.getBackground()
--


--БЛОК ЦВЕТОВОЙ ПАЛИТРЫ
white = 0xffffff 
black = 0x000000
red = 0xff0000
--

--ПЕРВИЧНАЯ НАСТРОЙКА ИНТЕРФЕЙСА

gpu.setForeground(black)
gpu.setBackground(white)
  
if term.clear() ~= nil then --ОЧИСТКА ОКНА
	term.clear()
end
--

--БЛОК СОЗДАНИЯ ПСЕВДОКЛАССОВ
function class_ini () 
	function class_button()
		button={}
		

		--local general_status

		function button:new(_x,_y,_w,_h,_text)
			local obj = {}
			
			obj.visible = false
			obj.x = _x
			obj.y = _y
			obj.w = _w
			obj.h = _h
			obj.t_color = black 
			obj.b_color = white
			obj.text = _text
			obj.action = function()
			end
			
			setmetatable(obj,self)
			self.__index = self
			return obj
		end
		
		function button:draw_button()
			gpu.setBackground(self.t_color)
			gpu.setForeground(self.b_color)
			gpu.fill(self.x,self.y,self.w,self.h," ")
			gpu.set(self.x+self.w/2-(#self.text)/2,self.y+self.h/2,self.text)
			gpu.setBackground(self.b_color)
			gpu.setForeground(self.t_color)
		end
		
		function button:get_x()
			return self.x;
		end
		
		function button:get_y()
			return self.y;
		end
		
		function button:get_w()
			return self.w;
		end
		
		function button:get_h()
			return self.h;
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
button_exit = button:new(m_weight/2-5,m_height/2+2,11,3,"EXIT^")
button_exit.action = function()
	gpu.setForeground(white)
	gpu.setBackground(black)
	gpu.fill(1, 1, m_weight, m_height, ' ')
	os.exit()
end

button_start = button:new(m_weight/2-5,m_height/2-2,11,3,"START")

--button_start.visible = true
button_start.action = function()
	gpu.setForeground(white)
	gpu.setBackground(black)
	gpu.fill(1, 1, m_weight, m_height, ' ')
	os.exit()
end

--

--ОСНОВНОЕ ТЕЛО ПРОГРАММЫ
while true do
--energy = c.solar_panel.getEnergyStored()
--max_energy = c.solar_panel.getMaxEnergyStored()

if general_status == 0 then
draw:text_align(1, m_height/2-4, 1, 0, "WELCOME TO PAP!")
button_start:draw_button()
button_exit:draw_button()
end
local tEvent = {e_pull('touch')}
if tEvent[3] >= button_start:get_x() and tEvent[3] <= button_start:get_x()+button_start:get_w() and tEvent[4] >= button_start:get_y() and tEvent[4] <= button_start:get_y()+button_start:get_h() then 
button_start:action()
end
if tEvent[3] >= button_exit:get_x() and tEvent[3] <= button_exit:get_x()+button_exit:get_w() and tEvent[4] >= button_exit:get_y() and tEvent[4] <= button_exit:get_y()+button_exit:get_h() then 
button_exit:action()
end

end