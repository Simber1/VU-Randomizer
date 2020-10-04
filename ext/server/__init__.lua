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

    -- If you want to remove any weapon from the pool just remove it from this list
    self.primaryTable = {"M39EBR","PP2000","MagpulPDR","P90","KH2002","PP-19","AEK971","MK11_RU","870","M98B","Jackhammer","A91","Pecheneg","SAIGA_20K","M27IAR","M16A4","HK417","AK74M_US","ACR","M4A1","SCAR-H","SCAR-L","M240","QBB-95","JNG90","UMP45","FAMAS","SteyrAug","L85A2","USAS-12","SVD_US","SVD","HK53","MK11","SPAS12","QBU-88_Sniper","QBZ-95B","G3A3","F2000","DAO-12","MTAR","Type88","SV98","M16_Burst","SKS","MP7","M16A4_RU","RPK-74M","M60","AN94","AK74M","SG553LB","AKS74u_US","G36C","M1014","MP5K","M40A5","ASVal","AKS74u","L96","RPK-74M_US","LSAT","M4A1_RU","M416","M249","M4","L86","M27IAR_RU","MG36"}
    self.secondaryTable = {"M93R","Taurus44_Scoped","M9_Silenced","M9_TacticalLight","MP412Rex","Taurus44","Glock17","M1911_Silenced","M1911_Tactical","MP443_Silenced","M9","Glock18","Glock17_Silenced","M1911","MP443_TacticalLight","M9_RU","M1911_Lit","MP443","MP443_US","Glock18_Silenced"}
    self.thirdSlotTable = {"FIM92","SMAW","FGM148","Crossbow_Scoped_Cobra","MAV","M26Mass","UGS","M320_LVG","M320_HE","M320_SHG","M320_SMK","Crossbow_Scoped_RifleScope","RPG7","Medkit","Ammobag","Sa18IGLA","SOFLAM","M26Mass_Frag","M26Mass_Flechette","M26Mass_Slug"}
    self.fourthSlotTable = {"M224","Defib","EODBot","RadioBeacon","Repairtool","C4","M15","Claymore"}
    self.knivesTable = {"Knife_Razor","Knife"}
    self.bagsTable = {"Medkit","Ammobag"}
    self.sightTable = {"BallisticScope","scope","Scope","PKA","IRNV","NoOptics","PSO-1","PK-AS","PKS-07","Acog","ACOG","M145","Kobra","EOTech","Eotech","RX01","RifleScope"}
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
            if weaponName == "Defib" then
                print(weaponUnlockAsset.typeInfo)
            end
			self.weaponTable[weaponName] = weaponUnlockAsset
		end
    end
end

-- Once the everything is loaded, store the UnlockAssets in each CustomizationUnlockParts array (each array is an attachment/sight/camo slot).
function RandomizerServer:OnLevelLoaded()
	
	for weaponName, weaponUnlockAsset in pairs(self.weaponTable) do
	
		if SoldierWeaponData(SoldierWeaponBlueprint(weaponUnlockAsset.weapon).object).customization ~= nil then -- Gadgets dont have customization
		
			self.unlockTables[weaponName] = {}
			
			local customizationUnlockParts = CustomizationTable(VeniceSoldierWeaponCustomizationAsset(SoldierWeaponData(SoldierWeaponBlueprint(weaponUnlockAsset.weapon).object).customization).customization).unlockParts
			
			for _, unlockParts in pairs(customizationUnlockParts) do
			
				for _, asset in pairs(unlockParts.selectableUnlocks) do
				
					-- Weapons/AN94/U_AN94_Acog --> Acog
					local unlockAssetName = asset.debugUnlockId:gsub("U_.+_","")

					self.unlockTables[weaponName][unlockAssetName] = asset
				end
            end
		end
	end
end

function RandomizerServer:OnEquipWeapon(player)

end

function RandomizerServer:ReplaceWeapons(player)

    math.randomseed(SharedUtils:GetTimeMS())

    local primaryWeaponName = self.primaryTable[math.random(#self.primaryTable)]
    local primaryWeapon = self.weaponTable[primaryWeaponName]

    local secondaryWeaponName = self.secondaryTable[math.random(#self.secondaryTable)]
    local secondaryWeapon = self.weaponTable[secondaryWeaponName]

    local thirdSlotWeaponName = self.thirdSlotTable[math.random(#self.thirdSlotTable)]
    local thirdSlotWeapon = self.weaponTable[thirdSlotWeaponName]

    local fourthSlotWeaponName = self.fourthSlotTable[math.random(#self.fourthSlotTable)]
    local fourthSlotWeapon = self.weaponTable[fourthSlotWeaponName]

    local knifeWeapon = self.weaponTable[self.knivesTable[math.random(#self.knivesTable)]]

    local primaryAttachments = {}

    local noAttachments = {}
    local noOpticAttachment = {}
    local possibleSights = {}
    print(self.sightTable)
    print(#self.sightTable)
    for i=1, #self.sightTable do
        if self.unlockTables[primaryWeaponName][self.sightTable[i]] ~= nil then
            table.insert(possibleSights, self.unlockTables[primaryWeaponName][self.sightTable[i]])
        end
    end
    local attachments = {}
    

    player:SelectWeapon(WeaponSlot.WeaponSlot_0, primaryWeapon, {possibleSights[math.random(#possibleSights)]})
    player:SelectWeapon(WeaponSlot.WeaponSlot_1, secondaryWeapon, noAttachments)
    local empty = SoldierWeaponUnlockAsset()
    print(thirdSlotWeaponName)
    if thirdSlotWeaponName == self.bagsTable[1] or thirdSlotWeaponName == self.bagsTable[2] then
        print("In slot 4,5")
         player:SelectWeapon(WeaponSlot.WeaponSlot_2, knifeWeapon, noAttachments) --Trying to remove the players weapons in slots 2 and 3
        -- player:SelectWeapon(WeaponSlot.WeaponSlot_3, SoldierWeaponUnlockAsset(), noAttachments)
        player:SelectWeapon(WeaponSlot.WeaponSlot_4, thirdSlotWeapon, noAttachments)
        player:SelectWeapon(WeaponSlot.WeaponSlot_5, fourthSlotWeapon, noAttachments)
    else
        print("In slot 2,3")
        player:SelectWeapon(WeaponSlot.WeaponSlot_2, thirdSlotWeapon, noAttachments)
        -- player:SelectWeapon(WeaponSlot.WeaponSlot_3, SoldierWeaponUnlockAsset(), noAttachments) --Trying to remove the players weapons in slots 3 and 4
        player:SelectWeapon(WeaponSlot.WeaponSlot_4, knifeWeapon, noAttachments)
        player:SelectWeapon(WeaponSlot.WeaponSlot_5, fourthSlotWeapon, noAttachments)
    end
    player:SelectWeapon(WeaponSlot.WeaponSlot_7, knifeWeapon, noAttachments)     
end

function RandomizerServer:Respawn(player)
    print("On Spawn Firing")
    self:ReplaceWeapons(player)
end


g_RandomizerServer = RandomizerServer()