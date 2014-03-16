require("scripts.Screen.BaseScreen")
require("scripts.Screen.GameScreen")
require("scripts.Screen.MainMenuScreen")
require("scripts.Screen.SelectMapScreen")

ScreenManager = ScreenManager or BaseClass()

function ScreenManager:__init()	
	ScreenManager.Instance = self

	self.main_menu_screen = MainMenuScreen.New()
	self.select_map_screen = SelectMapScreen.New()
	self.game_screen = GameScreen.New()  

	self.cur_screen = nil

	self:InitEvents()
end

function ScreenManager:__delete()
	self.main_menu_screen:DeleteMe()
	self.main_menu_screen = nil

	self.select_map_screen:DeleteMe()
	self.select_map_screen = nil

	self.game_screen:DeleteMe()
	self.game_screen = nil	
end

function ScreenManager:InitEvents()
	local go_main_menu = function ()
		self:GoMainMenuScreen()
	end
	GlobalEventSystem:Bind(EventName.GoMainMenu, go_main_menu)

	local go_select_map = function ()
		self:GoSelectMapScreen()
	end
	GlobalEventSystem:Bind(EventName.GoSelectMap, go_select_map)

	local go_game_screen = function (map_info)
		self:GoGameScreen(map_info)
	end
	GlobalEventSystem:Bind(EventName.GoGame, go_game_screen)
end

function ScreenManager:Update(delta_time, running_time)
	if self.cur_screen then
		self.cur_screen:Update(delta_time, running_time)
	end
end

function ScreenManager:GoMainMenuScreen()
	if self.cur_screen then
		self.cur_screen:Exit()
	end
	self.cur_screen = self.main_menu_screen
	self.cur_screen:Enter()
end

function ScreenManager:GoSelectMapScreen()
	if self.cur_screen then
		self.cur_screen:Exit()
	end
	self.cur_screen = self.select_map_screen
	self.cur_screen:Enter()
end

function ScreenManager:GoGameScreen(map_info)
	if self.cur_screen then
		self.cur_screen:Exit()
	end
	self.cur_screen = self.game_screen
	self.cur_screen:Enter(map_info)
end

