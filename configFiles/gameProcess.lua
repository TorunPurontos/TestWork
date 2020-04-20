require 'configFiles.levelData'
require 'configFiles.gameButtons'
require 'configFiles.texture'
require 'configFiles.font'

function countLength (word)
	lengthWord = 0
	continue = false
	for i = 1, #word do
		if not continue then
			local letter = word:sub(i + charSize , i + charSize)
			if not (((letter >= 'a') and (letter <= 'z')) or ((letter >= 'A') and (letter <= 'Z'))) then
				letter = word:sub(i + 1, i + charSize)
				continue = true
			end
			lengthWord = lengthWord +1 
		else
			continue = false
		end
	end
	return lengthWord
end

local function compareWords (word, word2)
	local language =  Levels[LevelData.LevelNumber].Language
	local sizeWord = ''
	if language == 'RU' then
		sizeWord = countLength(word)
		if word == word2 then 
			return true
		end
	else
		sizeWord = string.len(word)
		local sizeWord2 = countLength(word2)
		if sizeWord ~= sizeWord2 then
			return false
		else
			for i = 1, sizeWord do
				if string.byte(word, i) ~= string.byte(word2, i) then 
					return false
				end
			end
			return true
		end
	end
end

function checkAnswer ()
	local LevelAnswerKey = string.gmatch(Levels[LevelData.LevelNumber].AnswerKey, "%S+")
	for answerKey in LevelAnswerKey do
		if answerKey == numberChain then
			for _, button in pairs(chain) do
				table.insert(blockedButtons, button)
				table.insert(completeWords, gui.get_text(gui.get_node("selectedChars")))
				for _, completeButton in pairs(gameButtons) do
					if completeButton.data.id == button then
						changeTexture(completeButton.nodes[buttonPath], "complete")
					end
				end
			end
			return true
		end
	end
	return false
end

function checkWord ()
	local selectedChars = gui.get_node("selectedChars")
	local word = gui.get_text(selectedChars)
	local LevelWordArray = string.gmatch(Levels[LevelData.LevelNumber].Words, "%S+")
	local wordNotFind = true
	for levelWord in LevelWordArray do
		if compareWords(word, levelWord) == true then
			if checkAnswer() then
				local wordNotFind = false
				if levelWord == helpWord then
					gui.set_text(gui.get_node("helpLine"), "")
				end
				break
			else
				msg.post("/wrongOrder#wrongOrder", "show")
				break
			end 
		end
	end	
	chain = {}
	numberChain = '';
	gui.set_text(selectedChars, "")	
end

function checkEndLevel ()
	if table.maxn(blockedButtons) == Levels[LevelData.LevelNumber].Height * Levels[LevelData.LevelNumber].Width then
		if LevelData.LevelNumber == table.maxn(Levels) then 
			LevelData.LevelNumber = 1
		else
			LevelData.LevelNumber = LevelData.LevelNumber + 1 
		end
		blockedButtons = {}
		completeWords = {}
		msg.post("/levelСomplete#gui", "show") 
	end	
end

function blockList(blocks, block)
	for _, item in pairs(blocks) do
		if item == block then
			return true
		end
	end
	return false
end

function checkPosition (x, y, type)
	for i, button in pairs(gameButtons) do
		local buttonNodes = button.nodes[buttonPath]
		if gui.pick_node(buttonNodes, x, y) then
			local pos = gui.get_position(buttonNodes)
			switch = {
				["last"] = function () 
					preLastX = math.ceil(lastX)
					preLastY = math.ceil(lastY)
					lastX = math.ceil(pos.x)
					lastY = math.ceil(pos.y)
				end,
				["current"] = function () 
					currentX = math.ceil(pos.x)
					currentY = math.ceil(pos.y)
				end,
				["selectButton"] = function ()
					local selectedChars = gui.get_node("selectedChars")
					if not blockList(chain, button.data.id) and not blockList (blockedButtons, button.data.id) then
						table.insert(chain, button.data.id)
						numberChain = numberChain..string.match(button.data.id, "(%d+)")
						changeTexture(buttonNodes, "swap")						
						gui.set_text(selectedChars, gui.get_text(selectedChars)..button.data.text)
						button.data.func()
						checkPosition(x, y, "last")
					end
				end,
				["freeButton"] = function ()
					if blockList(chain, button.data.id) then
						for i, button in pairs(gameButtons) do
							local localNodes = button.nodes[buttonPath]
							if table.maxn(chain) > 1 then
								if button.data.id == chain[table.maxn(chain)] then
									changeTexture(localNodes, "free")
									table.remove(chain,table.maxn(chain))
									print('До '..numberChain)
									local lastButtonIdLength = string.match(button.data.id, "(%d+)")
									numberChain = numberChain:sub(1, string.len(numberChain) - string.len(lastButtonIdLength))
									print('После '..numberChain)
									break
								end
							end
						end
						for _, item in pairs(gameButtons) do
							local localNodes = item.nodes[buttonPath]
							if item.data.id == chain[table.maxn(chain)]  then
								lastX = math.ceil(gui.get_position(localNodes).x)
								lastY = math.ceil(gui.get_position(localNodes).y)
							end
							if item.data.id == chain[table.maxn(chain)-1] and table.maxn(chain) > 1 then
								preLastX = math.ceil(gui.get_position(localNodes).x)
								preLastY = math.ceil(gui.get_position(localNodes).y)
							elseif table.maxn(chain) == 1 then
								preLastX = 0
								preLastY = 0
							end
						end
						local selectedChars = gui.get_node("selectedChars")
						local selectedCharsText = gui.get_text(selectedChars)
						local selectedCharsTextLength = string.len(selectedCharsText)
						local newSelectedChars = string.sub(selectedCharsText, 1, selectedCharsTextLength - charSize)
						gui.set_text(selectedChars, newSelectedChars)	
					end
				end
			}
			switch[type]()
		end
	end
end

function findWordForHelp()
	local LevelWordArray = string.gmatch(Levels[LevelData.LevelNumber].Words, "%S+")
	for levelWord in LevelWordArray do
		local countWords = 0
		if table.maxn(completeWords) > 0 then
			for _, completeWord in pairs(completeWords) do
				if not compareWords(completeWord, levelWord) then
					countWords = countWords + 1
				end
			end
			if countWords == table.maxn(completeWords) then
				return levelWord
			end
		else
			return levelWord
		end
	end
end

function showHint ()
	local helpWordChars = {}
	if LevelData.СountHelp > 0 then
		local changeCountHelp = gui.get_node("countHelp")
		local help = gui.get_node("helpLine")
		local helpText = gui.get_text(help)
		local helpTextLength = string.len(helpText)
		helpWord = findWordForHelp()
		if helpWord ~= "" and helpTextLength ~= string.len(helpWord) then
			letter = helpWord:sub(helpTextLength + 1, helpTextLength + charSize)
			if Levels[LevelData.LevelNumber].Language == "ES" then
				if not (((letter >= 'a') and (letter <= 'z')) or ((letter >= 'A') and (letter <= 'Z'))) then
					dopValueForSizeChar = dopValueForSizeChar + 1
					letter = helpWord:sub(helpTextLength + 1, helpTextLength + charSize + dopValueForSizeChar)
				end
			end
			gui.set_text(help, helpText..letter)
			LevelData.СountHelp = LevelData.СountHelp - 1
			gui.set_text(changeCountHelp, LevelData.СountHelp)
		end		
	end
end