class 'RandomizerClient'
require('__shared/common')

function RandomizerClient:__init()
    print("Randomizer Loaded Locally")
    self:RegisterEvents()
end

function RandomizerClient:RegisterEvents()
    Events:Subscribe('Extension:Loaded', self, self.WebUIInit)
    Events:Subscribe('WebUIEvent', self, self.RecivedWebEvent)
    NetEvents:Subscribe('RespawnWeaponNames', self, self.NetEvent)
end

function RandomizerClient:WebUIInit()
    WebUI:Init()
    -- WebUI:Call('Hide')
end

function RandomizerClient:RecivedWebEvent(data)
    print(data)
end

function RandomizerClient:NetEvent(data)
    WebUI:ExecuteJS("show()")
    -- WebUI:Call('Show')
    Execute = 'setWeaponName("'..data..'");'
    WebUI:ExecuteJS(Execute)
    local timeDelayed = 0
    Events:Subscribe('Engine:Update', function(deltaTime) 
        timeDelayed = timeDelayed + deltaTime
        if timeDelayed >= 5 then
            print("Fading")
            WebUI:ExecuteJS("fade()")
            timeDelayed = 0
            Events:Unsubscribe('Engine:Update')
        end
        if timeDelayed >= 5.8 then
            print("hiding")
            -- WebUI:call("Hide")
            timeDelayed = 0
            Events:Unsubscribe('Engine:Update')
        end
    end)
end

g_RandomizerClient = RandomizerClient()