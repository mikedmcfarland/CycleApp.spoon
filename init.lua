local CycleApp = {}
CycleApp.__index = CycleApp

local obj = CycleApp
obj.__index = obj

-- metadata
CycleApp.name = "cycleApp"
CycleApp.version = "0.1"
CycleApp.author = "mikedmcfarland <mikedmcfarland@gmail.com>"
CycleApp.homepage = "https://github.com/mikedmcfarland/CycleApp.spoon"

-- initialization
function CycleApp:init(_)
    return self
end

function CycleApp:cycle()
    local window = hs.window.frontmostWindow()
    self.print("window " .. window)
    local app = window.application()
    self.print("app " .. app)

    local allAppWindows =
        hs.fnutils.filter(
        app:allWindows(),
        function(win)
            return win:isStandard()
        end
    )

    table.sort(
        allAppWindows,
        function(a, b)
            return a:id() < b:id()
        end
    )

    local currentIndex = hs.fnutils.indexOf(allAppWindows, window)
    local nextIndex = Wrap(#allAppWindows, 0, currentIndex + 1)
    local nextWindow = allAppWindows[nextIndex]
    self.print("nextWindow " .. nextWindow)
    nextWindow.focus()
end

function CycleApp:setDebug(value)
    self.debug = value
end

function CycleApp:print(message)
    if self.debug ~= nil and self.debug then
        print("cycleApp: " .. message)
    end
end

function CycleApp:bindHotKeys(mapping)
    self.print("bindingHotKeys" .. mapping)
    local spec = {
        cycle = hs.fnutils.partial(self.cycle, self)
    }
    hs.spoons.bindHotkeysToSpec(spec, mapping)
    return self
end

function Wrap(max, min, x)
    return (((x - min) % (max - min)) + (max - min)) % (max - min) + min
end
