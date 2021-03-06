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
    self.primaryTable = {"M39EBR","PP2000","MagpulPDR","P90","KH2002","PP-19","AEK971","870","M98B","Jackhammer","A91","Pecheneg","SAIGA_20K","M27IAR","M16A4","HK417","ACR","M4A1","SCAR-H","SCAR-L","M240","QBB-95","JNG90","UMP45","FAMAS","SteyrAug","L85A2","USAS-12","SVD","HK53","MK11","SPAS12","QBU-88_Sniper","QBZ-95B","G3A3","F2000","DAO-12","MTAR","Type88","SV98","M16_Burst","SKS","MP7","RPK-74M","M60","AN94","AK74M","SG553LB","G36C","M1014","MP5K","M40A5","ASVal","AKS74u","L96","LSAT","M416","M249","M4","L86","MG36"}
    self.secondaryTable = {"M93R","Taurus44_Scoped","M9_Silenced","M9_TacticalLight","MP412Rex","Taurus44","Glock17","M1911_Silenced","M1911_Tactical","MP443_Silenced","M9","Glock18","Glock17_Silenced","M1911","MP443_TacticalLight","M1911_Lit","MP443","Glock18_Silenced"}
    self.thirdSlotTable = {"FIM92","SMAW","FGM148","Crossbow_Scoped_Cobra","MAV","M26Mass","UGS","M320_LVG","M320_HE","M320_SHG","M320_SMK","Crossbow_Scoped_RifleScope","RPG7","Medkit","Ammobag","Sa18IGLA","SOFLAM","M26Mass_Frag","M26Mass_Flechette","M26Mass_Slug"}
    self.fourthSlotTable = {"M224","Defib","EODBot","RadioBeacon","Repairtool","C4","M15","Claymore"}
    self.knivesTable = {"Knife_Razor","Knife"}
    self.bagsTable = {"Medkit","Ammobag"}
    self.grenadeTable = {"M67"}
    self.sightTable = {"BallisticScope","scope","Scope","PKA","IRNV","NoOptics","PSO-1","PK-AS","PKS-07","Acog","ACOG","M145","Kobra","EOTech","Eotech","RX01","RifleScope"}
    self.barrelAttachmentsTable = {"ExtendedMag","TargetPointer","HeavyBarrel","Flashlight","Flashsuppressor","Suppressor","FlashSuppressor","Silencer","Barrel"}
    self.railAttachmentsTable = {"StraightPull","Bipod","Foregrip","NoSecondaryRail"}  
    self.shotgunRoundsTable = {"12gBuckshot","Slug","Flechette","Frag"}
    print("Registering Vars")
    
end

function RandomizerServer:RegisterEvents()
	Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)
    Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
    Events:Subscribe('Player:Respawn', self, self.Respawn)
    Events:Subscribe('Player:KitPickup', self, self.KitPickup)
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

function RandomizerServer:Respawn(player)
    print("On Spawn Firing")
    if player.soldier == nil then
        print("Soldier didn't exist")
    end

    local timeDelayed = 0.0

    Events:Subscribe('Engine:Update', function(deltaTime) 
        timeDelayed = timeDelayed + deltaTime
        if timeDelayed >= 0.09 then
            print("Delayed spawn")
            self:ReplaceWeapons(player)
            timeDelayed = 0
            Events:Unsubscribe('Engine:Update')
        end
    end)

end

function RandomizerServer:ReplaceWeapons(player)

    --Remove all of the players customizations
    local noWeaponsCustomizeSoldier = CustomizeSoldierData()
    noWeaponsCustomizeSoldier.removeAllExistingWeapons = true
    player.soldier:ApplyCustomization(noWeaponsCustomizeSoldier)

    local noAttachments = {}
    --Seed the randomness
    math.randomseed(SharedUtils:GetTimeMS())
    
    --Generates a primaryWeaponName randomly from the primaryWeaponsTable, It's needed for the attachments so it has to be done here and not in the weapon generation
    local primaryWeaponName = self.primaryTable[math.random(#self.primaryTable)]

    Weapons = self:WeaponGeneration(primaryWeaponName)
    -- Returns a table weapons, 1 is Primary, 2 is Secondary, 3 is Third Slot, 4 is 4th Slot, 5 is Knife
    local primaryAttachments = self:RandomizerAttachments(primaryWeaponName)

    --Spawning the player with a random primary and the attachments from above
    player:SelectWeapon(WeaponSlot.WeaponSlot_0, Weapons[1], primaryAttachments)
    player:SelectWeapon(WeaponSlot.WeaponSlot_1, Weapons[2], noAttachments)

    --If the weapon is a medic or ammo bag put it in slot 4 if not put the gadget in slot 3
    local slotThreeName = Weapons[3].name:match("/U_.+"):sub(4)
    if slotThreeName == self.bagsTable[1] or slotThreeName == self.bagsTable[2] then
        player:SelectWeapon(WeaponSlot.WeaponSlot_4, Weapons[3], noAttachments)
        player:SelectWeapon(WeaponSlot.WeaponSlot_5, Weapons[4], noAttachments)
    else
        player:SelectWeapon(WeaponSlot.WeaponSlot_3, Weapons[3], noAttachments) 
        player:SelectWeapon(WeaponSlot.WeaponSlot_5, Weapons[4], noAttachments)
    end
    player:SelectWeapon(WeaponSlot.WeaponSlot_6, Weapons[5], noAttachments)
    player:SelectWeapon(WeaponSlot.WeaponSlot_7, Weapons[6], noAttachments)    
    

    local TextToPlayer = Weapons[1].name:match("/U_.+"):sub(4) .. ", " .. Weapons[2].name:match("/U_.+"):sub(4) .. ", " .. Weapons[3].name:match("/U_.+"):sub(4) .. ", " .. Weapons[4].name:match("/U_.+"):sub(4)
    TextToPlayer = TextToPlayer:gsub("%_", " ")
    NetEvents:SendTo('RespawnWeaponNames', player, TextToPlayer)
end

function RandomizerServer:WeaponGeneration(primaryWeaponName)
        --Seed the randomness
        math.randomseed(SharedUtils:GetTimeMS())
        weapons = {}
        --Generate random weapon names and then getting the weapon

        local primaryWeapon = self.weaponTable[primaryWeaponName]
    
        local secondaryWeaponName = self.secondaryTable[math.random(#self.secondaryTable)]
        local secondaryWeapon = self.weaponTable[secondaryWeaponName]
    
        local thirdSlotWeaponName = self.thirdSlotTable[math.random(#self.thirdSlotTable)]
        local thirdSlotWeapon = self.weaponTable[thirdSlotWeaponName]
    
        local fourthSlotWeaponName = self.fourthSlotTable[math.random(#self.fourthSlotTable)]
        local fourthSlotWeapon = self.weaponTable[fourthSlotWeaponName]

        local grenadeWeapon = self.weaponTable[self.grenadeTable[1]]
    
        local knifeWeapon = self.weaponTable[self.knivesTable[math.random(#self.knivesTable)]]

        weapons = {primaryWeapon,secondaryWeapon,thirdSlotWeapon,fourthSlotWeapon,grenadeWeapon,knifeWeapon}
        -- Returns a table weapons, 1 is Primary, 2 is Secondary, 3 is Third Slot, 4 is 4th Slot, 5 is Knife
        return weapons
end

function RandomizerServer:RandomizerAttachments(primaryWeaponName)
    local possibleSights = {}
    local possibleBarrels = {}
    local possibleAmmos = {}
    local possibleRails = {}

    --Generating a table of possible attachments per attachment slot

    for i=1, #self.sightTable do
        if self.unlockTables[primaryWeaponName][self.sightTable[i]] ~= nil then
            table.insert(possibleSights, self.unlockTables[primaryWeaponName][self.sightTable[i]])
        end
    end

    for i=1, #self.barrelAttachmentsTable do
        if self.unlockTables[primaryWeaponName][self.barrelAttachmentsTable[i]] ~= nil then
            table.insert(possibleBarrels, self.unlockTables[primaryWeaponName][self.barrelAttachmentsTable[i]])
        end
    end

    for i=1, #self.railAttachmentsTable do
        if self.unlockTables[primaryWeaponName][self.railAttachmentsTable[i]] ~= nil then
            table.insert(possibleRails, self.unlockTables[primaryWeaponName][self.railAttachmentsTable[i]])
        end
    end

    for i=1, #self.shotgunRoundsTable do
        if self.unlockTables[primaryWeaponName][self.shotgunRoundsTable[i]] ~= nil then
            table.insert(possibleAmmos, self.unlockTables[primaryWeaponName][self.shotgunRoundsTable[i]])
        end
    end

    --Slapping all the attachments into 1 table
    local attachments = {possibleSights[math.random(#possibleSights)],possibleBarrels[math.random(#possibleBarrels)],possibleAmmos[math.random(#possibleAmmos)],possibleRails[math.random(#possibleRails)]}
    return attachments
end


function RandomizerServer:KitPickup(player, newCustomization)
    -- print(newCustomization)
    print(player.weapons)
end

g_RandomizerServer = RandomizerServer()