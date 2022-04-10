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
white = 0xffffff 
black = 0x000000
red = 0xff0000
--

--ПЕРВИЧНАЯ НАСТРОЙКА ИНТЕРФЕЙСА
origin_backcolor = black --сохраняем стандартные цвета консоли
origin_textcolor = white

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

		function button:new(_id,_gs,_x,_y,_w,_h,_text)
			local obj = {}
			
			obj.id = _id
			obj.g_status = _gs
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
		
		function get_general_status()
			return self.g_status;
		end

	end
	
-- ПОДКЛЮЧЕНИЕ ВСЕХ КЛАССОВ - ДУБЛИРВОАНИЕ ИМЁН ФУНКЦИЙ
	class_button()
	
end
--

--ИНИЦИАЛИЗАЦИЯ ВСЕХ КЛАССОВ
class_ini() 
--

--ФУНКЦИЯ РЕВЁРСА ОСНОВНЫХ ЦВЕТОВ ПАЛИТРЫ
function rev_color(_vol)
if _vol == 0 then 	--основной
	gpu.setBackground(white)
	gpu.setForeground(black)
else			  	--обратный
	gpu.setBackground(black)
	gpu.setForeground(white)
end
end
--

--ФУНКЦИЯ ПРИСВОЕНИЯ ID
--ПРОВЕРЯЕТ ЗАДАННЫЙ МАССИВ ОБЪЕКТОВ И ПРИСВАЕТ НОВЫЙ ID
function set_id(_arr)
	return #_arr+1
end
--

--БЛОК СОЗДАНИЯ ОБЪЕКТОВ
--[[  ГАЙД ПО КНОПКАМ
для корректного выравнивания кнопок:
высота -- НЕЧЁТНАЯ > 1
ширина -- >= ДЛИНА СЛОВА, НЕЧЁТНОЕ СЛОВО - ЧЁТНАЯ ДЛИНА И НАОБОРОТ  
]]
b_ = {} --массивк кнопок
id = set_id(b_)
b_[id] = button:new(id,0,m_weight/2-5,m_height/2+2,11,3,"EXIT^")
b_[id].action = function()
    rev_color(1)
	gpu.fill(1, 1, m_weight, m_height, ' ')
	os.exit()
end

id = set_id(b_)
b_[id] = button:new(id,0,m_weight/2-5,m_height/2-2,11,3,"START")
b_[id].action = function()
	general_status = 1
    rev_color(0)
	gpu.fill(1, 1, m_weight, m_height, ' ')	
end
--

--ОСНОВНОЕ ТЕЛО ПРОГРАММЫ
while true do
--energy = c.solar_panel.getEnergyStored()
--max_energy = c.solar_panel.getMaxEnergyStored()
if general_status == 0 then
draw:text_align(1, m_height/2-4, 1, 0, "WELCOME TO PAP!")
end
if general_status == 1 then
	draw:text_align(1,1, 1, 0, "Control Panel")
	rev_color(1)
	draw:rectangle(1, 2, m_weight, 1, 1, black, white)	
	draw:rectangle(4, 4, 10, 10, 0, black, white)	
	rev_color(0)
end
for i = 1, #b_ do
	if b_[i].g_status == general_status then
		b_[i]:draw_button()
	end
end
local tEvent = {e_pull('touch')}
for i = 1, #b_ do
	if b_[i].g_status == general_status then
		if tEvent[3] >= b_[i]:get_x() and tEvent[3] <= b_[i]:get_x()+b_[i]:get_w() and tEvent[4] >= b_[i]:get_y() and tEvent[4] <= b_[i]:get_y()+b_[i]:get_h() then 
			b_[i]:action()
		end
	end
end

end