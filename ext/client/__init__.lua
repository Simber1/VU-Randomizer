print("Randomizer Mod Loaded")
class 'RandomizerClient'

function RandomizerClient:__init()
    print('Hello world!')
    print(MyModVersion)
 
    self:RegisterVars()
    self:RegisterEvents()
end

function RandomizerClient:RegisterEvents()
    Events:Subscribe('Extension:Loaded',self, self.StartUI) --Loading webui
    print("RegisterEvents running")
end


function RandomizerClient:StartUI()
    WebUI:Init() 
    WebUI.Call('Show')
end
