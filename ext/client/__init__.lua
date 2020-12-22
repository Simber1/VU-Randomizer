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
    Execute = 'setWeaponName("'..data..'");'
    WebUI:ExecuteJS(Execute)
    WebUI:ExecuteJS("show()")
    local timeDelayed = 0
    Events:Subscribe('Engine:Update', function(deltaTime) 
        timeDelayed = timeDelayed + deltaTime
        if timeDelayed >= 5 then
            WebUI:ExecuteJS("fade()")
            timeDelayed = 0
            Events:Unsubscribe('Engine:Update')
        end
    end)
end

g_RandomizerClient = RandomizerClient()