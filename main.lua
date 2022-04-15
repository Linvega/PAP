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
thread = require('thread')
--


--БЛОК СТАНДАРТНЫХ ПЕРЕМЕННЫХ
gpu = c.gpu --подключаем видеокарту
m_weight, m_height = gpu.getResolution() --записываем длину и ширину монитора
general_status = 0 --статус активного окна
deneral_status_old = 0

b_ = {} --глобальный массив кнопок
b_list_ = {{},{}} --глобальный массив для листов

--


--БЛОК ЦВЕТОВОЙ ПАЛИТРЫ
white = 0xffffff 
black = 0x000000
red = 0xff0000
green = 0x00ff00
light_blue = 0x00ffff
pink = 0xff00ff
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
		
		
		function obj_list:new(_id,_gs,_x,_y,_w,_h,_d,_name)
			local obj = {}
			
			obj.id = _id
			obj.g_status = _gs
			obj.x = _x
			obj.y = _y
			obj.w = _w
			obj.h = _h
			obj.dim = _d
			obj.n_visible = 0
			obj.first_visible = 1
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
			a = 0
			if #self.obj_f_list == nil then
				i = 1
				for address, name in c.list() do
					self.obj_f_list[i] = obj_for_list:new(i,self.g_status,self.x,self.y+i-1+a,self.w,self.dim,name,address)
					id = set_id(b_list_[self.g_status])
					b_list_[self.g_status][id] = self.obj_f_list[i]
					i = i+1
					a = a + self.dim -1
				end
				i = 0
			else
				for e = 1, #self.obj_f_list do
					self.obj_f_list[e] = nil
				end
				for e = 1, #b_list_[self.g_status] do
					b_list_[self.g_status][e] = nil
				end
				i = 1
				for address, name in c.list() do
					self.obj_f_list[i] = obj_for_list:new(i,self.g_status,self.x,self.y+i-1+a,self.w,self.dim,name,address)
					id = set_id(b_list_[self.g_status])
					b_list_[self.g_status][id] = self.obj_f_list[i]
					i = i+1
					a = a + self.dim -1
				end
				i = 0
			end
			
			
		end
		
		function obj_list:draw_components_list()
			self.n_visible = #self.obj_f_list
			if #self.obj_f_list * self.dim > self.h then
			self.n_visible = self.h / self.dim 
			end	
			for i = self.first_visible, self.n_visible+self.first_visible - 1 do
				self.obj_f_list[i].visible = 1
			end
			gpu.fill(self.x,self.y,self.w,self.h," ")
			for e = 1, self.n_visible+self.first_visible - 1 do
			if self.obj_f_list[e].visible == 1 then
				if self.obj_f_list[e]:get_cond() == 1 then
					rev_color(1)
					gpu.fill(self.obj_f_list[e].x,self.obj_f_list[e].y,self.obj_f_list[e].w,1," ")
					gpu.set(self.obj_f_list[e].x,self.obj_f_list[e].y,e..". name: ")
					gpu.setForeground(pink)
					gpu.set(self.obj_f_list[e].x+9+e/10,self.obj_f_list[e].y,self.obj_f_list[e]:get_name())
					gpu.setForeground(white)
					gpu.fill(self.obj_f_list[e].x,self.obj_f_list[e].y+1,self.obj_f_list[e].w,1," ")
					gpu.set(self.obj_f_list[e].x,self.obj_f_list[e].y+1,"adress: "..self.obj_f_list[e]:get_discription())
					rev_color(0)
				else
					gpu.set(self.obj_f_list[e].x,self.obj_f_list[e].y,e..". name: ")
					gpu.setForeground(pink)
					gpu.set(self.obj_f_list[e].x+9+e/10,self.obj_f_list[e].y,self.obj_f_list[e]:get_name())
					gpu.setForeground(black)
					gpu.set(self.obj_f_list[e].x,self.obj_f_list[e].y+1,"adress: "..self.obj_f_list[e]:get_discription())
				end		
				end				
			end
		end
		
		function obj_list:up()
			if self.first_visible > 1 then
				self.first_visible = self.first_visible - 1
			for i = 1, self.first_visible do
				self.obj_f_list[i].visible = 0
				self.obj_f_list[self.first_visible].visible = 1
			end
				return true
			else
				return false
			end
		end
		
		function obj_list:down()
			if self.n_visible + self.first_visible <= #self.obj_f_list then
				self.first_visible = self.first_visible + 1
			for i = 1, self.first_visible - 1 do
				self.obj_f_list[i].visible = 0
				self.obj_f_list[self.n_visible+1].visible = 1
			end
				return true
			else
				return false
			end
		end
		
		function obj_list:up_list()
			if self.first_visible > 1 then
				self.first_visible = self.first_visible - 1
				return true
			else
				return false
			end
		end
		
		function obj_list:down_list()			
			_dim = 0
			for i = 1, #self.obj_f_list do
				_dim = _dim + self.obj_f_list[i].dim
			end
			if self.first_visible+self.n_visible <= _dim then
				self.first_visible = self.first_visible + 1
				return true
			else
				return false
			end
		end
		
		function obj_list:add_components_info(_table,_table_info)
			self.first_visible = 1
			if #self.obj_f_list ~= nil then
				for e = 1, #self.obj_f_list do
					self.obj_f_list[e] = nil
				end
			end
			_dim = 0
			for i in pairs(_table) do
				self.obj_f_list[i] = obj_for_list:new(i,self.g_status,self.x,self.y+i-1+_dim,self.w,1,_table[i],"")
				if _table_info[i] ~= nil then
					a = 1
					e = 1
					text = _table_info[i]
					t = string.len(text)
					if t > self.w then
						while t > self.w do
							self.obj_f_list[i].text_table[e] = string.sub(text,a,a+self.w-1)
							a = a + self.w
							t = t - self.w
							e = e + 1
							self.obj_f_list[i].dim = self.obj_f_list[i].dim + 1
						end
						self.obj_f_list[i].text_table[e] = string.sub(text,a,a+self.w-1)
						self.obj_f_list[i].dim = self.obj_f_list[i].dim + 1
					else
					self.obj_f_list[i].text_table[1] = text
					end
				else
					self.obj_f_list[i].text_table[1] = "no info"
					self.obj_f_list[i].dim = 2
				end
			_dim = _dim + self.obj_f_list[i].dim - 1
			end
		end
		
		function obj_list:draw_components_info()	

			gpu.fill(self.x,self.y,self.w,self.h," ")	
			if #self.obj_f_list ~= nil then
				_dim = 0
				for i = 1, #self.obj_f_list do
					_dim = _dim + self.obj_f_list[i].dim
				end
					self.n_visible = self.h
				if _dim > self.h then
					self.n_visible = self.h
				else
					self.n_visible = _dim
				end
			
				for i = 1 , #self.obj_f_list do
					if self.obj_f_list[i].y >= self.y and self.obj_f_list[i].y < self.y + self.h   then
					gpu.set(self.obj_f_list[i].x,self.obj_f_list[i].y,i.." name: ")
					gpu.setForeground(pink)
					gpu.set(self.obj_f_list[i].x+9+i/10,self.obj_f_list[i].y,self.obj_f_list[i].name)
					gpu.setForeground(black)
					end
					for t = 1, self.obj_f_list[i].dim-1 do
						if self.obj_f_list[i].y+t >= self.y and self.obj_f_list[i].y+t < self.y + self.h  then
							gpu.set(self.obj_f_list[i].x,self.obj_f_list[i].y+t,self.obj_f_list[i].text_table[t])
						end
					end
				end
			end
		end
		
		function obj_list:clear_components_info()
			if #self.obj_f_list ~= nil then
				for e = 1, #self.obj_f_list do
					self.obj_f_list[e] = nil
				end
			end
		end
		
		function obj_list:normal()
			self.first_visible = 1
			return true
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
			obj.visible = 0
			obj.condition = 0
			obj.x = _x
			obj.y = _y
			obj.w = _w
			obj.h = _h
			obj.dim = 1
			obj.t_color = black 
			obj.b_color = white
			obj.name = _name
			obj.text = _text
			obj.text_table = {}
			obj.action = function()
			end
			
			setmetatable(obj,self)
			self.__index = self
			return obj
		end
		
		function obj_for_list:get_name()
			return self.name
		end
		
		function obj_for_list:get_discription()
			return self.text
		end
		
		function obj_for_list:activate()
			if self.condition == 0 then
			self.condition = 1			
			methods = {}
			methods_info = {}
			for key, value in pairs(c.getPrimary(self.name)) do
					table.insert(methods,key)
					table.insert(methods_info,c.doc(self.text,key))
				end
			l_[2]:add_components_info(methods,methods_info)
			else
			self.condition = 0			
			end
			return true
		end
		
		function obj_for_list:get_cond()
			return self.condition
		end
		
		function obj_for_list:get_x()
			return self.x;
		end
		
		function obj_for_list:get_y()
			return self.y;
		end
		
		function obj_for_list:set_x(_x)
			self.x = _x
		end
		
		function obj_for_list:set_y(_y)
			self.y = _y
		end
		
		function obj_for_list:get_w()
			return self.w;
		end
		
		function obj_for_list:get_h()
			return self.h;
		end
		
	end

	--function 
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

--ФУНКЦИИ СМЕЩЕНИЙ КООРДИНАТ
function coor_down(_arr,_vol)
local arr = _arr
for i = 1, #arr do
arr[i]:set_y(arr[i]:get_y()-_vol)
end

end

function coor_up(_arr,_vol)
local arr = _arr
for i = 1, #arr do
arr[i]:set_y(arr[i]:get_y()+_vol)
end
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
	l_[1]:import_c_list()
	l_[2]:clear_components_info()
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


id = set_id(b_)
b_[id] = button:new(id,2,m_weight/2-15,14,8,3,"UP") --component api 1 table
b_[id].action = function()
if l_[1]:up() == true then
coor_up(l_[1]:get_arr_obj(),2)
end
end

id = set_id(b_)
b_[id] = button:new(id,2,m_weight/2-15,19,8,3,"DOWN") --component api 1 table
b_[id].action = function()
if l_[1]:down() == true then
coor_down(l_[1]:get_arr_obj(),2)
end
end

id = set_id(b_)
b_[id] = button:new(id,2,m_weight/2-15,24,8,3,"UPDATE") 
b_[id].action = function()
	l_[1]:normal()
	l_[1]:import_c_list()
end

id = set_id(b_)
b_[id] = button:new(id,2,m_weight/2+65,17,8,3,"UP") --component api 2 table
b_[id].action = function()
if l_[2]:up_list() == true then 
coor_up(l_[2]:get_arr_obj(),1)
end
end

id = set_id(b_)
b_[id] = button:new(id,2,m_weight/2+65,21,8,3,"DOWN") --component api 2 table
b_[id].action = function()
if l_[2]:down_list() == true then 
coor_down(l_[2]:get_arr_obj(),1)
end
end

--СОЗДАНИЕ СПИСКОВ С ОБЪЕКТАМИ
l_ = {}
id = set_id(l_)
l_[id] = obj_list:new(id,2,3,6,58,28,2,"components")	

id = set_id(l_)
l_[id] = obj_list:new(id,2,m_weight/2+3,6,58,28,2,"components_info")	


--СОЗДАНИЕ ТЕКСТОВЫХ СПИСКОВ

--
thread.create(function()
while true do
	if general_status ~= 0 then
		gpu.set(m_weight-5,1,string.sub(tostring(os.date()),10,14))
	end
    os.sleep(0.8)
end
end)
--ОСНОВНОЕ ТЕЛО ПРОГРАММЫ
while true do
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

else 

--io.write(os.time())
end

--control panel
if general_status == 1 then
	b_[1]:set_values(2,m_height-3,11,3)
	draw:text_align(1,1, 1, 0, "Control Panel")
	draw:rectangle(1, 2, m_weight, 1, 1, black, white)	
end

--component API
if general_status == 2 then
	draw:text_align(1,1, 1, 0, "Component API")
	draw:rectangle(1, 2, m_weight, 1, 1, black, white)
	--окна списков компонентов
	draw:text_align(2,4, 0, 0, "Found components_")	
	draw:rectangle(2,5,60,30,0,black,white)	
	draw:text_align(m_weight/2+2,4, 0, 0, "Function list_")	
	draw:rectangle(m_weight/2+2,5,60,30,0,black,white)
	

	l_[1]:draw_components_list()
	l_[2]:draw_components_info()

	--table.insert(methods,"")
	--for i= 1, #methods do
	--io.write(tostring(methods[i]))
	--end
	--[[for i = 1, #b_list_ do
	gpu.set(m_weight/2-15,5+i,tostring(b_list_[i]:get_x()))
	gpu.set(m_weight/2-10,5+i,tostring(b_list_[i]:get_y()))
	gpu.set(m_weight/2-5,5+i,tostring(b_list_[i]:get_h()))
	gpu.set(m_weight/2,5+i,tostring(b_list_[i]:get_w()))
	end]]

	
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

	for i = 1, #b_list_ do
		if i == general_status then
			for b = 1, #b_list_[i] do
	--for i = 1, #b_list_[general_status] do
			if tEvent[3] >= b_list_[general_status][b]:get_x() and tEvent[3] <= b_list_[general_status][b]:get_x()+b_list_[general_status][b]:get_w()-1 and tEvent[4] >= b_list_[general_status][b]:get_y() and tEvent[4] <= b_list_[general_status][b]:get_y()+b_list_[general_status][b]:get_h()-1 then 
				if b_list_[general_status][b].visible == 1 and b_list_[general_status][b]:activate() == true then
					for c = 1, #b_list_[general_status] do
					if b_list_[general_status][c] ~= b_list_[general_status][b] and b_list_[general_status][c]:get_cond() == 1 then
						b_list_[general_status][c]:activate()
						end
					end
				end
			end
		end
	end
	end
	--[[gpu.set(m_weight/2-15,10,"12345")
	for i = 1, #b_list_ do
	for b = 1, #b_list_[i] do
	gpu.set(m_weight/2-15+i-1,10+b,"x")
	gpu.set(m_weight/2-15+i-1,10+b,tostring(b_list_[i][b]:get_y()))
	
	end
	end]]
	--end
--end
for i = 1, #b_ do
	if b_[i].g_status == general_status then
		if tEvent[3] >= b_[i]:get_x() and tEvent[3] <= b_[i]:get_x()+b_[i]:get_w()-1 and tEvent[4] >= b_[i]:get_y() and tEvent[4] <= b_[i]:get_y()+b_[i]:get_h()-1 then 
			b_[i]:action()
		end
	end
	

end

end