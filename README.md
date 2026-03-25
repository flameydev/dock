# Dock
A clean, centralized input handler for Roblox — built on top of UserInputService.
Instead of scattering input listeners across your project, Dock gives you one place to register and manage all your input reactions.

## Why Dock?
Dock manages to do pretty much everything UserInputService can, just cleaner, more readable, and with some extra features.
Below is a comparison of the same behavior implemented using Dock and UserInputService.

```lua
-- Using Dock:
Dock.Bind(Enum.KeyCode.R, function()
    print("[DOCK]: R was pressed!")
end, "began")

-- Using UserInputService:
UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.R then
        print("[UIS]: R was pressed!")
    end
end)
```

---

## Installation
Copy `Dock.luau` into your project, then require it wherever you need to detect input:
```lua
local Dock = require(path.to.Dock)
```
You can also download the RBXM file directly and insert it into your project.

---

## API Reference

### `Dock.Bind(key, callback, triggerOn?, id?)`
Binds a callback to a single key.
- `triggerOn` — `"ended"` (default) fires when the key is released, `"began"` fires immediately on press.
- `id` — optional string ID for later reference. Auto-assigned if not provided.
```lua
-- Fires when E is released
Dock.Bind(Enum.KeyCode.E, function()
    print("E was released!")
end)

-- Fires immediately when Space is pressed, with a custom ID
Dock.Bind(Enum.KeyCode.Space, function()
    print("Space was pressed!")
end, "began", "Jump")
```

---

### `Dock.BindChord(keys, callback, id?)`
Fires when all keys in the table are held simultaneously.
- `id` — optional string ID for later reference. Auto-assigned if not provided.
```lua
Dock.BindChord({Enum.KeyCode.LeftShift, Enum.KeyCode.F}, function()
    print("Shift and F were pressed simultaneously!")
end, "SprintAttack")
```

---

### `Dock.BindHold(key, duration, callback, id?)`
Fires only if a key is held for at least `duration` seconds.
- `id` — optional string ID for later reference. Auto-assigned if not provided.
```lua
Dock.BindHold(Enum.KeyCode.G, 1.5, function()
    print("G was held for 1.5 seconds")
end, "ChargeAttack")
```

---

### `Dock.BindClickDetector(object, callback, id?)`
Binds a callback to a ClickDetector. Safely replaces any existing bind on the same object.
- `id` — optional string ID for later reference. Auto-assigned if not provided.
```lua
Dock.BindClickDetector(workspace.Part.ClickDetector, function()
    print("Part was clicked!")
end, "DoorClick")
```

---

### `Dock.BindOther(inputName, callback, id?)` and `Dock.Fire(inputName)`
Bind a callback to a named input event and fire it manually — or use one of Dock's built-in named events.
- `id` — optional string ID for later reference. Auto-assigned if not provided.
```lua
-- Built-in: Roblox pause menu
Dock.BindOther(Dock.OtherInputs.OpenMenu, function()
    print("Menu opened")
end)

Dock.BindOther(Dock.OtherInputs.CloseMenu, function()
    print("Menu closed")
end)

-- Custom named event
Dock.BindOther("MyEvent", function()
    print("Fired!")
end)

Dock.Fire("MyEvent")
```

---

### `Dock.Unbind(id, store?)`
Unbinds by ID. Searches all storage tables by default, or a specific one if `store` is provided.
- `store` — optional, one of `"binds"`, `"chordBinds"`, `"holdBinds"`, `"detectorBinds"`, `"otherInputBinds"`.
```lua
-- Search all stores
Dock.Unbind("Jump")

-- Only search chordBinds
Dock.Unbind("SprintAttack", "chordBinds")
```

---

## Known Limitations
- No method to receive all inputs from a client.
- No error handling.
- Input Binds for instances in Workspace are limited to ClickDetectors only.

---

## Contributing & Support
Contributions are more than welcome! If you've got a feature idea or a bug fix, open an issue or pull request. I will try my best to look at all of them.

If you need support with anything related to Dock, feel free to ask in the Discord server linked below. You can DM me on Discord for the latest beta version of Dock (under construction at the moment)

Link: https://discord.gg/a6r8uGDQqw
