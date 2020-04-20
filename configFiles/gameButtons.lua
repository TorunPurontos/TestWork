require 'configFiles.levelData'
require 'configFiles.font'

function createButtons ()
	blockedButtons = {}
	completeWords = {}
	chain = {}
	numberChain = ""
	setFont()
	local levelChar = Levels[LevelData.LevelNumber].Code
	local buttonId = hash("gameButton")
	local buttonIdText = hash("gameButtonText")
	local width = Levels[LevelData.LevelNumber].Width
	local height = Levels[LevelData.LevelNumber].Height
	lastX = 0
	lastY = 0 
	currentX = 0
	currentY = 0
	preLastX = 0
	preLastY = 0
	local continue = false
	dopValueForSizeChar = 0
	gui.set_text(gui.get_node("countHelp"), LevelData.СountHelp)
	buttonPath = hash("button/gameButton")
	buttonTextPath = hash("button/gameButtonText")
	gameButtons = {}
	local gameButtonsArray = {
		{
			id = buttonId.."1",
			text = levelChar:sub(1, charSize),
			func = function()
				play_sound(msg.url("/sounds#selectItem"))
			end
		},
	}
	local count = 1
	for i = charSize, #levelChar - 1, 1 do
		if not continue then
			count = count+1
			local letter = levelChar:sub(i + charSize ,i + charSize)
			if not (((letter >= 'a') and (letter <= 'z')) or ((letter >= 'A') and (letter <= 'Z'))) then
				letter = levelChar:sub(i + 1, i + charSize)
				continue = true
			end
			table.insert(gameButtonsArray, { id = buttonId..count , text = letter, func = function() play_sound(msg.url("/sounds#selectItem")) end })
		else
			continue = false
		end
	end
	local gameButton = gui.get_node(buttonPath)
	local buttonStartX = (sizeBoardForButtons / width) *0.7
	for i, data in ipairs(gameButtonsArray) do
		local nodes = gui.clone_tree(gameButton)
		local countButtons = math.max(width, height)
		defaultButtonSize = math.ceil(sizeBoardForButtons / countButtons)
		local x = #gameButtons % countButtons
		local y = math.floor(#gameButtons / countButtons)
		gui.set_size(nodes[buttonPath], vmath.vector4(defaultButtonSize, defaultButtonSize, 0, 0))
		if width < height then
			gui.set_position(nodes[buttonPath], vmath.vector3(buttonStartX + y * defaultButtonSize , buttonStartY + x * defaultButtonSize, 1))
		else
			gui.set_position(nodes[buttonPath], vmath.vector3(buttonStartX + x * defaultButtonSize , buttonStartY + y * defaultButtonSize, 1))
		end
		gui.set_text(nodes[buttonTextPath], data.text)
		gui.set_id(nodes[buttonTextPath], buttonIdText..i)
		gui.set_size(nodes[buttonTextPath], vmath.vector4(defaultButtonSize, defaultButtonSize, 0, 0))
		table.insert(gameButtons, { nodes = nodes, data = data })
	end
	gui.set_enabled(gameButton, false)
	msg.post("#", "acquire_input_focus")
end

function useGuiButtons (x,y)
	local guiButtons =  {"buttonBack", "buttonHelp", "sun", "moon"}
	for i, button in pairs(guiButtons) do
		if gui.pick_node(gui.get_node(button), x, y) then
			play_sound("/sounds#buttonClick", "play_sound")
			if button == "sun" then
				sprite.play_flipbook("/background#back","backgroundLight")
			elseif button == "moon" then
				sprite.play_flipbook("/background#back","bg")
			elseif button == "buttonBack" then
				msg.post("main:/mainMenu#gui", "back")
			elseif button == "buttonHelp" then
				showHint()
			end
		end
	end
end