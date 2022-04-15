--[[ОПИСАНИЕ
Программа программируемой автоматизации - Programmable Automation program (PAP)
Ver 0.0
	]]
	
--БЛОК ПОДКЛЮЧЕНИЯ БИБЛИОТЕК
c = require("component")
term = require("term")
e_pull = require('event').pull
event = require("event")
unicode = require("unicode")
draw = require('draw')
computer = require('computer')
thread = require('thread')
keyboard = require('keyboard')
key = require('pap_keyboard')
--


--БЛОК СТАНДАРТНЫХ ПЕРЕМЕННЫХ
gpu = c.gpu --подключаем видеокарту
m = c.modem --подключаем модем

need = 0

m.open(1) --открываем порт 1

m_weight, m_height = 160,50 --записываем длину и ширину монитора
gpu.setResolution(m_weight,m_height)
general_status = 0 --статус активного окна
deneral_status_old = 0

b_ = {} --глобальный массив кнопок

function newAutotable(dim)
    local MT = {};
    for i=1, dim do
        MT[i] = {__index = function(t, k)
            if i < dim then
                t[k] = setmetatable({}, MT[i+1])
                return t[k];
            end
        end}
    end

    return setmetatable({}, MT[1]);
end

b_list_ = newAutotable(3)
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
		
		function obj_list:create_table( _type,...) --метод передачи таблицы в объект списка
		local _table = {} 
		for i = 1, select('#', ...) do
		_table[i] = select(i, ...)
		end
			clear()
			
			local i = 1 --переменная для исчисления id объекта
			local _dim = 0 --переменная для вычисления высоты объекта
			
			if _type == "components" then --если тип компонентный
				for k, n in pairs(_table[1]) do
					self.obj_f_list[i] = obj_for_list:new(i,self.g_status,self.x,self.y+_dim,self.w,2,n,k) --создаём новый объект для списка
					self.obj_f_list[i].last_area = self.obj_f_list[i].last_area + 1
					b_list_[self.g_status][self.id][i] = self.obj_f_list[i] --добавляем объект в глобальный массив кнопок списков
					i = i+1
					_dim = _dim + 2
				end
			end
			
			if _type == "components_info" then --если тип компонентный
				for n in pairs(_table[1]) do --прогоняем первуб таблицу
					self.obj_f_list[n] = obj_for_list:new(n,self.g_status,self.x,self.y+n-1+_dim,self.w,1,_table[1][n],"") --создаём новый объект для списка
					local a = 1
					local e = 1
					local text = _table[2][n]
					t = string.len(text)
					if t > self.w then
						while t > self.w do
							self.obj_f_list[n].text_table[e] = string.sub(text,a,a+self.w-1)
							a = a + self.w
							t = t - self.w
							e = e + 1
							self.obj_f_list[n].dim = self.obj_f_list[n].dim + 1		
							self.obj_f_list[n].last_area = self.obj_f_list[i].last_area + 1
							_dim = _dim + 1
						end
						self.obj_f_list[n].text_table[e] = string.sub(text,a,a+self.w-1)
						self.obj_f_list[n].dim = self.obj_f_list[n].dim + 1	
						self.obj_f_list[n].last_area = self.obj_f_list[i].last_area + 1
						_dim = _dim + 1
					else
					self.obj_f_list[n].text_table[1] = text
					self.obj_f_list[n].dim = self.obj_f_list[n].dim + 1	
					self.obj_f_list[n].last_area = self.obj_f_list[i].last_area + 1
					_dim = _dim + 1
					end
					b_list_[self.g_status][self.id][i] = self.obj_f_list[n] --добавляем объект в глобальный массив кнопок списков
					i = i+1
				end
			end
			for a = 1, #self.obj_f_list do
				if self.obj_f_list[a].y > self.y + self.h - 1 then
					self.obj_f_list[a].last_area = 0
				else
					for t = 1, self.obj_f_list[a].dim - 1 do
					if self.obj_f_list[a].y + t > self.y + self.h - 1 then
						self.obj_f_list[a].last_area = self.obj_f_list[a].last_area - 1
					end
					end
				end
			end
		end
		
		function obj_list:draw_list(_t)
			
			_type = _t or 0
			
			if _type == "components" then --если тип компонентный
			
				gpu.fill(self.x,self.y,self.w,self.h," ")	
				
				gpu.fill(self.x,self.y,self.w,self.h," ")
				for e = 1, #self.obj_f_list do
					if self.obj_f_list[e]:get_cond() == 1 then
						if self.obj_f_list[e].y >= self.y and self.obj_f_list[e].y < self.y + self.h   then
						rev_color(1)
						gpu.fill(self.obj_f_list[e].x,self.obj_f_list[e].y,self.obj_f_list[e].w,1," ")
						gpu.set(self.obj_f_list[e].x,self.obj_f_list[e].y,e..". name: ")
						gpu.setForeground(pink)
						gpu.set(self.obj_f_list[e].x+9+e/10,self.obj_f_list[e].y,self.obj_f_list[e]:get_name())
						gpu.setForeground(white)
						rev_color(0)
						end
						if self.obj_f_list[e].y+1 >= self.y and self.obj_f_list[e].y+1 < self.y + self.h   then
						rev_color(1)
						gpu.fill(self.obj_f_list[e].x,self.obj_f_list[e].y+1,self.obj_f_list[e].w,1," ")
						gpu.set(self.obj_f_list[e].x,self.obj_f_list[e].y+1,self.obj_f_list[e]:get_discription())
						rev_color(0)
						end
					else
						if self.obj_f_list[e].y >= self.y and self.obj_f_list[e].y < self.y + self.h   then
						gpu.fill(self.obj_f_list[e].x,self.obj_f_list[e].y,self.obj_f_list[e].w,1," ")
						gpu.set(self.obj_f_list[e].x,self.obj_f_list[e].y,e..". name: ")
						gpu.setForeground(pink)
						gpu.set(self.obj_f_list[e].x+9+e/10,self.obj_f_list[e].y,self.obj_f_list[e]:get_name())
						gpu.setForeground(black)
						end
						if self.obj_f_list[e].y+1 >= self.y and self.obj_f_list[e].y+1 < self.y + self.h   then
						gpu.fill(self.obj_f_list[e].x,self.obj_f_list[e].y+1,self.obj_f_list[e].w,1," ")
						gpu.set(self.obj_f_list[e].x,self.obj_f_list[e].y+1,self.obj_f_list[e]:get_discription())
						end
					end		
				end		
			end
			
			if _type == "components_info" then --если тип компонентный
				gpu.fill(self.x,self.y,self.w,self.h," ")	
			
			
				for i = 1 , #self.obj_f_list do --построчная отрисовка 
					if self.obj_f_list[i].y >= self.y and self.obj_f_list[i].y < self.y + self.h   then --если коорды объекта попадают в диапазон окна
						if self.obj_f_list[i].condition == 1 then	--проверка выбранного объекта
							rev_color(1)
							gpu.fill(self.obj_f_list[i].x,self.obj_f_list[i].y,self.obj_f_list[i].w,1," ")
							gpu.set(self.obj_f_list[i].x,self.obj_f_list[i].y,i.." name: ") --выводим "имя"
							gpu.setForeground(pink)
							gpu.set(self.obj_f_list[i].x+9+i/10,self.obj_f_list[i].y,self.obj_f_list[i].name) --выводим имя выделенное цветом
							gpu.setForeground(black)
							rev_color(0)
						else
							gpu.fill(self.obj_f_list[i].x,self.obj_f_list[i].y,self.obj_f_list[i].w,1," ")
							gpu.set(self.obj_f_list[i].x,self.obj_f_list[i].y,i.." name: ") --выводим "имя"
							gpu.setForeground(pink)
							gpu.set(self.obj_f_list[i].x+9+i/10,self.obj_f_list[i].y,self.obj_f_list[i].name) --выводим имя выделенное цветом
							gpu.setForeground(black)
						end
					end
					for t = 1, self.obj_f_list[i].dim-1 do --выводим описание
						if self.obj_f_list[i].condition == 1 then	--проверка выбранного объекта
							rev_color(1)
							if self.obj_f_list[i].y+t >= self.y and self.obj_f_list[i].y+t < self.y + self.h  then
								gpu.fill(self.obj_f_list[i].x,self.obj_f_list[i].y+t,self.obj_f_list[i].w,1," ")
								gpu.set(self.obj_f_list[i].x,self.obj_f_list[i].y+t,self.obj_f_list[i].text_table[t])
							end
							rev_color(0)
						else
							if self.obj_f_list[i].y+t >= self.y and self.obj_f_list[i].y+t < self.y + self.h  then
								gpu.fill(self.obj_f_list[i].x,self.obj_f_list[i].y+t,self.obj_f_list[i].w,1," ")
								gpu.set(self.obj_f_list[i].x,self.obj_f_list[i].y+t,self.obj_f_list[i].text_table[t])
							end
						end
					end
				end
			end
		end
		
		function obj_list:up()
			if self.obj_f_list[1].y < self.y then
				return true
			else
				return false
			end
		end
		
		function obj_list:down()
			_dim = 0
			q = 0
			for i = 1, #self.obj_f_list do
				_dim = _dim + self.obj_f_list[i].dim
				q = q + 1
			end
			if self.obj_f_list[q].y+self.obj_f_list[q].dim-self.y >= self.h then
				return true
			else
				return false
			end
		end
		
		function obj_list:reset_up_area()
			for i = 1, #self.obj_f_list do
				for e = 1, self.obj_f_list[i].dim do
					if self.obj_f_list[i].y + e >= self.y and self.obj_f_list[i].first_area > 1 then
						self.obj_f_list[i].first_area = self.obj_f_list[i].first_area-1
					end
					if self.obj_f_list[i].y + e - 1 >= self.y+self.h-1 and self.obj_f_list[i].last_area > 0 then
						self.obj_f_list[i].last_area = self.obj_f_list[i].last_area-1
					end
				end
			end
		end
		
		function obj_list:reset_down_area()
			for i = 1, #self.obj_f_list do
				for e = 1, self.obj_f_list[i].dim do
					if self.obj_f_list[i].y + e - 1 < self.y and self.obj_f_list[i].first_area <= self.obj_f_list[i].dim + 1 then
						self.obj_f_list[i].first_area = self.obj_f_list[i].first_area+1
					end
					if self.obj_f_list[i].y + e - 1 <= self.y+self.h-1 and self.obj_f_list[i].last_area <= self.obj_f_list[i].dim then
						self.obj_f_list[i].last_area = self.obj_f_list[i].last_area+1
					end
				end
			end
		end
		
		function obj_list:get_arr()
			if self.obj_f_list ~= nil then
		return self.obj_f_list
			else return false
		end
		end
		
		function obj_list:clear()
			if #self.obj_f_list ~= nil then --в случае не пустого массива обнуляем его и глобальный
				for e = 1, #b_list_[self.g_status][self.id] do
					b_list_[self.g_status][self.id][e] = nil
					self.obj_f_list[e] = nil
				end
			end
		end
		
		function obj_list:set_function(_e,_f)
				self.obj_f_list[_e].function_ = _f
		end
		
	end
	
	function class_obj_for_list()
	
		obj_for_list={} --класс списка объектов (для выведения массива данных с возможностью обращения к записи)
		
		
		function obj_for_list:new(_id,_status,_x,_y,_w,_h,_name,_text)
			local obj = {}
			
			obj.id = _id
			obj.g_status = _gs
			obj.first_area = 1--
			obj.last_area = 1-- значение областей доступности взаимодействия с объектом от У координаты
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
			obj.function_ = function()
			end
			obj.action = function()
						if obj.condition == 0 then
							obj.condition = 1	
							else
							obj.condition = 0
							end
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
		
		function obj_for_list:set_function(_f)
			self.function_ = _f
		end
		
		function obj_for_list:activate_function(_f)
		if self.condition == 0 then
			self.action()
			self.function_()
			return true
			else
			return false
			end
		end
		
		function obj_for_list:get_cond()
			return self.condition
		end
		
		function obj_for_list:set_cond(_c)
			self.condition = _c
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
		
		function obj_for_list:get_area()
			if self.first_area > self.last_area or self.last_area == 0 then
				return false,0,0,0,0
			else
				return true, self.x, self.y + self.first_area-1, self.w-1, self.last_area - 1
			end
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
	if _arr ~= nil then
	return #_arr+1
	else
	return 1
	end
end
--

--ФУНКЦИИ СМЕЩЕНИЙ КООРДИНАТ
function coor_down(_arr,_vol)
for i = 1, #_arr do
_arr[i]:set_y(_arr[i]:get_y()-_vol)
end

end

function coor_up(_arr,_vol)
for i = 1, #_arr do
_arr[i]:set_y(_arr[i]:get_y()+_vol)
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
	general_status = 2	
	l_[1]:create_table("components",c.list())
	l_arr = l_[1]:get_arr()
	for e = 1, #l_arr do
		fun = function()
		id = set_id(l_)
		l_[id] = obj_list:new(2,2,m_weight/2+3,6,58,28,2,"components_info")	
		local methods = {}
		local methods_info = {}
		for key, value in pairs(c.getPrimary(l_arr[e].name)) do
					table.insert(methods,key)
		end
			table.sort(methods)
		for i in pairs(methods) do
			if c.doc(l_arr[e].text,methods[i]) ~= nil then
				table.insert(methods_info,c.doc(l_arr[e].text,methods[i]))
			else
				table.insert(methods_info,"no info")
			end
		end
		l_[2]:create_table("components_info",methods,methods_info)	
		l_[2]:draw_list("components_info")
		need = 1
		return true
		end
	l_[1]:set_function(e,fun)
	end
	if l_[2] ~= nil then
		l_[2]:clear()
	end
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
coor_up(l_[1]:get_arr(),1)
l_[1]:reset_up_area()
end
end

id = set_id(b_)
b_[id] = button:new(id,2,m_weight/2-15,19,8,3,"DOWN") --component api 1 table
b_[id].action = function()
if l_[1]:down() == true then
coor_down(l_[1]:get_arr(),1)
l_[1]:reset_down_area()
end
end

id = set_id(b_)
b_[id] = button:new(id,2,m_weight/2-15,24,8,3,"UPDATE") --component api 1 table
b_[id].action = function()
	l_[1]:create_table("components",c.list())	
	l_arr = l_[1]:get_arr()
	for e = 1, #l_arr do
		fun = function()
		id = set_id(l_)
		l_[id] = obj_list:new(2,2,m_weight/2+3,6,58,28,2,"components_info")	
		local methods = {}
		local methods_info = {}
		for key, value in pairs(c.getPrimary(l_arr[e].name)) do
					table.insert(methods,key)
		end
			table.sort(methods)
		for i in pairs(methods) do
			if c.doc(l_arr[e].text,methods[i]) ~= nil then
				table.insert(methods_info,c.doc(l_arr[e].text,methods[i]))
			else
				table.insert(methods_info,"no info")
			end
		end
		l_[2]:create_table("components_info",methods,methods_info)
		return true
		end
	l_[1]:set_function(e,fun)
	end
	if l_[2] ~= nil then
	l_[2]:clear()
	end
end

id = set_id(b_)
b_[id] = button:new(id,2,m_weight/2+65,17,8,3,"UP") --component api 2 table
b_[id].action = function()
	if l_[2] ~= nil then
		if l_[2]:up() == true then 
			coor_up(l_[2]:get_arr(),1)
			l_[2]:reset_up_area()
		end
	end
end

id = set_id(b_)
b_[id] = button:new(id,2,m_weight/2+65,21,8,3,"DOWN") --component api 2 table
b_[id].action = function()
	if l_[2] ~= nil then
		if l_[2]:down() == true then 
			coor_down(l_[2]:get_arr(),1)
			l_[2]:reset_down_area()
		end
	end
end

--СОЗДАНИЕ СПИСКОВ С ОБЪЕКТАМИ
l_ = {}
id = set_id(l_)
l_[id] = obj_list:new(1,2,3,6,58,28,2,"components")	






--СОЗДАНИЕ ТЕКСТОВЫХ СПИСКОВ

--

--ФОНОВЫЕ ПОТОКИ---------------------------------
thread.create(function() --время
while true do
if general_status ~= 0 then
		gpu.set(m_weight-5,1,string.sub(tostring(os.date()),10,14))
		if general_status == 2 then
		end
	end
    os.sleep(0.8)
end
end)


thread.create(function() --тест передачи сообщений
while true do
	_, _, from, port, _, message = e_pull("modem_message")
	if general_status == 2 then
		gpu.set(2,m_height-14,tostring(message))
	end
end
end)



--[[thread.create(function() --тест передачи сообщений
while true do
	if general_status ~= 0 then
   num = 3--#b_list_[2][1]
   for i = 1, num do
		--gpu.fill(1,1,10,1,' ')
		draw:text_align(1,1, 0, 0, tostring(b_list_[2][1][i]:get_x()))
		os.sleep(1)
   end
   end
end
end)]]
-----------------------------------------------


--ОСНОВНОЕ ТЕЛО ПРОГРАММЫ
while true do
--отслеживание перехода окна

function clear()
	gpu.fill(1, 1, m_weight, m_height, ' ')
end

if general_status_old ~= general_status then
	b_[1]:set_status(general_status)
	general_status_old = general_status
    rev_color(0)	
	clear()
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
	if l_[2] ~= nil then
		l_[2]:draw_list("components_info")	
	end
	l_[1]:draw_list("components")
	draw:text_align(1,1, 1, 0, "Component API")
	draw:rectangle(1, 2, m_weight, 1, 1, black, white)
	--окна списков компонентов
	draw:text_align(2,4, 0, 0, "Found components_")	
	draw:rectangle(2,5,60,30,0,black,white)	
	draw:text_align(m_weight/2+2,4, 0, 0, "Function list_")	
	draw:rectangle(m_weight/2+2,5,60,30,0,black,white)
	draw:text_align(2,36, 0, 0, "Function out_")	
	draw:rectangle(2,37,m_weight - 20,9,0,black,white)		

	
	thread.create(function() 
	local text = ""
	while true do
		local name, address, ch, code, player = event.pull("key_down")
		if key:get_key(code) == "back" then
		text = string.sub(text,1,string.len(text)-1)
		else 
		text = string.format("%s%s",text, key:get_key(code))
		end
		gpu.fill(3,38,m_weight - 19,1," ")
		gpu.set(3,38,text)
	end
	end)
					
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

if b_list_[general_status] ~= nil then
	for b = 1, #b_list_[general_status] do
		for a = 1, #b_list_[general_status][b] do
			local _s,_x,_y,_w,_h = b_list_[general_status][b][a]:get_area()
			if _s == true then
			if tEvent[3] >= _x and tEvent[3] <= _x+_w and tEvent[4] >= _y and tEvent[4] <= _y+_h then 
				--if b_list_[general_status][b][a].visible == 1  then
					if b_list_[general_status][b][a]:activate_function() == true then
					for c = 1, #b_list_[general_status][b] do
					if c ~= a and b_list_[general_status][b][c]:get_cond() == 1 then
						b_list_[general_status][b][c]:set_cond(0)
						end
					end
				end
			end
			end
			
		end
	end
end

for i = 1, #b_ do
	if b_[i].g_status == general_status then
		if tEvent[3] >= b_[i]:get_x() and tEvent[3] <= b_[i]:get_x()+b_[i]:get_w()-1 and tEvent[4] >= b_[i]:get_y() and tEvent[4] <= b_[i]:get_y()+b_[i]:get_h()-1 then 
			b_[i]:action()
		end
	end
	

end

end