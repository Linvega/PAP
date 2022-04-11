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
deneral_status_old = 0

b_ = {} --глобальный массив кнопок

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
	function class_button() --
		button={} --класс кнопок

		function button:new(_id,_gs,_x,_y,_w,_h,_text)
			local obj = {}
			
			obj.id = _id
			obj.g_status = _gs
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
		
		function button:set_status(_num)
			self.g_status = _num
		end
		
		function button:set_values(_x,_y,_w,_h)
			self.x = _x
			self.y = _y
			self.w = _w
			self.h = _h
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
	
	function class_obj_list()
		obj_list={} --класс списка объектов (для выведения массива данных с возможностью обращения к записи)
		
		
		function obj_list:new(_id,_gs,_x,_y,_w,_h,_name)
			local obj = {}
			
			obj.id = _id
			obj.g_status = _gs
			obj.x = _x
			obj.y = _y
			obj.w = _w
			obj.h = _h
			obj.t_color = black 
			obj.b_color = white
			obj.name = _name
			obj.obj_f_list = {}
			obj.action = function()
			end
			
			setmetatable(obj,self)
			self.__index = self
			return obj
		end
		
		function obj_list:import_c_list()
			if #self.obj_f_list == nil then
				i = 1
				for address, name in c.list() do
					self.obj_f_list[i] = obj_for_list:new(i,self.g_status,self.x,self.y+i-1,self.w,1,name,address)
					self.obj_f_list[i].action = function()
					os.exit()
					end
					id = set_id(b_)
					b_[id] = self.obj_f_list[i]
					i = i+1
				end
				i = 0
			else
				for e = 1, #self.obj_f_list do
					self.obj_f_list[e] = nil
				end
				i = 1
				for address, name in c.list() do
					self.obj_f_list[i] = obj_for_list:new(i,self.g_status,self.x,self.y+i-1,self.w,1,name,address)
					self.obj_f_list[i].action = function()
					os.exit()
					end
					id = set_id(b_)
					b_[id] = self.obj_f_list[i]
					i = i+1
				end
				i = 0
			end
		end
		
		function obj_list:draw_list()
			gpu.fill(self.x,self.y,self.w,self.h," ")
			for e = 1, #self.obj_f_list do
			gpu.set(self.x,self.y+e-1,e..". "..self.obj_f_list[e]:get_name())
			end
		end
		
		function obj_list:get_arr_obj()
		return self.obj_f_list
		end
		
	end
	
	function class_obj_for_list()
		obj_for_list={} --класс списка объектов (для выведения массива данных с возможностью обращения к записи)
		
		
		function obj_for_list:new(_id,_status,_x,_y,_w,_h,_name,_text)
			local obj = {}
			
			obj.id = _id
			obj.g_status = _gs
			obj.x = _x
			obj.y = _y
			obj.w = _w
			obj.h = _h
			obj.t_color = black 
			obj.b_color = white
			obj.name = _name
			obj.text = "name: ".._name.." discription: ".._text
			obj.action = function()
			end
			
			setmetatable(obj,self)
			self.__index = self
			return obj
		end
		
		function obj_for_list:get_name()
			return self.name
		end
		
		function obj_for_list:get_x()
			return self.x;
		end
		
		function obj_for_list:get_y()
			return self.y;
		end
		
		function obj_for_list:get_w()
			return self.w;
		end
		
		function obj_for_list:get_h()
			return self.h;
		end
		
	end
	
-- ПОДКЛЮЧЕНИЕ ВСЕХ КЛАССОВ - ДУБЛИРВОАНИЕ ИМЁН ФУНКЦИЙ
	class_button()
	class_obj_list()
	class_obj_for_list()
	
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

--ФУНКЦИЯ СОЗДАНИЯ ТАБЛИЦЫ ОБЪЕКТОВ
function create_obj_list(_name)

end
--

--БЛОК СОЗДАНИЯ ОБЪЕКТОВ
--[[  ГАЙД ПО КНОПКАМ
для корректного выравнивания кнопок:
высота -- НЕЧЁТНАЯ
ширина -- >= ДЛИНА СЛОВА, НЕЧЁТНОЕ СЛОВО - НЕЧЁТНАЯ ДЛИНА И НАОБОРОТ  
]]
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
end

id = set_id(b_)
b_[id] = button:new(id,1,2,4,11,3,"component")
b_[id].action = function()
	general_status = 2
end

id = set_id(b_)
b_[id] = button:new(id,2,14,m_height-3,11,3,"back^")
b_[id].action = function()
	general_status = general_status - 1
	if general_status > 1 then
		b_[id]:set_status(general_status)
	end
end

--[[
id = set_id(b_)
b_[id] = button:new(id,2,14,m_height-3,11,3,"UP")
b_[id].action = function()

end

id = set_id(b_)
b_[id] = button:new(id,2,14,m_height-3,11,3,"DOWN")
b_[id].action = function()

end
]]
l_ = {}
id = set_id(l_)
l_[id] = obj_list:new(id,2,3,6,58,28,"components")	
--

--ОСНОВНОЕ ТЕЛО ПРОГРАММЫ
while true do
components_arr = {}
--отслеживание перехода окна
if general_status_old ~= general_status then
	b_[1]:set_status(general_status)
	general_status_old = general_status
    rev_color(0)
	gpu.fill(1, 1, m_weight, m_height, ' ')	
end

--ОКНА -----------------------------------------------------
--стартовое меню
if general_status == 0 then
draw:text_align(1, m_height/2-4, 1, 0, "WELCOME TO PAP!")
end

--control panel
if general_status == 1 then
	b_[1]:set_values(2,m_height-3,11,3)
	draw:text_align(1,1, 1, 0, "Control Panel")
	draw:rectangle(1, 2, m_weight, 1, 1, black, white)	
end

--component API
if general_status == 2 then

	l_[1]:import_c_list()
	draw:text_align(1,1, 1, 0, "Component API")
	draw:rectangle(1, 2, m_weight, 1, 1, black, white)
	
	--окна списков компонентов
	draw:text_align(2,4, 0, 0, "Found components_")	
	draw:rectangle(2,5,60,30,0,black,white)	
	draw:text_align(m_weight/2+2,4, 0, 0, "Function list_")	
	draw:rectangle(m_weight/2+2,5,60,30,0,black,white)
	
	l_[1]:draw_list()
	--[[
	for i = 1, #b_ do
	gpu.set(m_weight/2-15,5+i,tostring(b_[i]:get_x()))
	gpu.set(m_weight/2-10,5+i,tostring(b_[i]:get_y()))
	gpu.set(m_weight/2-5,5+i,tostring(b_[i]:get_h()))
	gpu.set(m_weight/2,5+i,tostring(b_[i]:get_w()))
	end
]]
	
end
------------------------------------------------------------

--ОТРИСОВКА КНОПОК
for i = 1, #b_ do
	if b_[i].g_status == general_status then
		b_[i]:draw_button()
	end
end


--ПРОВЕРКА НАЖАТИЯ МЫШИ
local tEvent = {e_pull('touch')}
for i = 1, #b_ do
	if b_[i].g_status == general_status then
		if tEvent[3] >= b_[i]:get_x() and tEvent[3] <= b_[i]:get_x()+b_[i]:get_w() and tEvent[4] >= b_[i]:get_y() and tEvent[4] <= b_[i]:get_y()+b_[i]:get_h() then 
			b_[i]:action()
		end
	end
end

end