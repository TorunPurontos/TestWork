function setFont ()
	if Levels[LevelData.LevelNumber].Language == "ES" then
		gui.set_font(gui.get_node("selectedChars"), 'MadeleinaSans')
		gui.set_font(gui.get_node("helpLine"), 'MadeleinaSans')
		gui.set_font(gui.get_node("button/gameButtonText"), 'MadeleinaSans')
	else
		gui.set_font(gui.get_node("selectedChars"), 'InformBold')
		gui.set_font(gui.get_node("helpLine"), 'InformBold')
		gui.set_font(gui.get_node("button/gameButtonText"), 'InformBold')
	end
	if Levels[LevelData.LevelNumber].Language == "RU" then
		charSize = 2
	else
		charSize = 1
	end
end
