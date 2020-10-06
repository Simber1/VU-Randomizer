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
end

function RandomizerClient:RecivedWebEvent(data)
    print(data)
end

function RandomizerClient:NetEvent(data)
    Execute = 'setWeaponName("'..data..'");'
    WebUI:ExecuteJS(Execute)
end

g_RandomizerClient = RandomizerClient()