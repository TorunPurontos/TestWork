require 'configFiles.constants'
require 'configFiles.gameButtons'

function changeTexture (node, type)
	local changeSize = "size"
	local changeRotation = "rotation.z"
	switch = {
		["swap"] = function () 
			local newButtonSize = defaultButtonSize - defaultButtonSize * 0.3
			gui.animate(node, changeSize, newButtonSize, gui.EASING_INOUTQUART, durationButtonAnimation, delayButtonAnimation, nil, nil)
			gui.animate(node, changeRotation, newButtonRotationZ, gui.EASING_INOUTQUART, durationButtonAnimation, delayButtonAnimation, nil, nil)
		end,
		["reset"] = function () 
			for i, button in pairs(gameButtons) do
				local buttonNodes = button.nodes[buttonPath]
				gui.animate(buttonNodes, changeSize, defaultButtonSize, gui.EASING_INOUTQUART, durationButtonAnimation, delayButtonAnimation, nil, nil)
				gui.animate(buttonNodes, changeRotation, defaultButtonRotation, gui.EASING_INOUTQUART, durationButtonAnimation, delayButtonAnimation, nil, nil)
			end
		end,
		["complete"] = function ()
			gui.play_flipbook(node, "gameButtonGreen")
			gui.animate(node, changeSize, defaultButtonSize, gui.EASING_INOUTQUART, durationButtonAnimation, delayButtonAnimation, nil, nil)
			gui.animate(node, changeRotation, defaultButtonRotation, gui.EASING_INOUTQUART, durationButtonAnimation, delayButtonAnimation, nil, nil)
		end,
		["free"] = function ()
			gui.animate(node, changeSize, defaultButtonSize, gui.EASING_INOUTQUART, durationButtonAnimation, delayButtonAnimation, nil, nil)
			gui.animate(node, changeRotation, defaultButtonRotation, gui.EASING_INOUTQUART, durationButtonAnimation, delayButtonAnimation, nil, nil)
		end,
		["reload"] = function ()
			for i, button in pairs(gameButtons) do
				if blockList (blockedButtons, button.data.id) then
					local buttonNodes = button.nodes[buttonPath]
					gui.play_flipbook(buttonNodes, "gameButtonGreen")
				end
			end
		end
	}
	switch[type]()
end