--[[
Программа программируемой автоматизации - Programmable Automation program (PAP)
Ver 0.0
	]]
	
--БЛОК ПОДКЛЮЧЕНИЯ БИБЛИОТЕК
c = require("component")
term = require("term")
e_pull = require('event').pull
unicode = require("unicode")
--


--БЛОК СТАНДАРТНЫХ ПЕРЕМЕННЫХ
gpu = c.gpu
m_weight, m_height = gpu.getResolution()
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

		function button:new(_name)
		local obj = {name = _name}
		setmetatable(obj,self)
		return obj
		end

		function button:test()
		return "ok"
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
class_ini() --ИНИЦИАЛИЗАЦИЯ ВСЕХ КЛАССОВ

obj_test = button:new("TEST")
--

--ОСНОВНОЕ ТЕЛО ПРОГРАММЫ
while true do
--energy = c.solar_panel.getEnergyStored()
--max_energy = c.solar_panel.getMaxEnergyStored()


gpu.set(1, 1, "Добро пожаловать в PAP! Тестовая сборка")
gpu.set(1, 2, tostring(max_energy))

gpu.set(1, 3, obj_test:test())
os.sleep(0.5)
end