local CycleApp = {}
CycleApp.__index = CycleApp

-- metadata
CycleApp.name = "cycleApp"
CycleApp.version = "0.1"
CycleApp.author = "mikedmcfarland <mikedmcfarland@gmail.com>"
CycleApp.homepage = "https://github.com/mikedmcfarland/CycleApp.spoon"

-- initialization
function CycleApp:init(_)
    return self
end

function CycleApp:appWindows(app)
    local appWindows =
        hs.fnutils.filter(
        app:allWindows(),
        function(win)
            return win:isStandard()
        end
    )

    table.sort(
        appWindows,
        function(a, b)
            return a:id() < b:id()
        end
    )
    return appWindows
end

function CycleApp:cycle()
    local window = hs.window.frontmostWindow()
    if window ~= nil then
        print("window " .. window:title())
    else
        print("window is nil")
    end

    local app = window:application()
    print("app " .. app:title())

    local windows = self:appWindows(app)
    if #windows == 1 then
        -- we have only 1 window, not switching
        return
    end

    local currentIndex = hs.fnutils.indexOf(windows, window)
    print("currentIndex " .. currentIndex)
    print("allAppWindows length" .. #windows)

    local nextIndex = currentIndex + 1
    if nextIndex > #windows then
        nextIndex = 1
    end
    print("nextIndex " .. nextIndex)
    local nextWindow = windows[nextIndex]
    print("nextWindow " .. nextWindow:title())
    nextWindow:focus()
end

function CycleApp:setDebug(value)
    self.debug = value
end

function CycleApp:print(message)
    if self.debug ~= nil and self.debug then
        print("cycleApp: " .. message)
    end
end

function CycleApp:bindHotkeys(mapping)
    self.print("bindingHotkeys")
    local spec = {
        cycle = hs.fnutils.partial(self.cycle, self)
    }
    hs.spoons.bindHotkeysToSpec(spec, mapping)
    return self
end

function Wrap(max, min, x)
    return (((x - min) % (max - min)) + (max - min)) % (max - min) + min
end

return CycleApp
