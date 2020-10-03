class 'RandomizerServer'
require('__shared/common')

function RandomizerServer:__init()
    print('Hello world!')
    print(MyModVersion)
 
    self:RegisterVars()
    self:RegisterEvents()
end

function RandomizerServer:RegisterVars()
	self.weaponTable = {}
    self.unlockTables = {}
    self.counter = 0 
    print("Registering Vars")
    
end

function RandomizerServer:RegisterEvents()
	Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)
    Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
    Events:Subscribe('Player:Respawn', self, self.Respawn)
    NetEvents:Subscribe('ConsoleWeapons:EquipWeapon', self, self.OnEquipWeapon)
    print("RegisterEvents running")
end

-- Store the reference of all the SoldierWeaponUnlockAssets that get loaded
function RandomizerServer:OnPartitionLoaded(partition)
	local instances = partition.instances

    for i, instance in pairs(instances) do
        
		if instance:Is('SoldierWeaponUnlockAsset') then
            self.counter = self.counter + 1
            print(self.counter)
			local weaponUnlockAsset = SoldierWeaponUnlockAsset(instance)			
			self.weaponTable[self.counter] = weaponUnlockAsset
		end
    end

    
end

-- Once the everything is loaded, store the UnlockAssets in each CustomizationUnlockParts array (each array is an attachment/sight/camo slot).
function RandomizerServer:OnLevelLoaded()
    print(self.weaponTable)

	for i, weaponUnlockAsset in pairs(self.weaponTable) do
	
		if SoldierWeaponData(SoldierWeaponBlueprint(weaponUnlockAsset.weapon).object).customization ~= nil then -- Gadgets dont have customization
		
			self.unlockTables[i] = {}
			
			local customizationUnlockParts = CustomizationTable(VeniceSoldierWeaponCustomizationAsset(SoldierWeaponData(SoldierWeaponBlueprint(weaponUnlockAsset.weapon).object).customization).customization).unlockParts
			
			for _, unlockParts in pairs(customizationUnlockParts) do
			
				for k, asset in pairs(unlockParts.selectableUnlocks) do
				
					-- Weapons/AN94/U_AN94_Acog --> Acog
					local unlockAssetName = asset.debugUnlockId:gsub("U_.+_","")

					self.unlockTables[i][k] = asset
				end
			end
		end
    end
end

function RandomizerServer:OnEquipWeapon(player)

end

function RandomizerServer:ReplaceWeapons(player)
    print("Replace Weapons Firing")
    local attachments = {}
    -- local tableLength = table.getn(self.weaponTable)
    player:SelectWeapon(0, self.weaponTable[math.random(172)], attachments)
    player:SelectWeapon(1, self.weaponTable[math.random(172)], attachments)
end

function RandomizerServer:Respawn(player)
    print("On Spawn Firing")
    self:ReplaceWeapons(player)
end 


g_RandomizerServer = RandomizerServer()