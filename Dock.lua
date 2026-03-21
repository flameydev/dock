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
-- Auto-ID counters (separate per bind type)
local bindCount = 0
local chordCount = 0
local holdCount = 0
local detectorCount = 0
local otherCount = 0
-- OtherInputs directory
dock.OtherInputs = {
	OpenMenu = "OpenMenu",
	CloseMenu = "CloseMenu",
}
-- Bind a callback to a single key
-- triggerOn: "ended" (default) or "began"
function dock.Bind(key: Enum.KeyCode, callback, triggerOn: string?, id: string?)
	local resolvedId = id or bindCount
	bindCount += 1
	binds[resolvedId] = { key = key, callback = callback, triggerOn = triggerOn or "ended" }
end
-- Bind a callback to fire when all keys in the chord are held simultaneously
function dock.BindChord(keys: {Enum.KeyCode}, callback, id: string?)
	local resolvedId = id or chordCount
	chordCount += 1
	chordBinds[resolvedId] = { keys = keys, callback = callback, fired = false }
end
-- Bind a callback to fire only if a key is held for at least `duration` seconds
function dock.BindHold(key: Enum.KeyCode, duration: number, callback, id: string?)
	local resolvedId = id or holdCount
	holdCount += 1
	holdBinds[resolvedId] = { key = key, duration = duration, callback = callback, startTime = nil, fired = false }
end
-- Bind a callback to fire after a ClickDetector is clicked
function dock.BindClickDetector(object: ClickDetector, callback, id: string?)
	local resolvedId = id or detectorCount
	detectorCount += 1
	local existing = detectorBinds[resolvedId]
	if existing then
		existing.connection:Disconnect()
	end
	local connection = object.MouseClick:Connect(callback)
	detectorBinds[resolvedId] = { object = object, callback = callback, connection = connection }
end
-- Bind a callback to a named other input
function dock.BindOther(inputName: string, callback, id: string?)
	local resolvedId = id or otherCount
	otherCount += 1
	otherInputBinds[resolvedId] = { inputName = inputName, callback = callback }
end
-- Fire a named other input manually
function dock.Fire(inputName: string)
	for _, bind in pairs(otherInputBinds) do
		if bind.inputName == inputName then
			bind.callback()
		end
	end
end
-- Unbind by ID, automatically checks all storage tables
-- store: optional, "binds", "chordBinds", "holdBinds", "detectorBinds", "otherInputBinds"
function dock.Unbind(id: string | number, store: string?)
	local targets = store and { store } or { "binds", "chordBinds", "holdBinds", "detectorBinds", "otherInputBinds" }
	local storeMap = {
		binds = binds,
		chordBinds = chordBinds,
		holdBinds = holdBinds,
		detectorBinds = detectorBinds,
		otherInputBinds = otherInputBinds,
	}
	for _, storeName in ipairs(targets) do
		local t = storeMap[storeName]
		if t and t[id] then
			if storeName == "detectorBinds" then
				t[id].connection:Disconnect()
			end
			t[id] = nil
			return
		end
	end
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
	-- Regular binds (began)
	for _, bind in pairs(binds) do
		if bind.key == input.KeyCode and bind.triggerOn == "began" then
			bind.callback()
		end
	end
	-- Hold: record start time
	for _, hold in pairs(holdBinds) do
		if hold.key == input.KeyCode then
			hold.startTime = os.clock()
			hold.fired = false
		end
	end
	-- Chord: check if any chord just became fully active
	for _, chord in pairs(chordBinds) do
		if not chord.fired and chordActive(chord.keys) then
			chord.fired = true
			chord.callback()
		end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	-- Regular binds (ended)
	for _, bind in pairs(binds) do
		if bind.key == input.KeyCode and bind.triggerOn == "ended" and activeKeys[input.KeyCode] then
			bind.callback()
		end
	end
	-- Hold: cancel if released before firing
	for _, hold in pairs(holdBinds) do
		if hold.key == input.KeyCode then
			hold.startTime = nil
			hold.fired = false
		end
	end
	activeKeys[input.KeyCode] = nil
	-- Chord: reset fired state
	for _, chord in pairs(chordBinds) do
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
-- Hold: poll each frame
RunService.Heartbeat:Connect(function()
	for _, hold in pairs(holdBinds) do
		if hold.startTime and not hold.fired then
			if os.clock() - hold.startTime >= hold.duration then
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
print("🖱️Loaded and running Dock v2.0 by meflamey!")
return dock
