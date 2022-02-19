local CycleApp = {}
CycleApp.__index = CycleApp

-- metadata
CycleApp.name = "cycleApp"
CycleApp.version = "0.1"
CycleApp.author = "mikedmcfarland <mikedmcfarland@gmail.com>"
CycleApp.homepage = "https://github.com/mikedmcfarland/CycleApp.spoon"

-- initialization
function CycleApp:init(_)
    local windows = {}
    self.windows = windows

    self.windowFilter =
        hs.window.filter.new():subscribe(
        {
            [hs.window.filter.windowCreated] = function(window, appName, _)
                print("adding " .. appName .. ":" .. window:id())
                ListAdd(windows, window)
            end,
            [hs.window.filter.windowDestroyed] = function(window, appName, _)
                print("removing " .. appName .. ":" .. window:id())
                ListRemove(windows, window)
            end,
            [hs.window.filter.windowFocused] = function(window, appName, _)
                print("adding " .. appName .. ":" .. window:id())
                ListAdd(windows, window)
            end
        }
    )

    self.windows = windows

    return self
end

function CycleApp:appWindows(app)
    local windows =
        hs.fnutils.filter(
        self.windows,
        function(win)
            return win:application():name() == app:name()
        end
    )
    table.sort(
        windows,
        function(a, b)
            return a:id() > b:id()
        end
    )
    return windows
end

function CycleApp:cycle()
    local window = hs.window.frontmostWindow()
    local app = window:application()
    print("current " .. app:title() .. ":" .. window:id())

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

function ListAdd(list, item)
    for _, a in ipairs(list) do
        if a:id() == item:id() then
            return
        end
    end

    table.insert(list, item)
end

function ListRemove(list, item)
    for i, a in ipairs(list) do
        if a:id() == item:id() then
            table.remove(list, i)
            return
        end
    end
end

return CycleApp
