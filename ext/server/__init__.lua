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

    self.primaryTable = {"M39EBR","PP2000","MagpulPDR","P90","KH2002","PP-19","AEK971","MK11_RU","870","M98B","Jackhammer","A91","Pecheneg","SAIGA_20K","M27IAR","M16A4","HK417","AK74M_US","ACR","M4A1","SCAR-H","SCAR-L","M240","QBB-95","JNG90","UMP45","FAMAS","SteyrAug","L85A2","USAS-12","SVD_US","SVD","HK53","MK11","SPAS12","QBU-88_Sniper","QBZ-95B","G3A3","F2000","DAO-12","MTAR","Type88","SV98","M16_Burst","SKS","MP7","M16A4_RU","RPK-74M","M60","AN94","AK74M","SG553LB","AKS74u_US","SMAW","G36C","M1014","MP5K","M40A5","ASVal","AKS74u","L96","RPK-74M_US","LSAT","M4A1_RU","M416","M15","M249","M4","L86","M27IAR_RU","MG36"}
    self.secondaryTable = {"M93R","Taurus44_Scoped","M9_Silenced","M9_TacticalLight","MP412Rex","Taurus44","Glock17","M1911_Silenced","M1911_Tactical","MP443_Silenced","M9","Glock18","Glock17_Silenced","M1911","MP443_TacticalLight","M9_RU","M1911_Lit","MP443","MP443_US","Glock18_Silenced"}
    self.thirdSlotTable = {"FIM92","FGM148","Crossbow_Scoped_Cobra","MAV","M26Mass","UGS","M320_LVG","M320_HE","M320_SHG","M320_SMK","Crossbow_Scoped_RifleScope","RPG7","Medkit","Ammobag","Sa18IGLA","SOFLAM","M26Mass_Frag","M26Mass_Flechette","M26Mass_Slug"}
    self.fourthSlotTable = {"M224","Defib","EODBot","RadioBeacon","Repairtool","C4","Claymore"}
    self.knivesTable = {"Knife_Razor","Knife"}
    print("Registering Vars")
    
end

function RandomizerServer:RegisterEvents()
	Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)
    Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
    Events:Subscribe('Player:Respawn', self, self.Respawn)
    print("RegisterEvents running")
end

-- Store the reference of all the SoldierWeaponUnlockAssets that get loaded
function RandomizerServer:OnPartitionLoaded(partition)
	local instances = partition.instances

    for _, instance in pairs(instances) do
        
		if instance:Is('SoldierWeaponUnlockAsset') then
			
			local weaponUnlockAsset = SoldierWeaponUnlockAsset(instance)
		
			-- Weapons/SAIGA20K/U_SAIGA_20K --> SAIGA_20K
			local weaponName = weaponUnlockAsset.name:match("/U_.+"):sub(4)
			
			self.weaponTable[weaponName] = weaponUnlockAsset
		end
    end
end

-- Once the everything is loaded, store the UnlockAssets in each CustomizationUnlockParts array (each array is an attachment/sight/camo slot).
function RandomizerServer:OnLevelLoaded()
	
	for weaponName, weaponUnlockAsset in pairs(self.weaponTable) do
	
		if SoldierWeaponData(SoldierWeaponBlueprint(weaponUnlockAsset.weapon).object).customization ~= nil then
		
			self.unlockTables[weaponName] = {}
			
			local customizationUnlockParts = CustomizationTable(VeniceSoldierWeaponCustomizationAsset(SoldierWeaponData(SoldierWeaponBlueprint(weaponUnlockAsset.weapon).object).customization).customization).unlockParts
			
			for _, unlockParts in pairs(customizationUnlockParts) do
			
				for i, asset in pairs(unlockParts.selectableUnlocks) do
				
					local unlockAssetName = asset.debugUnlockId:gsub("U_.+_","")
					
					self.unlockTables[weaponName][i] = unlockAssetName
				end
			end
		end
	end
end

function RandomizerServer:OnEquipWeapon(player)

end

function RandomizerServer:ReplaceWeapons(player)
    print("Replace Weapons Firing")
    local primary = math.random(#self.primaryTable)
    local secondary = math.random(#self.secondaryTable)
    local thirdSlot = math.random(#self.thirdSlotTable)
    local fourthSlot = math.random(#self.fourthSlotTable)
    local primaryAttachments = {}
    local secondaryAttachments = {}
    local noAttachments = {}
    
    -- for i = 3, #args do
	-- 	attachments[i-2] = self.unlockTables[args[primary]][args[i]]
	-- end
    -- local tableLength = table.getn(self.weaponTable)
    print(self.unlockTables[self.primaryTable[primary]])
    print(#self.secondaryTable)
    player:SelectWeapon(WeaponSlot.WeaponSlot_0, self.weaponTable[self.primaryTable[primary]], noAttachments)
    player:SelectWeapon(WeaponSlot.WeaponSlot_1, self.weaponTable[self.secondaryTable[secondary]], noAttachments)
    player:SelectWeapon(WeaponSlot.WeaponSlot_2, self.weaponTable[self.thirdSlotTable[thirdSlot]], noAttachments)
    player:SelectWeapon(WeaponSlot.WeaponSlot_3, self.weaponTable[self.fourthSlotTable[fourthSlot]], noAttachments)    
end

function RandomizerServer:Respawn(player)
    print("On Spawn Firing")
    self:ReplaceWeapons(player)
end 


g_RandomizerServer = RandomizerServer()