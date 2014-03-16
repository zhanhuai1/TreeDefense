ScreenMgr = ScreenMgr or BaseClass()

function ScreenMgr:__init()
	self.screens = {}
	self.screens["main_menu_screen"] = MainMenuScreen.New()
	self.screens["main_game_screen"] = GameScreen.New()  

	self.current_screen = self.screens["main_menu_screen"]
	self.current_screen:Enter()
end
