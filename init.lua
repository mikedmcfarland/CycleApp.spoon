local CycleApp = {}
CycleApp.__index = CycleApp

-- metadata
CycleApp.name = "cycleApp"
CycleApp.version = "0.1"
CycleApp.author = "mikedmcfarland <mikedmcfarland@gmail.com>"
CycleApp.homepage = "https://github.com/mikedmcfarland/CycleApp.spoon"

local logger = hs.logger.new("CycleApp", "error")
CycleApp.logger = logger

-- initialization
function CycleApp:init()
    logger.d("init")
    return self
end

function CycleApp:start()
    logger.d("start")
    local windows = {}
    self.windows = windows

    self.windowFilter =
        hs.window.filter.new():subscribe(
        {
            [hs.window.filter.windowCreated] = function(window, appName, eventName)
                logger.d(eventName, "adding", appName, window:id())
                ListAdd(windows, window)
            end,
            [hs.window.filter.windowDestroyed] = function(window, appName, eventName)
                logger.d(eventName, "removing", appName, window:id())
                ListRemove(windows, window)
            end,
            [hs.window.filter.windowFocused] = function(window, appName, eventName)
                logger.d(eventName, "adding", appName, window:id())
                ListAdd(windows, window)
            end
        }
    )

    self.windows = windows
    return self
end

function CycleApp:stop()
    logger.d("stop")
    self.windowFilter.unsubscribeAll()
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
    logger.i("cycle current window", app:title(), window:id())

    local windows = self:appWindows(app)
    if #windows <= 1 then
        logger.i("no windows to switch to")
        return
    end

    local currentIndex = hs.fnutils.indexOf(windows, window)

    local nextIndex = currentIndex + 1
    if nextIndex > #windows then
        nextIndex = 1
    end
    local nextWindow = windows[nextIndex]
    logger.i("cycle focusing", nextWindow:title(), window:id())
    nextWindow:focus()
end

function CycleApp:bindHotkeys(mapping)
    self.logger.d("bindingHotkeys")
    local spec = {
        cycle = hs.fnutils.partial(self.cycle, self)
    }
    hs.spoons.bindHotkeysToSpec(spec, mapping)
    return self
end

function ListAdd(list, item)
    for _, a in ipairs(list) do
        if a == item then
            return
        end
    end

    table.insert(list, item)
end

function ListRemove(list, item)
    for i, a in ipairs(list) do
        if a == item then
            table.remove(list, i)
            return
        end
    end
end

return CycleApp
