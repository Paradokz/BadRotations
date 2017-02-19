br.loader = {}
function br.loader:new(spec,specName)
    br.loader.rotations = {}
    for k, v in pairs(br.rotations) do
        if spec == k then
            for i = 1, #v do
                tinsert(br.loader.rotations, v[i])
            end
        end
    end
    local self = cCharacter:new(tostring(select(1,UnitClass("player"))))
    local player = "player" -- if someone forgets ""

    self.profile = specName

    -- Mandatory !
    self.rotations = br.loader.rotations

    -- Spells From Spell Table
    self.spell = mergeIdTables(self.spell)

    -- Add Artifact Ability
    for k,v in pairs(self.spell.artifacts) do
        if not IsPassiveSpell(v) then
            self.spell['abilities'][k] = v
            self.spell[k] = v
            break
        end
    end

    -- Update Talent Info
    local function getTalentInfo()
        br.activeSpecGroup = GetActiveSpecGroup()
        if self.talent == nil then self.talent = {} end
        for r = 1, 7 do --search each talent row
            for c = 1, 3 do -- search each talent column
            -- Cache Talent IDs for talent checks
                local _,_,_,selected,_,talentID = GetTalentInfo(r,c,br.activeSpecGroup)
                -- Compare Row/Column Spell Id to Talent Id List for matches
                for k,v in pairs(self.spell.talents) do
                    if v == talentID then
                        -- Add All Matches to Talent List for Boolean Checks
                        self.talent[k] = selected
                        -- Add All Active Ability Matches to Ability/Spell List for Use Checks
                        if not IsPassiveSpell(v) then
                            self.spell['abilities'][k] = v
                            self.spell[k] = v
                        end
                    end
                end
            end
        end
    end

    -- Update Talent Info on Init and Talent Change
    getTalentInfo()
    AddEventCallback("PLAYER_TALENT_UPDATE",function()
        getTalentInfo()
    end)

    -- Build Buff Info
    for k,v in pairs(self.spell.buffs) do
        if k ~= "rollTheBones" then
            if self.buff[k] == nil then self.buff[k] = {} end
            local buff = self.buff[k]
            buff.exists = function(thisUnit,sourceUnit)
                if thisUnit == nil then thisUnit = 'player' end
                if sourceUnit == nil then sourceUnit = 'player' end
                return UnitBuffID(thisUnit,v,sourceUnit) ~= nil
            end
            buff.duration = function(thisUnit,sourceUnit)
                if thisUnit == nil then thisUnit = 'player' end
                if sourceUnit == nil then sourceUnit = 'player' end
                return getBuffDuration(thisUnit,v,sourceUnit)
            end
            buff.remain = function(thisUnit,sourceUnit)
                if thisUnit == nil then thisUnit = 'player' end
                if sourceUnit == nil then sourceUnit = 'player' end
                return math.abs(getBuffRemain(thisUnit,v,sourceUnit))
            end
            buff.stack = function(thisUnit,sourceUnit)
                if thisUnit == nil then thisUnit = 'player' end
                if sourceUnit == nil then sourceUnit = 'player' end
                return getBuffStacks(thisUnit,v,sourceUnit)
            end
            buff.refresh = function(thisUnit,sourceUnit)
                return buff.remain(thisUnit,sourceUnit) <= buff.duration(thisUnit,sourceUnit) * 0.3
            end
            buff.count = function()
                return tonumber(getBuffCount(v))
            end
        end
    end
    -- Build Debuff Info
    function self.getSnapshotValue(dot)
        -- Feral Bleeds
        if GetSpecializationInfo(GetSpecialization()) == 103 then
            local multiplier        = 1.00
            local Bloodtalons       = 1.30
            local SavageRoar        = 1.40
            local TigersFury        = 1.15
            local RakeMultiplier    = 1
            -- Bloodtalons
            if self.buff.bloodtalons.exists() then multiplier = multiplier*Bloodtalons end
            -- Savage Roar
            if self.buff.savageRoar.exists() then multiplier = multiplier*SavageRoar end
            -- Tigers Fury
            if self.buff.tigersFury.exists() then multiplier = multiplier*TigersFury end
            -- rip
            if dot == self.spell.debuffs.rip then
                -- -- Versatility
                -- multiplier = multiplier*(1+Versatility*0.1)
                -- return rip
                return 5*multiplier
            end
            -- rake
            if dot == self.spell.debuffs.rake then
                -- Incarnation/Prowl
                if self.buff.incarnationKingOfTheJungle.exists() or self.buff.prowl.exists() then
                    RakeMultiplier = 2
                end
                -- return rake
                return multiplier*RakeMultiplier
            end
            return 0
        end
    end

    for k,v in pairs(self.spell.debuffs) do
        if self.debuff[k] == nil then self.debuff[k] = {} end
        local debuff = self.debuff[k]
        debuff.exists = function(thisUnit,sourceUnit)
            if thisUnit == nil then thisUnit = 'target' end
            if sourceUnit == nil then sourceUnit = 'player' end
            return UnitDebuffID(thisUnit,v,sourceUnit) ~= nil
        end
        debuff.duration = function(thisUnit,sourceUnit)
            if thisUnit == nil then thisUnit = 'target' end
            if sourceUnit == nil then sourceUnit = 'player' end
            return getDebuffDuration(thisUnit,v,sourceUnit)
        end
        debuff.remain = function(thisUnit,sourceUnit)
            if thisUnit == nil then thisUnit = 'target' end
            if sourceUnit == nil then sourceUnit = 'player' end
            return math.abs(getDebuffRemain(thisUnit,v,sourceUnit))
        end
        debuff.stack = function(thisUnit,sourceUnit)
            if thisUnit == nil then thisUnit = 'target' end
            if sourceUnit == nil then sourceUnit = 'player' end
            return getDebuffStacks(thisUnit,v,sourceUnit)
        end
        debuff.refresh = function(thisUnit,sourceUnit)
            if thisUnit == nil then thisUnit = 'target' end
            if sourceUnit == nil then sourceUnit = 'player' end
            return debuff.remain(thisUnit,sourceUnit) <= debuff.duration(thisUnit,sourceUnit) * 0.3
        end
        debuff.calc = function()
            return self.getSnapshotValue(v)
        end
        debuff.count = function()
            return tonumber(getDebuffCount(v))
        end
        debuff.applied = function(thisUnit)
            return debuff.bleed[thisUnit] or 0
        end
    end

    self.units = function(range,aoe)
        if aoe == nil then aoe = false end
        if aoe then
            return dynamicTarget(range, false)
        else
            return dynamicTarget(range, true)
        end
    end

    self.enemies = function(range,unit)
        if unit == nil then unit = "player" end
        return getEnemies(unit,range)
    end

-- Build Best Unit and Enemies List per Range
    -- local typicalRanges = {
    --     50,
    --     45,
    --     40, -- Typical Ranged Limit
    --     35,
    --     30,
    --     25,
    --     23,
    --     22.75,
    --     20,
    --     18,
    --     15,
    --     13, -- Feral Interrupt
    --     12,
    --     10, -- Other Typical AoE Effect
    --     9, -- Monk Artifact
    --     8, -- Typical AoE Effect
    --     5, -- Typical Melee
    -- }
    -- for x = 1, #typicalRanges do
    --     local i = typicalRanges[x]

    --     self.units["dyn"..i] = function(aoe)
    --         if aoe == nil then aoe = false end
    --         if aoe then
    --             return dynamicTarget(i, false)
    --         else
    --             return dynamicTarget(i, true)
    --         end
    --     end

    --     self.enemies["yards"..i] = function(unit)
    --         if unit == nil then unit = "player" end
    --         return getEnemies(unit,i)
    --     end
    -- end

    -- Cycle through Abilities List
    for k,v in pairs(self.spell.abilities) do
        if self.cast            == nil then self.cast               = {} end        -- Cast Spell Functions
        if self.cast.debug      == nil then self.cast.debug         = {} end        -- Cast Spell Debugging
        -- if self.charges.frac    == nil then self.charges.frac       = {} end        -- Charges Fractional
        -- if self.charges.max     == nil then self.charges.max        = {} end        -- Charges Maximum
        --
        -- -- Build Spell Charges
        -- self.charges[k]     = getCharges(v)
        -- self.charges.frac[k]= getChargesFrac(v)
        -- self.charges.max[k] = getChargesFrac(v,true)
        -- self.recharge[k]    = getRecharge(v)
        --
        -- -- Build Spell Cooldown
        -- self.cd[k] = getSpellCD(v)

        -- Build Cast Funcitons
        self.cast[k] = function(thisUnit,debug,minUnits,effectRng)
            local spellCast = v
            local spellName = GetSpellInfo(v)
            local minRange = select(5,GetSpellInfo(spellName))
            local maxRange = select(6,GetSpellInfo(spellName))
            --if spellName == nil then print(v) end
            if IsHelpfulSpell(spellName) and thisUnit == nil then
                if thisUnit == nil or (not UnitIsFriend(thisUnit,"player") and thisUnit ~= "best") then
                    thisUnit = "player"
                end
                amIinRange = true
            elseif thisUnit == nil then
                if IsUsableSpell(v) and isKnown(v) then
                    if maxRange ~= nil and maxRange > 0 then
                        -- if maxRange > 50 then maxRange = 50 end
                        thisUnit = self.units(maxRange) --self.units["dyn"..tostring(maxRange)]()
                        amIinRange = getDistance(thisUnit) < maxRange
                    else
                        thisUnit = self.units(5) --self.units.dyn5()
                        amIinRange = getDistance(thisUnit) < 5
                    end
                end
            elseif thisUnit == "best" then
                amIinRange = true
            elseif IsSpellInRange(spellName,thisUnit) == nil then
                amIinRange = true
            else
                amIinRange = IsSpellInRange(spellName,thisUnit) == 1
            end
            if minUnits == nil then minUnits = 1 end
            if effectRng == nil then effectRng = 8 end
            if --[[isChecked("Use: "..spellName) and ]]not select(2,IsUsableSpell(v)) and getSpellCD(v) == 0 and isKnown(v) and amIinRange then
                if debug == "debug" then
                    return castSpell(thisUnit,spellCast,false,false,false,false,false,false,false,true)
                else
                    if thisUnit == "best" then
                        return castGroundAtBestLocation(spellCast,effectRng,minUnits,maxRange,minRange,debug)
                    elseif debug == "ground" then
                        if getLineOfSight(thisUnit) then
                           return castGround(thisUnit,spellCast,maxRange,minRange)
                        end
                    elseif debug == "dead" then
                        if thisUnit == nil then thisUnit = "player" end
                        return castSpell(thisUnit,spellCast,false,false,false,true,true,true,true,false)
                    elseif debug == "aoe" then
                        if thisUnit == nil then thisUnit = "player" end
                        return castSpell(thisUnit,spellCast,true,false,false,true,false,true,true,false)
                    else
                        if thisUnit == nil then thisUnit = "player" end
                        return castSpell(thisUnit,spellCast,false,false,false,true,false,true,true,false)
                    end
                end
            elseif debug == "debug" then
                return false
            end
        end
    end

------------------
--- OOC UPDATE ---
------------------

    function self.updateOOC()
        -- Call baseUpdateOOC()
        self.baseUpdateOOC()
    end

--------------
--- UPDATE ---
--------------

    function self.update()
        -- Call baseUpdate()
        self.baseUpdate()
        -- local startTime = debugprofilestop()
        self.cBuilder()
        -- br.debug.cpu.cBuilder.totalIterations = br.debug.cpu.cBuilder.totalIterations + 1
        -- br.debug.cpu.cBuilder.currentTime = debugprofilestop()-startTime
        -- br.debug.cpu.cBuilder.elapsedTime = br.debug.cpu.cBuilder.elapsedTime + debugprofilestop()-startTime
        -- br.debug.cpu.cBuilder.averageTime = br.debug.cpu.cBuilder.elapsedTime / br.debug.cpu.cBuilder.totalIterations
        self.getPetInfo()
        self.getToggleModes()
        -- Start selected rotation
        self:startRotation()
    end

---------------
--- BUILDER ---
---------------
    function self.cBuilder()

        -- local timeStart = debugprofilestop()
        -- Update Power
        powerList     = {
            mana            = 0,
            rage            = 1,
            focus           = 2,
            energy          = 3,
            comboPoints     = 4,
            runes           = 5,
            runicPower      = 6,
            soulShards      = 7,
            lunarPower      = 8,
            holyPower       = 9,
            altPower        = 10,
            maelstrom       = 11,
            chi             = 12,
            insanity        = 13,
            obsolete        = 14,
            obsolete2       = 15,
            arcaneCharges   = 16,
            fury            = 17,
            pain            = 18,
        }
        local function runeCDPercent(runeIndex)
            if GetRuneCount(runeIndex) == 0 then
                return (GetTime() - select(1,GetRuneCooldown(runeIndex))) / select(2,GetRuneCooldown(runeIndex))
            else
                return 0
            end
        end
        if self.power == nil then self.power = {} end
        -- for i = 0, #powerList do
        for k, v in pairs(powerList) do
            if UnitPower("player",v) ~= nil then
                if self.power[k] == nil then self.power[k] = {} end
                if self.power.amount == nil then self.power.amount = {} end
                local powerV = UnitPower("player",v)
                local powerMaxV = UnitPowerMax("player",v)
                self.power[k].amount    = powerV
                self.power[k].max       = powerMaxV
                self.power[k].deficit   = powerMaxV - powerV
                self.power[k].percent   = ( powerV / powerMaxV) * 100
                self.power.amount[k]    = powerV
                -- DKs are special snowflakes
                if select(2,UnitClass("player")) == "DEATHKNIGHT" and v == 5 then
                    local runeCount = 0
                    for i = 1, 6 do
                        runeCount = runeCount + GetRuneCount(i)
                    end
                    self.power.amount[k]    = runeCount
                    self.power[k].frac      = runeCount + math.max(runeCDPercent(1),runeCDPercent(2),runeCDPercent(3),runeCDPercent(4),runeCDPercent(5),runeCDPercent(6))
                end
            end
        end
        self.power.regen     = getRegen("player")
        self.power.ttm       = getTimeToMax("player")

        -- -- Build Best Unit and Enemies List per Range
        -- local typicalRanges = {
        --     40, -- Typical Ranged Limit
        --     35,
        --     30,
        --     25,
        --     20,
        --     15,
        --     13, -- Feral Interrupt
        --     12,
        --     10, -- Other Typical AoE Effect
        --     9, -- Monk Artifact
        --     8, -- Typical AoE Effect
        --     5, -- Typical Melee
        -- }
        -- for x = 1, #typicalRanges do
        --     local i = typicalRanges[x]
        --     -- Assign Best Target In Front for Set Yards
        --     self.units["dyn"..tostring(i)] = dynamicTarget(i, true)
        --     -- Assign Best Target In AoE for Set Yards
        --     self.units["dyn"..tostring(i).."AoE"] = dynamicTarget(i, false)
        --     -- Prep Enemies Per Yards tables
        --     if self.enemies["yards"..tostring(i)] == nil then self.enemies["yards"..tostring(i)] = {} else table.wipe(self.enemies["yards"..tostring(i)]) end
        --     if i <= 10 then
        --         if self.enemies["yards"..tostring(i).."t"] == nil then self.enemies["yards"..tostring(i).."t"] = {} else table.wipe(self.enemies["yards"..tostring(i).."t"]) end
        --     end
        -- end
        -- for k, v in pairs(br.enemy) do
        --     -- -- Store enemies in Debuff Applied for adding applied bleed values to
        --     -- if self.debuff.applied == nil then self.debuff.applied = {} end
        --     -- if self.debuff.applied[k] == nil then self.debuff.applied[k] = 0 end
        --     -- Find ranges enemy is present in and add to tables
        --     local thisUnit = br.enemy[k].unit
        --     local thisDistance = getDistance(thisUnit)
        --     for x = 1, #typicalRanges do
        --         local i = typicalRanges[x]
        --         -- Assign enemies to tables for specific yard
        --         if thisDistance < i then
        --             table.insert(self.enemies["yards"..tostring(i)],thisUnit)
        --         end
        --         local thisDistanceT = getDistance(self.units["dyn"..tostring(i)],thisUnit)
        --         if thisDistanceT < i and i <= 10 then
        --             table.insert(self.enemies["yards"..tostring(i).."t"],thisUnit)
        --         end
        --     end
        -- end

        if not UnitAffectingCombat("player") then
            -- Build Artifact Info
            for k,v in pairs(self.spell.artifacts) do
                self.artifact[k] = hasPerk(v) or false
                self.artifact.rank[k] = getPerkRank(v) or 0
            end
        end

        for k, v in pairs(self.debuff) do
            if k == "rake" or k == "rip" then
                if self.debuff[k].bleed == nil then self.debuff[k].bleed = {} end
                for l, w in pairs(self.debuff[k].bleed) do
                    if not UnitAffectingCombat("player") or UnitIsDeadOrGhost(l) then
                        self.debuff[k].bleed[l] = nil
                    elseif not self.debuff[k].exists(l) then
                        self.debuff[k].bleed[l] = 0
                    end
                end
            end
        end

        -- Cycle through Abilities List
        for k,v in pairs(self.spell.abilities) do
            if self.cast            == nil then self.cast               = {} end        -- Cast Spell Functions
            if self.cast.debug      == nil then self.cast.debug         = {} end        -- Cast Spell Debugging
            if self.charges.frac    == nil then self.charges.frac       = {} end        -- Charges Fractional
            if self.charges.max     == nil then self.charges.max        = {} end        -- Charges Maximum

            -- Build Spell Charges
            self.charges[k]     = getCharges(v)
            self.charges.frac[k]= getChargesFrac(v)
            self.charges.max[k] = getChargesFrac(v,true)
            self.recharge[k]    = getRecharge(v)

            -- Build Spell Cooldown
            self.cd[k] = getSpellCD(v)

            -- Build Cast Debug
            self.cast.debug[k] = self.cast[k](nil,"debug")
        end
    end

----------------
--- PET INFO ---
----------------
    function self.getPetInfo()
        if select(2,UnitClass("player")) == "HUNTER" or select(2,UnitClass("player")) == "WARLOCK" then
            if self.petInfo == nil then self.petInfo = {} end
            self.petInfo = table.wipe(self.petInfo)
            for i = 1, ObjectCount() do
                -- define our unit
                local thisUnit = GetObjectWithIndex(i)
                -- check if it a unit first
                if ObjectIsType(thisUnit, ObjectTypes.Unit)  then
                    local unitName      = UnitName(thisUnit)
                    local unitID        = GetObjectID(thisUnit)
                    local unitGUID      = UnitGUID(thisUnit)
                    local unitCreator   = UnitCreator(thisUnit)
                    local player        = GetObjectWithGUID(UnitGUID("player"))
                    if unitCreator == player
                        and (unitID == 55659 -- Wild Imp
                            or unitID == 98035 -- Dreadstalker
                            or unitID == 103673 -- Darkglare
                            or unitID == 78158 or unitID == 11859 -- Doomguard
                            or unitID == 78217 or unitID == 89 -- Infernal
                            or unitID == 416 -- Imp
                            or unitID == 1860 -- Voidwalker
                            or unitID == 417 -- Felhunter
                            or unitID == 1863 -- Succubus
                            or unitID == 17252) -- Felguard
                    then
                        if self.spell.buffs.demonicEmpowerment ~= nil then
                            demoEmpBuff   = UnitBuffID(thisUnit,self.spell.buffs.demonicEmpowerment) ~= nil
                        else
                            demoEmpBuff   = false
                        end
                        local unitCount     = #getEnemies(tostring(thisUnit),10) or 0
                        tinsert(self.petInfo,{name = unitName, guid = unitGUID, id = unitID, creator = unitCreator, deBuff = demoEmpBuff, numEnemies = unitCount})
                    end
                end
            end
        end
    end

---------------
--- TOGGLES ---
---------------

    function self.getToggleModes()

        self.mode.rotation      = br.data.settings[br.selectedSpec].toggles["Rotation"]
        self.mode.cooldown      = br.data.settings[br.selectedSpec].toggles["Cooldown"]
        self.mode.defensive     = br.data.settings[br.selectedSpec].toggles["Defensive"]
        self.mode.interrupt     = br.data.settings[br.selectedSpec].toggles["Interrupt"]
    end

    -- Create the toggle defined within rotation files
    function self.createToggles()
        GarbageButtons()
        if self.rotations[br.selectedProfile] ~= nil then
            self.rotations[br.selectedProfile].toggles()
        else
            return
        end
    end

---------------
--- OPTIONS ---
---------------

    -- Class options
    -- Options which every Rogue should have
    -- function self.createClassOptions()
    --     -- Class Wrap
    --     local section = br.ui:createSection(br.ui.window.profile,  "Class Options", "Nothing")
    --     br.ui:checkSectionState(section)
    -- end
    -- Create Spell Index
    -- function self.createSpellIndex()
    --     section = br.ui:createSection(br.ui.window.profile,  "Spells - Uncheck to prevent bot use")
    --     for k,v in pairs(self.spell.abilities) do
    --         if v ~= 61304 and v ~= 28880 and v ~= 58984 and v ~= 107079 then
    --             br.ui:createCheckbox(section, "Use: "..tostring(GetSpellInfo(v)),"|cFFED0000 WARNING!".."|cFFFFFFFF Unchecking spell may cause rotation to not function correctly or at all.",true)
    --         end
    --     end
    -- end
     -- Creates the option/profile window
    function self.createOptions()
        -- br.ui:createProfileWindow(self.profile)
        br.ui:createProfileWindow(self.profile)

        -- Get the names of all profiles and create rotation dropdown
        local names = {}
        for i=1,#self.rotations do
            -- if spec == self.rotations[i].spec then
                tinsert(names, self.rotations[i].name)
            -- end
        end
        br.ui:createRotationDropdown(br.ui.window.profile.parent, names)

        -- Create Base and Class option table
        local optionTable = {
            {
                [1] = "Base Options",
                [2] = self.createBaseOptions,
            },
            -- {
            --     [1] = "Spell Index",
            --     [2] = self.createSpellIndex,
            -- },
        }

        -- Get profile defined options
        local profileTable = profileTable
        if self.rotations[br.selectedProfile] ~= nil then
            profileTable = self.rotations[br.selectedProfile].options()
        else
            return
        end

        -- Only add profile pages if they are found
        if profileTable then
            insertTableIntoTable(optionTable, profileTable)
        end

        -- Create pages dropdown
        br.ui:createPagesDropdown(br.ui.window.profile, optionTable)

        -- br:checkProfileWindowStatus()
        br.ui:checkWindowStatus("profile")
    end

------------------------
--- CUSTOM FUNCTIONS ---
------------------------

    function useAoE()
        local rotation = self.mode.rotation
        if (rotation == 1 and #getEnemies("player",8) >= 3) or rotation == 2 then
            return true
        else
            return false
        end
    end

    function useCDs()
        local cooldown = self.mode.cooldown
        if (cooldown == 1 and isBoss()) or cooldown == 2 then
            return true
        else
            return false
        end
    end

    function useDefensive()
        if self.mode.defensive == 1 then
            return true
        else
            return false
        end
    end

    function useInterrupts()
        if self.mode.interrupt == 1 then
            return true
        else
            return false
        end
    end

    function useMfD()
        if self.mode.mfd == 1 then
            return true
        else
            return false
        end
    end

    function useRollForTB()
        if self.mode.RerollTB == 1 then
            return true
        else
            return false
        end
    end

     function useRollForOne()
        if self.mode.RollForOne == 1  then
            return true
        else
            return false
        end
    end

-----------------------------
--- CALL CREATE FUNCTIONS ---
-----------------------------
    -- Return
    return self
end --End function
