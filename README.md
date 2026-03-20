# Dock
A clean, centralized input handler for Roblox — built on top of UserInputService.

Instead of scattering input listeners across your project, Dock gives you one place to register and manage all your input reactions.

---

## Installation
Copy `Dock.lua` into your project, then require it wherever you need it:
```lua
local Dock = require(path.to.Dock)
```

---

## API Reference

### `Dock.Bind(key, callback, triggerOn?)`
Binds a callback to a single key.
- `triggerOn` — `"ended"` (default) fires when the key is released, `"began"` fires immediately on press.
```lua
-- Fires when E is released
Dock.Bind(Enum.KeyCode.E, function()
    print("E pressed")
end)

-- Fires immediately when Space is pressed
Dock.Bind(Enum.KeyCode.Space, function()
    print("Space down")
end, "began")
```

---

### `Dock.BindChord(keys, callback)`
Fires when all keys in the table are held simultaneously.
```lua
Dock.BindChord({Enum.KeyCode.LeftShift, Enum.KeyCode.F}, function()
    print("Shift+F!")
end)
```

---

### `Dock.BindHold(key, duration, callback)`
Fires only if a key is held for at least `duration` seconds.
```lua
Dock.BindHold(Enum.KeyCode.G, 1.5, function()
    print("G held for 1.5 seconds")
end)
```

---

### `Dock.BindClickDetector(object, callback)`
Binds a callback to a ClickDetector. Safely replaces any existing bind on the same object.
```lua
Dock.BindClickDetector(workspace.Part.ClickDetector, function()
    print("Part clicked!")
end)
```

---

### `Dock.BindOther(inputName, callback)` and `Dock.Fire(inputName)`
Bind a callback to a named input event and fire it manually — or use one of Dock's built-in named events.
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

## Known Limitations
- `BindOther` only supports one callback per input name — last bind wins.
- Jump support is planned for v2.
- Group tagging and context switching are planned for v2.

---

## Contributing
Contributions are welcome! If you've got a feature idea or bug fix, open an issue or pull request.
