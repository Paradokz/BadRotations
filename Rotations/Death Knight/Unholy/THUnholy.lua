local rotationName = "THUnholy" -- Change to name of profile listed in options drop down

---------------
--- Toggles ---
---------------
local function createToggles() -- Define custom toggles
-- Rotation Button
    RotationModes = {
        [1] = { mode = "Auto", value = 1 , overlay = "Automatic Rotation", tip = "Swaps between Single and Multiple based on number of #enemies.yards8 in range.", highlight = 0, icon = br.player.spell.deathAndDecay },
        [2] = { mode = "Mult", value = 2 , overlay = "Multiple Target Rotation", tip = "Multiple target rotation used.", highlight = 0, icon = br.player.spell.deathAndDecay },
        [3] = { mode = "Sing", value = 3 , overlay = "Single Target Rotation", tip = "Single target rotation used.", highlight = 0, icon = br.player.spell.furiousSlash },
        [4] = { mode = "Off", value = 4 , overlay = "DPS Rotation Disabled", tip = "Disable DPS Rotation", highlight = 0, icon = br.player.spell.enragedRegeneration}
    };
    CreateButton("Rotation",1,0)
-- Cooldown Button
    CooldownModes = {
        [1] = { mode = "Auto", value = 1 , overlay = "Cooldowns Automated", tip = "Automatic Cooldowns - Boss Detection.", highlight = 1, icon = br.player.spell.summonGargoyle },
        [2] = { mode = "On", value = 2 , overlay = "Cooldowns Enabled", tip = "Cooldowns used regardless of target.", highlight = 0, icon = br.player.spell.darkArbiter },
        [3] = { mode = "Off", value = 3 , overlay = "Cooldowns Disabled", tip = "No Cooldowns will be used.", highlight = 0, icon = br.player.spell.battleCry }
    };
    CreateButton("Cooldown",2,0)
-- Defensive Button
    DefensiveModes = {
        [1] = { mode = "On", value = 1 , overlay = "Defensive Enabled", tip = "Includes Defensive Cooldowns.", highlight = 1, icon = br.player.spell.corpseShield },
        [2] = { mode = "Off", value = 2 , overlay = "Defensive Disabled", tip = "No Defensives will be used.", highlight = 0, icon = br.player.spell.enragedRegeneration }
    };
    CreateButton("Defensive",3,0)
-- Interrupt Button
    InterruptModes = {
        [1] = { mode = "On", value = 1 , overlay = "Interrupts Enabled", tip = "Includes Basic Interrupts.", highlight = 1, icon = br.player.spell.mindFreeze },
        [2] = { mode = "Off", value = 2 , overlay = "Interrupts Disabled", tip = "No Interrupts will be used.", highlight = 0, icon = br.player.spell.pummel }
    };
    CreateButton("Interrupt",4,0)
end

-- Toogle Section
local function uncheck(Value)
    if br.data~=nil then
         print(Value)
        br.data.settings[br.selectedSpec][br.selectedProfile][Value.. "Check"] = false
    end
end

---------------
--- OPTIONS ---
---------------
local function createOptions()
    local optionTable

    local function rotationOptions()
        -----------------------
        --- GENERAL OPTIONS --- -- Define General Options
        -----------------------
        section = br.ui:createSection(br.ui.window.profile,  "General")
            -- Death Grip
            --br.ui:createCheckbox(section,"Death Grip")
            -- Debug
            br.ui:createCheckbox(section,"Debug Info")

        br.ui:checkSectionState(section)
        ------------------------
        --- COOLDOWN OPTIONS --- -- Define Cooldown Options
        ------------------------
        section = br.ui:createSection(br.ui.window.profile,  "Cooldowns")
            -- Racial
            br.ui:createCheckbox(section,"Racial")
            --Asphyxiate
            --br.ui:createCheckbox(section,"Asphyxiate")
            --Summon Gargoyle
            br.ui:createCheckbox(section,"Summon Gargoyle")

        br.ui:checkSectionState(section)
        ------------------------
        --- Pet OPTIONS --- -- 
        ------------------------
        section = br.ui:createSection(br.ui.window.profile, "Pet")
        -- Auto Summon
            br.ui:createCheckbox(section,"Auto Summon")
        --Auto Attack
            br.ui:createCheckbox(section,"Pet Attack")
         br.ui:checkSectionState(section)    
        -------------------------
        --- DEFENSIVE OPTIONS --- -- Define Defensive Options
        -------------------------
        section = br.ui:createSection(br.ui.window.profile, "Defensive")
            -- Healthstone
            br.ui:createSpinner(section, "Healthstone",  61,  0,  100,  5,  "|cffFFBB00Health Percentage to use at.")
             -- Anti-Magic Shell
            br.ui:createSpinner(section, "Anti-Magic Shell",  75,  0,  100,  5,  "|cffFFFFFFHealth Percent to Cast At")
             -- Death Strike
            br.ui:createSpinner(section, "Death Strike",  70,  0,  100,  5,  "|cffFFFFFFHealth Percent to Cast At")
            -- Icebound Fortitude
            br.ui:createSpinner(section, "Icebound Fortitude",  35,  0,  100,  5,  "|cffFFFFFFHealth Percent to Cast At")
            -- Corpse Shield
            br.ui:createSpinner(section, "Corpse Shield",  59,  0,  100,  5,  "|cffFFFFFFHealth Percent to Cast At")
            -- Raise Ally
            br.ui:createCheckbox(section,"Raise Ally")
            br.ui:createDropdownWithout(section, "Raise Ally - Target", {"|cff00FF00Target","|cffFF0000Mouseover"}, 1, "|cffFFFFFFTarget to cast on")

        br.ui:checkSectionState(section)
        -------------------------
        --- INTERRUPT OPTIONS --- -- Define Interrupt Options
        -------------------------
        section = br.ui:createSection(br.ui.window.profile, "Interrupts")
            -- Leap
            br.ui:createCheckbox(section,"Leap")
            -- Mind Freeze
            br.ui:createCheckbox(section,"Mind Freeze")
            -- Asphyxiate Kick
            br.ui:createCheckbox(section,"Asphyxiate Kick")
            -- DeathGrip
            br.ui:createCheckbox(section,"Death Grip")
            -- Interrupt Percentage
            br.ui:createSpinner(section,  "InterruptAt",  0,  0,  95,  5,  "|cffFFBB00Cast Percentage to use at.")    
        br.ui:checkSectionState(section)

        ---------------------
        --- PVP Option    ---
        ---------------------
         section = br.ui:createSection(br.ui.window.profile,  "Toggle Keys")
            -- Necrotic Strike
            br.ui:createCheckbox(section,"Necrotic Strike")
             -- Chains of Ice
            br.ui:createCheckbox(section,"Chains of Ice")
            -- AMS Counter
            br.ui:createCheckbox(section,"AMS Counter")
         br.ui:checkSectionState(section)
        ----------------------
        --- TOGGLE OPTIONS --- -- Degine Toggle Options
        ----------------------
        section = br.ui:createSection(br.ui.window.profile,  "Toggle Keys")
            -- Single/Multi Toggle
            br.ui:createDropdown(section,  "Rotation Mode", br.dropOptions.Toggle,  4)
            --Cooldown Key Toggle
            br.ui:createDropdown(section,  "Cooldown Mode", br.dropOptions.Toggle,  3)
            --Defensive Key Toggle
            br.ui:createDropdown(section,  "Defensive Mode", br.dropOptions.Toggle,  6)
            -- Interrupts Key Toggle
            br.ui:createDropdown(section,  "Interrupt Mode", br.dropOptions.Toggle,  6)
            -- Pause Toggle
            br.ui:createDropdown(section,  "Pause Mode", br.dropOptions.Toggle,  6)   
        br.ui:checkSectionState(section)
        

    end
    optionTable = {{
        [1] = "Rotation Options",
        [2] = rotationOptions,
    }}
    return optionTable
end

----------------
--- ROTATION ---
----------------
local function runRotation()
    if br.timer:useTimer("debugUnholy", 0.1) then --change "debugFury" to "debugSpec" (IE: debugFire)
        --Print("Running: "..rotationName)

---------------
--- Toggles --- -- List toggles here in order to update when pressed
---------------
        UpdateToggle("Rotation",0.25)
        UpdateToggle("Cooldown",0.25)
        UpdateToggle("Defensive",0.25)
        UpdateToggle("Interrupt",0.25)
--------------
--- Locals ---
--------------
        local lastSpell         = lastCast
        local bop               = UnitBuff("target","Blessing of Protection") ~= nil
        local cloak             = UnitBuff("target","Cloak of Shadows") ~= nil or UnitBuff("target","Anti-Magic Shell") ~= nil
        local immunDS           = UnitBuff("target","Divine Shield") ~= nil 
        local immunIB           = UnitBuff("target","Ice Block") ~= nil
        local immunAotT         = UnitBuff("target","Aspect of the Turtle") ~= nil
        local immunCyclone      = UnitBuff("target","Cyclone") ~= nil
        local immun             = immun or immunIB or immunAotT or immunDS or immunCyclone
        local attacktar         = UnitCanAttack("target", "player")
        local buff              = br.player.buff
        local cast              = br.player.cast
        local cd                = br.player.cd
        local charges           = br.player.charges
        local deadtar           = UnitIsDeadOrGhost("target") or isDummy()
        local playertar         = UnitIsPlayer("target")
        local debuff            = br.player.debuff
        local enemies           = enemies or {}
        local petMinion         = false
        local petRisen          = false
        local gcd               = br.player.gcd
        local glyph             = br.player.glyph
        local inCombat          = br.player.inCombat
        local level             = br.player.level
        local mode              = br.player.mode
        local moving            = GetUnitSpeed("player")>0
        local php               = br.player.health
        local power             = br.player.power
        local pullTimer         = br.DBM:getPulltimer()
        local racial            = br.player.getRacial()
        local runicPower        = br.player.power.amount.runicPower
        local runicPowerDeficit = br.player.power.runicPower.deficit
        local runes             = br.player.power.runes.frac
        local swimming          = IsSwimming()
        local talent            = br.player.talent
        local t19_2pc           = TierScan("T19") >= 2
        local t19_4pc           = TierScan("T19") >= 4
        local ttd               = getTTD
        local units             = units or {}

        units.dyn5 = br.player.units(5)
        units.dyn8 = br.player.units(8)
        units.dyn30 = br.player.units(30)
        enemies.yards8 = br.player.enemies(8)
        enemies.yards10 = br.player.enemies(10)
        enemies.yards10t = br.player.enemies(10,br.player.units(10,true))
        enemies.yards15 = br.player.enemies(15)
        enemies.yards30 = br.player.enemies(30)
        enemies.yards40 = br.player.enemies(40)
        
        if lastSpell == nil or not inCombat then lastSpell = 0 end
        if profileStop == nil then profileStop = false end


        if isChecked("Debug Info") then
            local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(223829)
            print(name, rank, spellID)
        end

       -- print (cd.apocalypse, cd.soulReaper, debuff.festeringWound.stack("target"))

        if not inCombat and not IsMounted() and isChecked("Auto Summon") and not UnitExists("pet") and (UnitIsDead("pet") ~= nil or UnitIsDead("pet") == false) then
            if waitForPetToAppear ~= nil and waitForPetToAppear < GetTime() - 2 and onlyOneTry ~= nil and not onlyOneTry then
                onlyOneTry = true
                if cast.raiseDead() then return end
            end

            if waitForPetToAppear == nil then
                waitForPetToAppear = GetTime()
            end
        else
            onlyOneTry = false
        end

--------------------
--- Action Lists ---
--------------------
    ---------------------------------------------------------------------------------------------------------------------------------
    -- Action List - Cooldowns
    ---------------------------------------------------------------------------------------------------------------------------------
        local function actionList_Cooldowns()
            if isChecked("Debug Info") then Print("actionList_Cooldowns") end
        --Racial
            if isChecked("Racial") and (((br.player.race == "Troll" or br.player.race == "Orc"))
                or (br.player.race == "BloodElf" and runicPowerDeficit > 20)) and getSpellCD(racial) == 0
                and (not talent.soulReaper or (not debuff.soulReaper.exists("target") or buff.soulReaper.stack("player") == 3))
                and getDistance("target") < 5
            then
                if castSpell("player",racial,false,false,false) then return end
            end
        -- Blighted Runeweapon
            if talent.blightedRuneWeapon
                and (not talent.soulReaper or (not debuff.soulReaper.exists("target") or buff.soulReaper.stack("player") == 3))
                and getDistance("target") < 5
                and not immun
                and not bop 
            then
                if cast.blightedRuneWeapon() then return end
            end
         --Summon Gargoyle
            if isChecked("Summon Gargoyle") 
                and (useCDs() or playertar)
                and (not talent.soulReaper or buff.soulReaper.stack("player") == 3 or (not debuff.soulReaper.exists("target") and cd.soulReaper > 30))
                and cd.summonGargoyle == 0 
            then
                if cast.summonGargoyle() then return end
            end
        end
    ---------------------------------------------------------------------------------------------------------------------------------    
    -- Action List - Extras
    ---------------------------------------------------------------------------------------------------------------------------------
        local function actionList_Extras()        
            if isChecked("Debug Info") then Print("actionList_Extras") end
        -- Dummy Test
            if isChecked("DPS Testing") then
                if GetObjectExists("target") then
                    if getCombatTime() >= (tonumber(getValue("DPS Testing"))*60) and isDummy() then
                        profileStop = true
                        StopAttack()
                        ClearTarget()
                        Print(tonumber(getValue("DPS Testing")) .." Minute Dummy Test Concluded - Profile Stopped")
                        return true
                    end
                end
            end
        -- Chains of Ice
            if isChecked("Chains of Ice") then
                if waitforNextIoC ~= nil and waitforNextIoC < GetTime() -1.5 then
                    if playertar 
                        and getDistance("target") > 5
                        and (not debuff.chainsOfIce.exists("target"))
                        and (not talent.soulReaper or not debuff.soulReaper.exists("target") or (buff.soulReaper.stack("player") == 3)  or  getDistance("target") > 5)
                        and getFacing("player","target")
                        and not (UnitBuff("target","Blessing of Freedom") ~= nil)
                        and not immun
                        and not cloak
                      --  and isMoving(thisUnit) 
                        and getDistance("target") <= 30
                        and inCombat
                    then
                        if cast.chainsOfIce("target") then waitforNextIoC = GetTime() return end
                    end
                end
                if waitforNextIoC == nil then
                    waitforNextIoC = GetTime()
                end
            end
        end
    ---------------------------------------------------------------------------------------------------------------------------------    
    -- Action List - Defensive
    ---------------------------------------------------------------------------------------------------------------------------------
        local function actionList_Defensive()
            if isChecked("Debug Info") then Print("actionList_Defensive") end
            if useDefensive() and not IsMounted() then
            --- AMS Counter
                if isChecked("AMS Counter") 
                    and debuff.soulReaper.exists("player") 
                then
                    if cast.antiMagicShell() then return end
                end

            --Healthstone
                if isChecked("Healthstone") 
                    and php <= getOptionValue("Healthstone")
                    and inCombat 
                    and hasItem(5512)
                then
                    if canUse(5512) then
                        useItem(5512)
                    end
                end
            -- Death Strike
                if isChecked("Death Strike") 
                    and inCombat 
                    and (buff.darkSuccor.exists() and (php < getOptionValue("Death Strike") or buff.darkSuccor.remain() < 2))
                    or  runicPower >= 45  and php < getOptionValue("Death Strike")                         
                then
                    if isChecked("Debug Info") then Print("cast DS") end
                    if cast.deathStrike() then return end
                end
                if isChecked("Debug Info") then Print("IBF") end
            -- Icebound Fortitude
                if isChecked("Icebound Fortitude") 
                    and php < getOptionValue("Icebound Fortitude") 
                    and inCombat 
                then
                    if cast.iceboundFortitude() then return end
                end
            -- Corpse Shield
                if isChecked("Corpse Shield") 
                    and php < getOptionValue("Corpse Shield") 
                    and inCombat 
                then
                    if cast.corpseShield() then return end
                end
            -- Anti-Magic Shell
                if isChecked("Anti-Magic Shell") and php <= getOptionValue("Anti-Magic Shell") then
                    if cast.antiMagicShell() then return end
                end
            -- Raise Ally
                if isChecked("Raise Ally") then
                    if getOptionValue("Raise Ally - Target")==1
                        and UnitIsPlayer("target") and UnitIsDeadOrGhost("target") and UnitIsFriend("target","player")
                    then
                        if cast.raiseAlly("target","dead") then return end
                    end
                    if getOptionValue("Raise Ally - Target")==2
                        and UnitIsPlayer("mouseover") and UnitIsDeadOrGhost("mouseover") and UnitIsFriend("mouseover","player")
                    then
                        if cast.raiseAlly("mouseover","dead") then return end
                    end
                end
            end
        end
    ---------------------------------------------------------------------------------------------------------------------------------
    -- Action List - Interrupts
    ---------------------------------------------------------------------------------------------------------------------------------
        local function actionList_Interrupts()
            if isChecked("Debug Info") then Print("actionList_Interrupts") end
            if useInterrupts() then
                if waitforNextKick ~= nil and waitforNextKick < GetTime() -2 then
                    if cd.mindFreeze == 0 or cd.deathGrip == 0 or cd.asphyxiate ==0 or cd.leap == 0 then                
                        for i=1, #enemies.yards30 do
                            thisUnit = enemies.yards30[i]
                            if inCombat 
                                and (UnitIsPlayer(thisUnit) or not playertar)
                                and isValidUnit(thisUnit) 
                                and not isDummy(thisUnit) 
                                and canInterrupt(thisUnit,getOptionValue("InterruptAt"))
                                and not immunDS
                                and not immunAotT
                            then  
                                -- Leap Dark Transormation
                                if getDistance(thisUnit) > 5
                                    and getDistance(thisUnit) < 30
                                then
                                    if talent.sludgeBelcher then
                                        waitforNextKick = GetTime()
                                        if cast.hook(thisUnit) then print("Hook Kick") return end
                                    elseif buff.darkTransformation.exists("pet")
                                    then
                                        waitforNextKick = GetTime()
                                        if cast.leap(thisUnit) then print("Leap Kick") return end
                                    end
                                end
                                -- Mind Freeze
                                if isChecked("Mind Freeze") 
                                   -- and cd.mindFreeze == 0 
                                    and getDistance(thisUnit) < 15 
                                    and getFacing("player",thisUnit) 
                                then
                                    waitforNextKick = GetTime()
                                    if cast.mindFreeze(thisUnit) then print("Mind Freeze") return end
                                end
                                --Asphyxiate
                                if isChecked("Asphyxiate Kick") 
                                    and talent.asphyxiate
                                    and getDistance(thisUnit) < 20 
                                    and getFacing("player",thisUnit) 
                                then
                                    waitforNextKick = GetTime()
                                    if cast.asphyxiate(thisUnit) then  print("Asphyxiate Kick") return end
                                end
                                -- DeathGrip
                                if isChecked("Death Grip") 
                                    and getDistance("target") < 5
                                    and getFacing("player",thisUnit) 
                                then
                                    waitforNextKick = GetTime()
                                    if cast.deathGrip(thisUnit) then print ("Grip Kick") return end
                                end
                            end
                        end --endfor
                    end --Kick auf CD                
                end --Timer
                if waitforNextKick == nil then
                    waitforNextKick = GetTime()
                end
            end -- End Use Interrupts Check
        end -- End Action List - Interrupts
    ---------------------------------------------------------------------------------------------------------------------------------
    -- Action List - Pet Management
    ---------------------------------------------------------------------------------------------------------------------------------
        local function actionList_PetManagement()
            if isChecked("Debug Info") then Print("actionList_PetManagement") end
            if not IsMounted() then
                --Corpse Shield
                if buff.corpseShield.exists() then
                    if talent.sludgeBelcher then
                        if cast.protectiveBile() then return end
                    else
                        if cast.huddle() then return end
                    end
                end
                if getHP("pet") < 40 
                    and UnitExists("pet") 
                    and not buff.corpseShield.exists() 
                then
                    print("Pet Dismiss - Low Health")
                    PetDismiss()
                end

                if isChecked("Auto Summon") and not UnitExists("pet") and (UnitIsDead("pet") ~= nil or UnitIsDead("pet") == false) then
                    if waitForPetToAppear ~= nil and waitForPetToAppear < GetTime() - 2 then
                        if cast.raiseDead() then return end
                    end

                    if waitForPetToAppear == nil then
                        waitForPetToAppear = GetTime()
                    end
                end

                -- Pet Attack / retreat
                if inCombat and isValidUnit(units.dyn30) and getDistance(units.dyn30) < 30 and isChecked("Pet Attack") then
                    if not UnitIsUnit("target","pettarget") and attacktar and not IsPetAttackActive() then
                        PetAttack()
                        PetAssistMode()
                    end
                else
                    if IsPetAttackActive() then
                        PetStopAttack()
                        PetPassiveMode()
                    end
                end
            end
        end
    ---------------------------------------------------------------------------------------------------------------------------------
    -- Action List - Soul Reaper Debuff
    ---------------------------------------------------------------------------------------------------------------------------------
        local function actionList_SoulReaperDebuff()
        --Apocalypse
            if cd.apocalypse <= 0
                and debuff.festeringWound.stack("target") >= 7
                and not immun
                and not bop
            then
                if cast.apocalypse("target") then return end
            end
        -- ScourgeStrike if Soulreaper
            if debuff.festeringWound.stack("target") >= 1
                and not immun
                and not cloak
            then
                if talent.clawingShadows then
                    if cast.clawingShadows("target") then return end
                else
                    if cast.scourgeStrike("target") then return end
                end
            end
        end
    ---------------------------------------------------------------------------------------------------------------------------------
    -- Action List - Generic
    ---------------------------------------------------------------------------------------------------------------------------------
        local function actionList_Generic()
            if isChecked("Debug Info") then Print("actionList_Generic") end
           
            if waitfornextPrint == nil then
                waitfornextPrint = GetTime()
            end
            if waitfornextVirPlague == nil then
                waitfornextVirPlague = 0
            end

            --Soul Reaper if artifact == 0 and festeringWound > 6
            if debuff.festeringWound.stack("target") >= 7
                and cd.apocalypse <= 0
                and not immun
                and not bop
                and not cloak
            then 
                if cast.soulReaper("target") then return end
            end  
            --Apocalypse
            if cd.apocalypse <= 0
                and cd.soulReaper > 10
                and debuff.festeringWound.stack("target") >= 7
                and not immun
                and not bop
            then
                if cast.apocalypse("target") then return end
            end
            -- Virulent Plague
            if waitfornextVirPlague ~= nil and waitfornextVirPlague < GetTime() - 6 then
                if (not debuff.virulentPlague.exists("target")
                    or debuff.virulentPlague.remain("target") < 1.5) 
                    and not debuff.soulReaper.exists("target")
                    and not immun
                    and not cloak
                then
                    if cast.outbreak("target") then 
                        waitfornextVirPlague = GetTime() 
                        return 
                    end
                end
                local unitWithoutVirPlague = "player"
                for i = 1, #enemies.yards30 do
                    local thisUnit = enemies.yards30[i]
                    if not debuff.virulentPlague.exists(thisUnit) 
                        and UnitAffectingCombat(thisUnit) 
                        and not cloak
                        and not immun
                    then
                        if cast.outbreak(thisUnit) then 
                            waitfornextVirPlague = GetTime() 
                            return 
                        end
                        break
                    end
                end
            end

             --Dark Transformation
            if not immun
               and not bop
               and ((hasEquiped(137075) and not (cd.apocalypse < 10)) or playertar)
               and getDistance("target") < 5
               and (not debuff.soulReaper.exists("target") or buff.soulReaper.stack("player") == 3)
            then
                if cast.darkTransformation() then return end
            end
            --Death and Decay
            if #enemies.yards10 >= 3 then
                if cast.deathAndDecay("player") then return end
            end
            -- ScourgeStrike if Scourge of Worlds / Death and Decay
            if (debuff.scourgeOfWorlds.exists("target") or buff.deathAndDecay.exists())
                and debuff.festeringWound.stack("target") > 1
                and runicPower < 90
                and (not (cd.apocalypse == 0) or getDistance("target") > 5)
                and not (cd.soulReaper < 5)
                and not immun
                and not cloak
            then
                if talent.clawingShadows then
                    if cast.clawingShadows("target") then return end
                else
                    if cast.scourgeStrike("target") then return end
                end
            end           
            -- Death Coil
            if (runicPower >= 65
                or (buff.suddenDoom.exists() and buff.suddenDoom.remain() < 8))
                and (not buff.necrosis.exists("player") or buff.suddenDoom.remain() < 2 or runicPower > 90)
                and not immun
                and not cloak
            then
                if cast.deathCoil("target") then return end
            end
            -- Festering Strike
            if ((debuff.festeringWound.stack("target") < 5)
                or (debuff.festeringWound.stack("target") < 8 and cd.apocalypse == 0))
                and not immun
                and not bop
                then
                if cast.festeringStrike("target") then return end
            end

            --Soul Reaper if not artifact== 0
            if debuff.festeringWound.stack("target") >= 3 
                and cd.soulReaper <= 0
                and not (cd.apocalypse <= 0) 
                and runes >= 3.6
                and not immun
                and not bop
                and not cloak
            then
                --print (" Soulreaper Cast Runes : ", runes)
                if cast.soulReaper("target") then return end
            end          

            --Scourge
            if debuff.festeringWound.stack("target") > 3
                and (not (cd.soulReaper < 5) or runes > 4)
                and runes > 2
                and not immun
                and not cloak
            then
                if playertar and isChecked("Necrotic Strike") then 
                    if cast.necroticStrike("target") then 
                        return 
                    elseif talent.clawingShadows then
                        if cast.clawingShadows("target") then return end
                    else
                        if cast.scourgeStrike("target") then return end
                    end
                elseif talent.clawingShadows then
                    if cast.clawingShadows("target") then return end
                else
                    if cast.scourgeStrike("target") then return end
                end
            end
            --Clawing Shadow  is out of range
            if  talent.clawingShadows 
                and getDistance("target") > 5 
                and runes > 2 
                and not cloak
                and not immun
            then
                if cast.clawingShadows("target") then return end
            end
            -- DeathCoil
            if getDistance("target") > 5 
                and not immun
                and not cloak
            then
                if cast.deathCoil("target") then return end
            end
        end
-----------------
--- Rotations ---
-----------------
        -- Pause
        if pause() or (UnitExists("target") and (UnitIsDeadOrGhost("target") or not UnitCanAttack("target", "player"))) or mode.rotation == 4 then
            if isChecked("Debug Info") then Print("Rotation Pause") end
            return true
        else
---------------------------------
--- Out Of Combat - Rotations ---
---------------------------------
            if not inCombat and ObjectExists("target") and not UnitIsDeadOrGhost("target") and UnitCanAttack("target", "player") then
                if isChecked("Debug Info") then Print("OOC") end


            end -- End Out of Combat Rotation
-----------------------------
--- In Combat - Rotations --- 
-----------------------------
            if inCombat then
                if isChecked("Debug Info") then Print("inCombat") end


                 --print (#br.player.queue)
                -----------------
                --- SoulReaper --
                -----------------
                if talent.soulReaper and debuff.soulReaper.exists("target") and buff.soulReaper.stack("player") < 3  then
                    if actionList_SoulReaperDebuff() then return end
                elseif #br.player.queue == 0 then                       
                    -----------------
                    --- Extras    ---
                    -----------------
                        if actionList_Extras() then return end
                    -----------------
                    --- Cooldowns ---
                    -----------------
                        if actionList_Cooldowns() then return end
                    -----------------
                    --- Interrupt ---
                    -----------------
                       if actionList_Interrupts() then return end
                    -----------------
                    --- Pet Logic ---
                    -----------------
                        if actionList_PetManagement() then return end
                    --------------------------
                    --- Defensive Rotation ---
                    --------------------------
                        if actionList_Defensive() then return end
                    -----------------
                    --- Generic -----
                    -----------------
                        if actionList_Generic() then return end
                    -----------------
                    --- Queue     ---
                    -----------------
                -- else
                --     for i = 1, #br.player.queue do
                --         print(br.player.queue[i].name.." CD..", getSpellCD(br.player.queue[i].name) )
                --         if getSpellCD(br.player.queue[i].name) <= 0 then
                --             if waitforQueueCastToRemove ~= nil then
                --                 if castSpell("target", br.player.queue[i].id,true, false) then 
                --                     Print("Casted |cFFFF0000"..br.player.queue[i].name)
                --                     timeSet = false
                --                 elseif timeSet == nil or not timeSet then
                --                     timeSet = true
                --                     waitforQueueCastToRemove = GetTime()
                --                 end
                --                 if timeSet and waitforQueueCastToRemove < GetTime() -2 then
                --                     Print("Removed |cFFFF0000"..br.player.queue[i].name.. "|r time over")
                --                     timeSet = false
                --                     if br.player.queue == nil then Print("Queue nil") end
                --                     if #br.player.queue == 0 then Print("Queue already 0") end
                --                     if #br.player.queue > 0 then br.player.queue = {}; Print("Queue Cleared") end
                --                 end
                --             end
                --             if waitforQueueCastToRemove == nil then
                --                 timeSet = false
                --                 waitforQueueCastToRemove = GetTime()
                --             end
                --         elseif getSpellCD(br.player.queue[i].name) > 2 then
                --             Print("Removed |cFFFF0000"..br.player.queue[i].name.. "|r cause CD")
                --             timeSet = false
                --             tremove(br.player.queue,i)
                --         end
                --     end
                end

                if isChecked("Debug Info") then uncheck("Debug Info") end
            end -- End In Combat Rotation
        end -- Pause
    end -- End Timer
end -- End runRotation 
local id = 252 -- Change to the spec id profile is for.
if br.rotations[id] == nil then br.rotations[id] = {} end
tinsert(br.rotations[id],{
    name = rotationName,
    toggles = createToggles,
    options = createOptions,
    run = runRotation,
})