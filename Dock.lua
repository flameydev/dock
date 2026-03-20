local dock = {}
-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
-- Storage
local activeKeys = {}
local binds = {}
local chordBinds = {}
local holdBinds = {}
local detectorBinds = {}
local otherInputBinds = {}
-- OtherInputs directory
dock.OtherInputs = {
	OpenMenu = "OpenMenu",
	CloseMenu = "CloseMenu",
}
-- Bind a callback to a single key
-- triggerOn: "ended" (default) or "began"
function dock.Bind(key: Enum.KeyCode, callback, triggerOn: string?)
	binds[key] = { callback = callback, triggerOn = triggerOn or "ended" }
end
-- Bind a callback to fire when all keys in the chord are held simultaneously
function dock.BindChord(keys: {Enum.KeyCode}, callback)
	table.insert(chordBinds, { keys = keys, callback = callback, fired = false })
end
-- Bind a callback to fire only if a key is held for at least `duration` seconds
function dock.BindHold(key: Enum.KeyCode, duration: number, callback)
	holdBinds[key] = { duration = duration, callback = callback, startTime = nil, fired = false }
end
-- Bind a callback to fire after a ClickDetector is clicked
function dock.BindClickDetector(object: ClickDetector, callback)
	local existing = detectorBinds[object]
	if existing then
		existing.connection:Disconnect()
	end
	local connection = object.MouseClick:Connect(callback)
	detectorBinds[object] = { callback = callback, connection = connection }
end
-- Bind a callback to a named other input
function dock.BindOther(inputName: string, callback)
	otherInputBinds[inputName] = callback
end
-- Fire a named other input manually
function dock.Fire(inputName: string)
	local cb = otherInputBinds[inputName]
	if cb then cb() end
end
-- Check if all keys in a chord are currently held
local function chordActive(keys)
	for _, key in ipairs(keys) do
		if not activeKeys[key] then
			return false
		end
	end
	return true
end
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	activeKeys[input.KeyCode] = true
	-- Regular bind (began)
	local bind = binds[input.KeyCode]
	if bind and bind.triggerOn == "began" then
		bind.callback()
	end
	-- Hold: record the start time
	local hold = holdBinds[input.KeyCode]
	if hold then
		hold.startTime = tick()
		hold.fired = false
	end
	-- Chord: check if any chord just became fully active
	for _, chord in ipairs(chordBinds) do
		if not chord.fired and chordActive(chord.keys) then
			chord.fired = true
			chord.callback()
		end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	-- Regular bind (ended)
	local bind = binds[input.KeyCode]
	if bind and bind.triggerOn == "ended" and activeKeys[input.KeyCode] then
		bind.callback()
	end
	-- Hold: cancel if released before firing
	local hold = holdBinds[input.KeyCode]
	if hold then
		hold.startTime = nil
		hold.fired = false
	end
	activeKeys[input.KeyCode] = nil
	-- Chord: reset fired state so the chord can trigger again next time
	for _, chord in ipairs(chordBinds) do
		if chord.fired then
			for _, key in ipairs(chord.keys) do
				if input.KeyCode == key then
					chord.fired = false
					break
				end
			end
		end
	end
end)
-- Hold: poll each frame to check if duration has been reached
RunService.Heartbeat:Connect(function()
	for _, hold in pairs(holdBinds) do
		if hold.startTime and not hold.fired then
			if tick() - hold.startTime >= hold.duration then
				hold.fired = true
				hold.callback()
			end
		end
	end
end)
-- Menu events
GuiService.MenuOpened:Connect(function()
	dock.Fire(dock.OtherInputs.OpenMenu)
end)
GuiService.MenuClosed:Connect(function()
	dock.Fire(dock.OtherInputs.CloseMenu)
end)
return dock
