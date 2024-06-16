

--	local name, _, _, stacks, duration, expirationTime = AuraUtil.FindAuraByName(value.dotname, "target", "PLAYER|HARMFUL" );

local DebuffFilter = CreateFrame("Frame")
DebuffFilter.cache = {}

local DEFAULT_DEBUFF = 3
local DEFAULT_BIGDEBUFF = 5
local DEFAULT_BUFF = 13 --This Number Needs to Equal the Number of tracked Table Buf
local BIGGEST = 1.6
local BIGGER = 1.45
local BIG = 1.45
local BOSSDEBUFF = 1.45
local BOSSBUFF = 1.45
local WARNING = 1.325
local PRIORITY = 1.225
local DEBUFF = .925

local row1BUFF_SIZE = .95
local SMALL_BUFF_SIZE = 1
local BOR_BUFF_SIZE = 1
local BOL_BUFF_SIZE = 1

local NATIVE_UNIT_FRAME_HEIGHT = 36;
local NATIVE_UNIT_FRAME_WIDTH = 72;

local strfind = string.find
local strmatch = string.match
local tblinsert = table.insert
local tblremove= table.remove
local math_floor = math.floor
local math_min = math.min
local math_max = math.max
local math_rand = math.random
local mathabs = math.abs
local bit_band = bit.band
local tblsort = table.sort
local Ctimer = C_Timer.After
local substring = string.sub

local SmokeBombAuras = {}
local DuelAura = {}

local PriorityBuff = {}
for i = 1, DEFAULT_BUFF do
	if not PriorityBuff[i] then PriorityBuff[i] = {} end
end

local anybackCount = {
	["Inner Fire"] = true
}

local playerbackCount = {
	["Prayer of Mending"] = true,
}


PriorityBuff[1] = {
	"Power Word: Shield",
	--"Arcane Intellect",
	--"Arcane Brilliance",
	--"Dalaran Brilliance",
	"Weakened Soul"
}

PriorityBuff[2]= {
	"Renew",
	--"Dampen Magic",
	--"Amplify Magic",
}

PriorityBuff[3] = {
	"Prayer of Mending",
	--"Slow Fall",
	--"Focus Magic"
}

local row1Buffs = {}
local row1BuffsCount = 1
for i = 1, 3 do
	row1Buffs[i] = {}
	for _, v in ipairs(PriorityBuff[i]) do
		row1Buffs[i][v] = row1BuffsCount
		row1BuffsCount = row1BuffsCount + 1
	end
end

--Second Row 
PriorityBuffRow2 = {
	--"Regrowth",
	--"Wild Growth",
	--"Adaptive Swarm",
}

local row2Buffs = {}
local row2BuffsCount = 1
for _, v in ipairs(PriorityBuffRow2) do
	row2Buffs[v] = row2BuffsCount
	row2BuffsCount = row2BuffsCount  + 1
end

Buffs = {
	"Power Word: Fortitude",
	"Prayer of Fortitude",
	"Fortitude",
	"Shadow Protection",
	"Prayer of Shadow Protection",
	"Mark of the Wild",
	"Battle Shout",
	"Focus Magic",
	85768,
	85767,
	"Vampiric Embrace",
	"Arcane Intellect",
	"Arcane Brilliance",
	"Dalaran Brilliance",
}

local smallBuffs = {}
local smallBuffsCount = 1
for _, v in ipairs(Buffs) do
	smallBuffs[v] = smallBuffsCount
	smallBuffsCount = smallBuffsCount  + 1
end



--------------------------------------------------------------------------------------------------------------------------------------------------
--UPPER RIGHT PRIO COUNT (Buff Overlay Right)
--------------------------------------------------------------------------------------------------------------------------------------------------
BOR = {
 	--**Resets**--

	14185, --Preparation
	11958, --Cold Snap
	23989,  --Readiness

	--**Class Stealth**--

	"Prowl", 
	"Stealth",
	GetSpellInfo(66), --Invisibility
	7870, --Succy Pet Invis

	--**Secondary’s CD’s Given**--

	53480, --Roar of Sacrifice
	--59543, --Gift of the Naaru

	--**Threat MIsdirect Given**--

	396936,	-- Tricks of the Trade
	396937,	-- Tricks of the Trade
	57933,	-- Tricks of the Trade
	"Misdirection",

	--** Secondary’ Class Ds**--

	"Tremendous Fortitude",
	"Gladiator's Emblem",
	71586,

	--**Class Perm Passive Buffs & DMG CDs**--

	47568, --Empower Rune Wep
	51271, --Pillars of Frost
	49206, --Ebon Gargoyle
	49028, --Dancing Rune Weapon
	"Blood Presence",
	"Frost Presence",
	"Unholy Presence",

	91342, --SHadow Infusion (Pet)

	"Dire Bear Form", 
	50334, --Berserk (Cat)
	--93622, --Berserk (Bear) Mangle Proc
	"Starfall",
	"Bear Form",   --Bear Form
	"Tiger's Fury",
	33831, --Trees CLEU
	"Moonkin Form", --Moonkin Form
	"Cat Form", --Cat Form
	"Travel Form", --Travel Form

	34471, --The Beast within
	19574, --Bestial Wraith
	3045, --Rapid Fire
	51755, --"Camouflage",
	--"Aspect of the Viper", 
	--"Aspect of the Dragonhawk",

	GetSpellInfo(11129), --Combustion
	12043, --Presence of Mind (talent)
	12472, --Icy Veins
	12042, --Arcane Power
	48108, --Pyro
	11426, --Ice Barrier
	GetSpellInfo(11426), --Ice Barrier
	543, --Mage Ward
	"Mana Shield",
	58833, --Mirror Image
	58834, --Mirror Image
	58831, --Mirror Image
	--31687, --Water Elemental
	"Mage Armor",
	"Frost Armor",
	"Molten Armor",

	86698, -- Guardian of Ancinet Kings (Ret)
	86669, -- Guardian of Ancinet Kings (Holy)
	85696, -- Zealotry
	31842, -- Divine Favor (Haste & Crit)
	54428, -- Divine Plea
	
	87153, --Dark Archangel
	81700, --Archangel
	14751, --Chakra
	34433,  --Disc Pet Summmon Sfiend
	"Shadowform", --Shadowform
	81209, --Red Chakra
	81206, --Blue Chakra
	81208, --Yellow Chakra
	"Inner Will", --Inner Will
	"Inner Fire", --Inner Fire

	13750, --Adrenline Rush
	51690, --Killing Spree
	13877, --Blade FLurry
	57934, --Tricksing the Target
	14177, --Cold Blood

	2645,   --Ghost Wolf
	GetSpellInfo(16166), --Elemental Mastery (talent)
	64701,  --Elemental Mastery (talent)
	51533, --Feral Spirits (Summon or Buff)
	79206, --Spirit Walkers Grace
	55277, --Stoneclaw Shield

	1122,  --Infernals
	79463, --Demon Soul Incubus Both
	79460, --Demon Soul Fel Hunter
	79464, --Demon Soul Void walker
	79459, --Demon Soul Imp
	79462, --Demon Soul Felguard
	86211, -- SoulSwap
	"Shadow Ward",
	"Soul Link",

	1719,  --Recklessness
	85730, --Deadly Calm
	12292, --Death Wish

}

local BORBuffs = {}
local BORBuffsCount = 1
for _, v in ipairs(BOR) do
	BORBuffs[v] = BORBuffsCount 
	BORBuffsCount = BORBuffsCount  + 1
end


--------------------------------------------------------------------------------------------------------------------------------------------------
--UPPER LEFT PRIO COUNT (Buff Overlay Right)
--------------------------------------------------------------------------------------------------------------------------------------------------
BOL = {

	"Food",
	"Drink",
	"Food & Drink",
	"Refreshment",
	
	--**Immunity Raid**-----------------------------------------------------------------------
	
	--**Healer CDs Given**--------------------------------------------------------------------
	98007, --Spirit Link Totem

	1022, --Blessing of Protection
	6940, ---Hand of Sacrifice (30%)
	70940, --Divine Guardian (Prot)
	31821, --Aura Mastery

	33206, --Pain Suppression
	81782, --Barrier
	47788, --Guardian Spirit
	64901, --Hym of Hope
	64844, --Divine Hymn Stacks
	64843, --Divine Hymn

	GetSpellInfo(16689), --Nature's Grasp (Has Stacks)
	"Tranquility", --Tranquility (Has Stacks)
	--98007, --Spirit Link Totem
	--325174, --Spirit Link Totem
	
	--**Class Healing CDs**---------------------------------------------------------------------

	50461, --Anti-Magic Zone
	97463, --Rallying Cry
		
	--**Class Healing & DMG CDs Given**---------------------------------------------------------
	
	"Power Infusion",
	GetSpellInfo(2825), --Bloodlust
	GetSpellInfo(32182), --Heroism
	GetSpellInfo(80353), --Timelust
	GetSpellInfo(90355), --Ancient Hysteria

	29166, --Innervate
	16191, --Mana Tide

	--** Healer CDs Given w/ Short CD**---------------------------------------------------------

	--GetSpellInfo(552), --Abolish Disease
	--GetSpellInfo(2893), --Abolish Poison

	--**CC Help**-------------------------------------------------------------------------------

	49016, --Unholy Frenzy
	1038,  -- Hand of Salvation
	6346, --Fear Ward
	
	--**Passive Buffs Given**------------------------------------------------------------------

	467, --Thorns (Friendly and Enemy spellId)
	974, --Earth Shield (Has Stacks)
	--Beacons
	--317920, --Concentration Aura
	--465, --Devotion Aura
	--32223, --Crusader Aura
}

local BOLBuffs = {}
local BOLBuffsCount = 1
for _, v in ipairs(BOL) do
	BOLBuffs[v] = BOLBuffsCount 
	BOLBuffsCount = BOLBuffsCount  + 1
end





 --------------------------------------------------------------------------------------------------------------------------------------------------
 --Debuffs
 --------------------------------------------------------------------------------------------------------------------------------------------------
local spellIds = {

--DONT SHOW
	[57723] = "Hide", --Exhaustion
	[390435] = "Hide", --Exhaustion
	[57724] = "Hide", --Sated
	[80354] = "Hide", --Mage Sated
	[6788] = "Hide", --Weakened Soul
	[69127] = "Hide", --Weakened Soul


---GENERAL DANGER---
--DEATH KNIGHT
	[49206] = "Biggest", --Ebon Gargoyle
	--[45524] = "Bigger", --Chains of Ice
	[50536] = "Warning", --Unholy Blight
	[GetSpellInfo(49194) or 49194] = "Warning", --Unholy Blight
	--[GetSpellInfo(55095) or 55095] = "Priority", -- Frost Fever, Ranged & Melle Slowed 20%

--DRUID
	[GetSpellInfo(58179) or 58179] = "Big", -- Infected Wounds

	[91565] = "Priority", -- "Faerie Fire
	[GetSpellInfo(770) or 770] = "Priority", -- "Faerie Fire
	[GetSpellInfo(16857 or 16857)] = "Priority", --"Faerie Fire (Feral)


--HUNTER
	[63672]  = "Big", -- Black Arrow
	[3674]  = "Big", -- Black Arrow
	[GetSpellInfo(63672) or 63672] = "Big", -- Black Arrow

	[82654] = "Warning", -- Widow Venom
	[GetSpellInfo(82654) or 82654]  = "Warning",  -- Widow Venom 25%



	[1130] = "Priority", -- Hunter's Mark
	[GetSpellInfo(1130) or 1130] = "Priority", -- Hunter's Mark

--MAGE
	[83853] = "Biggest", --Combustion
	[41425] = "Priority", --Hypothermia

--PALLY
	[25771] = "Priority", --Forbearance
	[85509] = "Priority", -- Denounce
	[20170] = "Priority", -- Seal of Justice (100% movement snare; druids and shamans might want this though)

--PRIEST
	[GetSpellInfo(2944) or 2944] = "Bigger", --Devouring Plague
	[GetSpellInfo(589) or 589] = "Priority", -- Shadow Word : Pain

--ROGUE
	[GetSpellInfo(13218) or 13218]  = "Warning",				
	[GetSpellInfo(88611) or 88611]  = "Big", -- Smokebomb	
	[79140] = "Biggest", --Vendetta
--SHAMAN

--WARLOCK
	[GetSpellInfo(48181) or 48181] = "Bigger", -- Haunt
	[GetSpellInfo(348) or 348] = "Warning", -- Immolate
	[GetSpellInfo(32389) or 32389] = "Warning", -- Shadow Embrace
	[GetSpellInfo(172) or 172] = "Priority", -- Corruption

--WARRIOR
	[GetSpellInfo(94009) or 94009]  = "Big", -- Rend		
	[GetSpellInfo(12294) or 12294]  = "Warning", -- Mortal Strike 25%

--TRINKETS


--------------------------------------------------------------------------------------------------------------------------------------------------
--BGs & Pets
--------------------------------------------------------------------------------------------------------------------------------------------------
}

-- data from LoseControl
local bgBiggerspellIds = { --Always Shows for Pets
	[49206] = "True", --Ebon Gargoyle
	[83853] = "True", --Combustion
	[79140] = "True", --Vendetta
	
}

-- data from LoseControl
local bgBigspellIds = { --Always Shows for Pets
	--CC--
	[49203] = "CC", --Hungering Cold (talent)
	[47481] = "CC",--Gnaw
	[91800] = "CC",--Gnaw
	[91797] = "CC", --Monstrous Blow

	[33786] = "CC", 	--Cyclone
	[5211] = "CC",	-- Bash
	[9005] = "CC",	-- Pounce
	[22570] = "CC",	-- Maim
	[2637] = "CC",	-- Hibernate (rank 1)


	[1513] = "CC",			-- Scare Beast 
	[3355] = "CC",			-- Freezing Trap 
	[19386] = "CC",			-- Wyvern Sting (talent) 
	[19503] = "CC",			-- Scatter Shot (talent)

	[90337] = "CC",				-- Bad Manner
	[24394] = "CC",			-- Intimidation (talent)
	[50519] = "CC",				-- Sonic Blast (Bat)


	[GetSpellInfo(118)] = "CC",
	[118] = "CC",				-- Polymorph (rank 1)
	[28271] = "CC",				-- Polymorph: Turtle
	[28272] = "CC",				-- Polymorph: Pig
	[61305] = "CC",				-- Polymorph: Black Cat
	[61721] = "CC",				-- Polymorph: Rabbit
	[61780] = "CC",				-- Polymorph: Turkey
	[71319] = "CC",				-- Polymorph: Turkey
	[61025] = "CC",				-- Polymorph: Serpent
	[59634] = "CC",				-- Polymorph - Penguin (Glyph)
	[82691] = "CC",				-- Ring of Frost
	[83047] = "CC",				-- Improved Polymorph (talent)
	[12355] = "CC",				-- Impact (talent)
	[31661] = "CC",				-- Dragon's Breath (talent)
	[44572] = "CC",				-- Deep Freeze (talent)

	[853] = "CC",				-- Hammer of Justice
	[2812] = "CC",				-- Holy Wrath
	[10326] = "CC",				-- Turn Evil
	[20066] = "CC",				-- Repentance (talent)

	[8122] = "CC",				-- Psychic Scream 
	[605] = "CC",					-- Mind Control
	[88625] = "CC",				-- Chastise
	[87204] = "CC",				-- Sin and Punishment
	[64044] = "CC",				-- Psychic Horror (talent)

	[2094] = "CC",				-- Blind
	[408] = "CC",				-- Kidney Shot 
	[1833] = "CC",				-- Cheap Shot
	[6770] = "CC",				-- Sap 
	[1776] = "CC",				-- Gouge


	["Hex"] = "CC",	
	[51514] = "CC",
	[58861] = "CC",	 		--Bash (Spirit Wolf)
	[39796] = "CC",	 	 		--Stoneclaw Stun (Stoneclaw Totem)
	[77505] = "CC",	 		--Earthquake
	[76780] = "CC",	 		--Bind Elemental

	[5782] = "CC",						-- Fear
	[5484] = "CC",						-- Howl of Terror
	[6789] = "CC",						-- Death Coil
	[710] = "CC",						-- Banish 
	[93986] = "CC",						-- Aura of Foreboding
	[6358] = "CC",						-- Seduction (Succubus)
	[89766] = "CC",						-- Axe Toss (Felguard)
	[30283] = "CC",						-- Shadowfury (talent)
	[54786] = "CC",						-- Demon Leap (metamorphosis talent)
	[85387] = "CC",						-- Aftermath


	[22703] = "CC",						-- Inferno Effect
	[60995] = "CC",						-- Demon Charge (metamorphosis talent)
	[30153] = "CC",					-- Intercept Stun (rank 1) (Felguard)
	[19482] = "CC",					-- War Stomp (Doomguard)
	[32752] = "CC",					-- Summoning Disorientation

	[7922] = "CC",					-- Charge (rank 1/2/3)
	[96273] = "CC",	
	[20253] = "CC",				-- Intercept
	[5246] = "CC",				-- Intimidating Shout
	[20511] = "CC",				-- Intimidating Shout
	[85388] = "CC",			-- Throwdown
	[12809] = "CC",			-- Concussion Blow (talent)
	[46968] = "CC",			-- Shockwave (talent)

	[20549] = "CC",				-- War Stomp (tauren racial)

	[47476] = "Silence",-- Strangulate
	[81261] = "Silence",-- Strangulate
	[34490] = "Silence", --Silencing Shot
	[18469] = "Silence",		-- Counterspell - Silenced (rank 1) (Improved Counterspell talent)
	[55021] = "Silence",				-- Counterspell - Silenced (rank 2) (Improved Counterspell talent)
	[31935] = "Silence",		-- Silenced - Avenger's Shield
	[15487] = "Silence",			-- Silence (talent)
	[1330] = "Silence",		--Garrote - Silence_Arena
	[18425] = "Silence",		--Kick - Silenced (talent)
	[86759] = "Silence", 		--Kick - Silenced (talent)
	[31117] = "Silence",		--Unstable Affliction
	[24259] = "Silence", 		--Spell Lock (Felhunter)
	[18498] = "Silence",		-- Silenced - Gag Order (Improved Shield Bash talent
	[25046] = "Silence",				-- Arcane Torrent (blood elf racial)
	[28730] = "Silence",				-- Arcane Torrent (blood elf racial)
	[50613] = "Silence",				-- Arcane Torrent (blood elf racial)
	[69179] = "Silence",				-- Arcane Torrent (blood elf racial)
	[80483] = "Silence",				-- Arcane Torrent (blood elf racial)

	--[212638 , "RootPhyiscal_Special"},				-- Tracker's Net (pvp honor talent) -- Also -80% hit chance melee & range physical (CC and Root category)
	[96294] = "Root", 	-- CHains of Ice Root
	[96293] = "Root",	-- CHains of Ice Root
	[91807] = "Root",   --Shambling Rush
	[339] = "Root", 	-- Entangling Roots
	[19975] = "Root",	-- Entangling Roots (Nature's Grasp spell)
	[16979] = "Root",	-- Feral Charge Effect (Feral Charge talent)
	[GetSpellInfo(16979 or 16979)] = "Root",
	[45334] = "Root",			-- Feral Charge Effect (Feral Charge talent)
	[19306] = "Root",		-- Counterattack (talent)
	[19185] = "Root",			-- Entrapment (talent)
	[64803] = "Root",			-- Entrapment (talent)
	[4167] = "Root",			-- Web (Spider)
	[54706] = "Root",			-- Venom Web Spray (Silithid)
	[50245] = "Root",		-- Pin (Crab)
	[53148] = "Root",		-- Charge (Bear and Carrion Bird)
	[25999] = "Root",			-- Boar Charge (Boar)
	[122] = "Root",				-- Frost Nova 
	[83302] = "Root",			-- Imp Cone of ColdU
	[55080] = "Root",			-- Shattered Barrier (talent)
	[83073] = "Root",			-- Shattered Barrier (talent)
	[33395] = "Root",			-- Freeze
	[87194] = "Root",			-- Paralysis
	[9484] = "Root",			-- Shackle Undead
	[64695] = "Root", 		-- Earthgrab
	[63685] = "Root",		-- Freeze (Frozen Power talent)
	[93987] = "Root",			--Aura of Foreboding
	[23694] = "Root",		-- Imp Hamstring

	[54404] = "Disarm",			-- Dust Cloud (chance to hit reduced by 100%) (Tallstrider)
	[50541] = "Disarm",			-- Snatch (Bird of Prey)
	[64058] = "Disarm",			-- Psychic Horror (talent)
	[51722] = "Disarm",			-- Dismantle
	[676] = "Disarm",		-- Disarm



}

-- data from LoseControl Warning 
local bgWarningspellIds = { --Always Shows for Pets

	[GetSpellInfo(48181) or 48181] = "True", -- Warlock: Haunt 
	[GetSpellInfo(30108) or 30108] = "True", -- UA
	[GetSpellInfo(34914) or 34914] = "True", -- VT

	[88611] = "True",  --SmokeBomb


	--[45524] = "Big", --Chains of Ice
 }


--[[local function ObjectDNE(guid) --Used for Infrnals and Ele
	local tooltipData =  C_TooltipInfo.GetHyperlink('unit:' .. guid or '')
	TooltipUtil.SurfaceArgs(tooltipData)

	for _, line in ipairs(tooltipData.lines) do
		TooltipUtil.SurfaceArgs(line)
	end
	--print(#tooltipData.lines)
	if #tooltipData.lines == 1 then -- Fel Obelisk
		return "Despawned"
	end
	for i = 1, #tooltipData.lines do 
 		local text = tooltipData.lines[i].leftText
		 if text and (type(text == "string")) then
			--print(i.." "..text)
			if strfind(text, "Level ??") or strfind(text, "Corpse") then 
				return "Despawned"
			end
		end
	end
end]]

local DNEtooltip = CreateFrame("GameTooltip", "DFDNEScanSpellDescTooltip", UIParent, "GameTooltipTemplate")

local function ObjectDNE(guid) --Used for Infrnals and Ele
	DNEtooltip:SetOwner(WorldFrame, 'ANCHOR_NONE')
	DNEtooltip:SetHyperlink("unit:"..guid or '')

	for i = 1 , DNEtooltip:NumLines() do
		local text =_G["DFDNEScanSpellDescTooltipTextLeft"..i]; 
		text = text:GetText()
		if text and (type(text == "string")) then
			--print(i.." "..text)
			if strfind(text, "Level ??") or strfind(text, "Corpse") then 
				return "Despawned"
			end
		end
	end
end

local function compare_1(a,b)
  return a[13] < b[13]
end


local function compare_2(a, b)
	if a[13] < b[13] then return true end
	if a[13] > b[13] then return false end
	return a[6] > b[6]
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CLEU Events
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--BOC CLEU Events
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DebuffFilter:BOCCLEU()
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--BOL CLEU Events
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local CLEUBOL = {}
local WarBanner = {}
local Barrier = {}
local Earthen = {}

function DebuffFilter:BOLCLEU()
	local _, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellId, _, _, _, _, spellSchool = CombatLogGetCurrentEventInfo()
	local scf, uid

	-----------------------------------------------------------------------------------------------------------------
	--Barrier Check
	-----------------------------------------------------------------------------------------------------------------
	if ((sourceGUID ~= nil) and (event == "SPELL_CAST_SUCCESS") and (spellId == 62618)) then
		scf = self.cache[sourceGUID]
		if scf then 
			uid = scf.unit
		end
		if (sourceGUID ~= nil) then
		local duration = 10 + 1
		local expiration = GetTime() + duration
			if (Barrier[sourceGUID] == nil) then
				Barrier[sourceGUID] = {}
			end
			Barrier[sourceGUID] = { ["duration"] = duration, ["expiration"] = expiration }
			Ctimer(duration + 1, function()	-- execute iKn some close next frame to accurate use of UnitAura function
			Barrier[sourceGUID] = nil
			end)
		end
	end

	-----------------------------------------------------------------------------------------------------------------
	--Earthen Check (Totems Need a Spawn Time Check)
	-----------------------------------------------------------------------------------------------------------------
	if ((event == "SPELL_SUMMON") or (event == "SPELL_CREATE")) and (spellId == 198838) then
		if sourceGUID and not (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
			scf = self.cache[sourceGUID]
			if scf then 
				uid = scf.unit
			end
			local duration = 18 --Totemic Focus Makes it 18
			local expirationTime = GetTime() + duration
			if (Earthen[sourceGUID] == nil) then  --source is friendly unit party12345 raid1...
				Earthen[sourceGUID] = {}
			end
			Earthen[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
			Ctimer(duration + .2, function()	-- execute in some close next frame to accurate use of UnitAura function
				Earthen[sourceGUID] = nil
			end)
			local spawnTime
			local unitType, _, _, _, _, _, spawnUID = strsplit("-", destGUID)
			if unitType == "Creature" or unitType == "Vehicle" then
				local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
				local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
				spawnTime = spawnEpoch + spawnEpochOffset
				--print("Earthen Totem Spawned at: "..spawnTime)
			end
			if (Earthen[spawnTime] == nil) then --source becomes the totem ><
				Earthen[spawnTime] = {}
			end
			Earthen[spawnTime] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
		end
	end

	-----------------------------------------------------------------------------------------------------------------
	--WarBanner Check (Totems Need a Spawn Time Check)
	-----------------------------------------------------------------------------------------------------------------
	if ((event == "SPELL_SUMMON") or (event == "SPELL_CREATE")) and (spellId == 236320) then
		if sourceGUID and not (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
			scf = self.cache[sourceGUID]
			if scf then 
				uid = scf.unit
			end
			local duration = 15
			local expirationTime = GetTime() + duration
			if (WarBanner[sourceGUID] == nil) then --source is friendly unit party12345 raid1...
				WarBanner[sourceGUID] = {}
			end
			WarBanner[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
			Ctimer(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
			WarBanner[sourceGUID] = nil
			end)
		end
	end
	if scf and uid then 
		self:BuffFilter(scf, uid)
	end
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--BOR CLEU Events
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local CLEUBOR = {}
local summonedAura = {
	[49206]  = 30, --Ebon Gargoyle

	[33831] = 30, --Trees

	--[31687] = 45, -- Water Ele DOESNT WORK SPELL CAST SUCCESS
	[58833] = 30, --Mirror Image
	[58834] = 30, --Mirror Image
	[58831] = 30, --Mirror Image

	[34433]  = 15, --Disc Pet Summmon Sfiend "Shadowfiend" same Id has sourceGUID

	[51533] = 45, --Feral Spirits




}



local castedAura = {
--Casted Spells
	[14185] = 2, --Preparation
	[11958] = 2, --Cold Snap
	[23989] = 2,  --Readiness
	[47568] = 3, --Empower Rune Wep

	[1122] = 45, --Warlock Infernals,  has sourceGUID (spellId and Summons are different) [spellbookid]


}

function DebuffFilter:BORCLEU()
	local _, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellId, _, _, _, _, spellSchool = CombatLogGetCurrentEventInfo()
	local scf, uid

	-----------------------------------------------------------------------------------------------------------------
	--Summoned
	-----------------------------------------------------------------------------------------------------------------
	if (event == "SPELL_SUMMON") or (event == "SPELL_CREATE") then --Summoned CDs
		--print(event.." "..spellId.." "..GetSpellInfo(spellId).." "..(destName or ""))
		if summonedAura[spellId] and sourceGUID and not (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
			scf = self.cache[sourceGUID]
			if not scf then return end 
			uid = scf.unit
			local guid = destGUID
			local duration = summonedAura[spellId]
			local namePrint, _, icon = GetSpellInfo(spellId)
			local expirationTime = GetTime() + duration

			if spellId == 58833 or spellId == 58831 or spellId == 58834 then -- Mirror Image
				icon = 135994
			end

			if spellId == 157299 or spellId == 157319 then -- Strom Elemental
				icon = 2065626
			end
			--print(sourceName.." Summoned "..namePrint.." "..substring(destGUID, -7).." for "..duration.." BOR")
			if not CLEUBOR[sourceGUID] then
				CLEUBOR[sourceGUID] = {}
			end
			tblinsert(CLEUBOR[sourceGUID], {namePrint, icon, _, _, duration, expirationTime, sourceName, _, _, spellId, _, destGUID, BORBuffs[spellId]})
			--{icon, duration, expirationTime, spellId, destGUID, BORBuffs[spellId], sourceName, namePrint})
			tblsort(CLEUBOR[sourceGUID], compare_1)
			tblsort(CLEUBOR[sourceGUID], compare_2)
			local ticker = 1
			Ctimer(duration, function()
				if CLEUBOR[sourceGUID] then
					for k, v in pairs(CLEUBOR[sourceGUID]) do
						if v[10] == spellId then
							--print(v[1].." ".."Timed Out".." "..v[1].." "..substring(v[12], -7).." left w/ "..string.format("%.2f", v[6]-GetTime()).." BOR C_Timer")
							tremove(CLEUBOR[sourceGUID], k)
							tblsort(CLEUBOR[sourceGUID], compare_1)
							tblsort(CLEUBOR[sourceGUID], compare_2)
							if #CLEUBOR[sourceGUID] ~= 0 then self:BuffFilter(scf, uid) end
							if #CLEUBOR[sourceGUID] == 0 then
								CLEUBOR[sourceGUID] = nil
								self:BuffFilter(scf, uid)
							end
						end
					end
				end
			end)
			self.ticker = C_Timer.NewTicker(.1, function()
				if CLEUBOR[sourceGUID] then
					for k, v in pairs(CLEUBOR[sourceGUID]) do
						if (v[12] and (v[10] ~= 394243 and v[10] ~= 387979 and v[10] ~= 394235)) then --Dimmensional Rift Hack to Not Deswpan
							if substring(v[12], -5) == substring(guid, -5) then --string.sub is to help witj Mirror Images bug
								if ObjectDNE(v[12]) then
								--print(v[1].." "..ObjectDNE(v[12], ticker, v[1], v[7]).." "..v[1].." "..substring(v[12], -7).." left w/ "..string.format("%.2f", v[6]-GetTime()).." BOR C_Ticker")
								tremove(CLEUBOR[sourceGUID], k)
								tblsort(CLEUBOR[sourceGUID], compare_1)
								tblsort(CLEUBOR[sourceGUID], compare_2)
								if #CLEUBOR[sourceGUID] ~= 0 then self:BuffFilter(scf, uid) end
								if #CLEUBOR[sourceGUID] == 0 then
									CLEUBOR[sourceGUID] = nil
									self:BuffFilter(scf, uid)
									end
									break
								end
							end
						end
					end
				end
				ticker = ticker + 1
			end, duration * 10 + 5)
		end
	end

	-----------------------------------------------------------------------------------------------------------------
	--Casted  CDs w/o Aura
	-----------------------------------------------------------------------------------------------------------------
	if (event == "SPELL_CAST_SUCCESS") then --Casted  CDs w/o Aura
		if castedAura[spellId] and sourceGUID and not (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
			scf = self.cache[sourceGUID]
			if not scf then return end 
			uid = scf.unit
			local duration = castedAura[spellId]
			local namePrint, _, icon = GetSpellInfo(spellId)
			local expirationTime = GetTime() + duration
			--print(sourceName.." Casted "..namePrint.." "..substring(destGUID, -7).." for "..duration.." BOR")
			if not CLEUBOR[sourceGUID] then
				CLEUBOR[sourceGUID] = {}
			end
			tblinsert(CLEUBOR[sourceGUID], {namePrint, icon, count, debuffType, duration, expirationTime, sourceName, canStealOrPurge, _, spellId, canApplyAura, destGUID, BORBuffs[spellId]})
			tblsort(CLEUBOR[sourceGUID], compare_1)
			tblsort(CLEUBOR[sourceGUID], compare_2)
			Ctimer(duration, function()
				if CLEUBOR[sourceGUID] then
					for k, v in pairs(CLEUBOR[sourceGUID]) do
						if v[10] == spellId then
							--print(v[1].." ".."Timed Out".." "..v[1].." "..substring(v[12], -7).." left w/ "..string.format("%.2f", v[6]-GetTime()).." BOR C_Timer")
							tremove(CLEUBOR[sourceGUID], k)
							tblsort(CLEUBOR[sourceGUID], compare_1)
							tblsort(CLEUBOR[sourceGUID], compare_2)
							if #CLEUBOR[sourceGUID] ~= 0 then self:BuffFilter(scf, uid) end
							if #CLEUBOR[sourceGUID] == 0 then
								CLEUBOR[sourceGUID] = nil
								self:BuffFilter(scf, uid)
							end
						end
					end
				end
			end)
		end
	end

	if scf and uid then 
		self:BuffFilter(scf, uid)
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--DF CLEU Events
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function DebuffFilter:DFCLEU()
	local _, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, _, _, _, spellId, _, _, _, _, spellSchool = CombatLogGetCurrentEventInfo()
	-----------------------------------------------------------------------------------------------------------------
	--SmokeBomb Check
	-----------------------------------------------------------------------------------------------------------------
	if ((event == "SPELL_CAST_SUCCESS") and (spellId == 76577 or spellId == 359053)) then
		if (sourceGUID ~= nil) then
		local duration = 5 + 1
		local expirationTime = GetTime() + duration
			if not SmokeBombAuras[sourceGUID] then
				SmokeBombAuras[sourceGUID] = {}
			end
			SmokeBombAuras[sourceGUID] = { ["duration"] = duration, ["expirationTime"] = expirationTime }
			Ctimer(duration + 1, function()	-- execute in some close next frame to accurate use of UnitAura function
			SmokeBombAuras[sourceGUID] = nil
			end)
		end
	end

	-----------------------------------------------------------------------------------------------------------------
	--Shaodwy Duel Enemy Check
	-----------------------------------------------------------------------------------------------------------------
	--[[if (event == "SPELL_CAST_SUCCESS") and (spellId == 207736) then
		if sourceGUID and (bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
			if (DuelAura[sourceGUID] == nil) then
				DuelAura[sourceGUID] = {}
			end
			if not DuelAura[destGUID] then
				DuelAura[destGUID] = {}
			end
			local duration = 5
			Ctimer(duration + 1, function()
			DuelAura[sourceGUID] = nil
			DuelAura[destGUID] = nil
			end)
		end
	end]]
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Debuf Scale Filters
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function isBiggestDebuff(unit, index, filter)
  local  name, _, _, _, _, _, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	if (spellIds[spellId] == "Biggest" or spellIds[name] == "Biggest") then
		return true
	else
		return false
	end
end

local function isBiggerDebuff(unit, index, filter)
  local  name, _, _, _, _, _, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	local inInstance, instanceType = IsInInstance()
	if (instanceType =="pvp" or strfind(unit,"pet")) and (bgBiggerspellIds[spellId] or bgBiggerspellIds[name]) then
		return true
	elseif (spellIds[spellId] == "Bigger" or spellIds[name] == "Bigger") and instanceType ~="pvp" then
		return true
	else
		return false
	end
end

local function isBigDebuff(unit, index, filter)
  local name, _, count, _, _, _, source, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	local inInstance, instanceType = IsInInstance()
	if (instanceType =="pvp" or strfind(unit,"pet")) and (bgBigspellIds[spellId] or bgBigspellIds[name])then
		return true
	elseif (spellIds[spellId] == "Big" or spellIds[name] == "Big")  and instanceType ~="pvp" then
		return true
	else
		return false
	end
end

local function CompactUnitFrame_UtilIsBossDebuff(unit, index, filter)
  local _, _, _, _, _, _, _, _, _, _, _, isBossDeBuff = UnitAura(unit, index, "HARMFUL");
	if isBossDeBuff then
		return true
	else
		return false
	end
end

local function CompactUnitFrame_UtilIsBossAura(unit, index, filter)
  local _, _, _, _,_, _, _, _, _, _, _, isBossDeBuff = UnitAura(unit, index, "HELPFUL");
	if isBossDeBuff then
		return true
	else
		return false
	end
end

local function isWarning(unit, index, filter)
    local name, _, count, _, _, _, source, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	local inInstance, instanceType = IsInInstance()
	if (instanceType =="pvp" or strfind(unit,"pet")) and (bgWarningspellIds[spellId] or bgWarningspellIds[name]) and spellId ~= 31117 then
		return true
	elseif (spellIds[spellId] == "Warning" or spellIds[name] == "Warning")  and instanceType ~="pvp" then
		if spellId == 58180 or spellId == 8680 or spellId == 410063 then -- Only Warning if Two Stacks of MS
			if count >= 2 then
				return true
			else
				return false
			end
		end
		return true
	else
		return false
	end
end

local function isPriority(unit, index, filter)
    local  name, _, _, _, _, _, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	local inInstance, instanceType = IsInInstance()
		if (spellIds[spellId] == "Priority" or spellIds[name] == "Priority") and instanceType ~="pvp" then
		return true
	else
		return false
	end
end

local function isMagicPriority(unit, index, filter)
    local  name, _, _, debuffType, _, _, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	local class_Name, UNIT_CLASS, class_Id = UnitClass("player")
	if (spellIds[spellId] == "Hide" or spellIds[name] == "Hide") then
		return false
	elseif UNIT_CLASS == "PRIEST" and debuffType == "Magic" then
		return true
	elseif UNIT_CLASS == "MAGE" and debuffType == "Curse" then
		return true
	elseif debuffType == "Magic" then
		return true
	else
		return false
	end
end

local function isDispelPriority(unit, index, filter)
    local  name, _, _, debuffType, _, _, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	local class_Name, UNIT_CLASS, class_Id = UnitClass("player")
	if (spellIds[spellId] == "Hide" or spellIds[name] == "Hide") then
		return false
	elseif UNIT_CLASS == "PRIEST" and debuffType == "Disease" then
		return true
	elseif UNIT_CLASS == "MAGE" and debuffType == "Magic" then
		return true
	elseif debuffType == "Curse" or debuffType == "Poison" or  debuffType == "Disease" then
		return true
	else
		return false
	end
end

local function isDebuff(unit, index, filter)
    local  name, _, _, debuffType, _, _, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
		if (spellIds[spellId] == "Hide" or spellIds[name] == "Hide") then
		return false
	else
	  	return true
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Setting the Debuff Frame
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function CooldownFrame_Set(self, start, duration, enable, forceShowDrawEdge, modRate)
	if enable and enable ~= 0 and start > 0 and duration > 0 then
		self:SetDrawEdge(forceShowDrawEdge);
		self:SetCooldown(start, duration, modRate);
	else
		CooldownFrame_Clear(self);
	end
end

local function CooldownFrame_Clear(self)
	self:Clear();
end

local function SetdebuffFrame(scf, f, debuffFrame, uid, index, filter, scale)
	if not debuffFrame then return end 

	local frameWidth, frameHeight = f:GetSize()
	local componentScale = min(frameHeight / NATIVE_UNIT_FRAME_HEIGHT, frameWidth / NATIVE_UNIT_FRAME_WIDTH);
	local overlaySize = 11 * componentScale
	local buffId = index
	local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId = UnitAura(uid, index, filter);

	if spellId == 45524 then --Chains of Ice Dk
		icon = 236925
	end

	if spellId == 85509 then --Denounce
		icon = 135950
	end

	if spellId == 115196 then --Shiv
		icon = 135428
	end
	
	if spellId == 285515 then --Frost Shock to Frost Nove
		icon = 135848
	end

	if spellId == 7922 or spellId == 96273 then --Charge Stun
		icon = 132337
	end

	if spellId == 5484 then --howl of terror
		icon = "Interface\\Icons\\ability_warlock_howlofterror"
	end


	debuffFrame.icon:SetTexture(icon);
	debuffFrame.icon:SetDesaturated(nil) --Destaurate Icon
	debuffFrame.icon:SetVertexColor(1, 1, 1);
	if filter == "HARMFUL" then 
		debuffFrame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(debuffFrame.icon, "ANCHOR_RIGHT")
			if uid then
				GameTooltip:SetUnitDebuff(uid, buffId, "HARMFUL")
			else
				GameTooltip:SetSpellByID(buffId)
			end
			GameTooltip:Show()
		end)
		debuffFrame:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	elseif filter == "HELPFUL" then 
		debuffFrame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(debuffFrame.icon, "ANCHOR_RIGHT")
			if uid then
				GameTooltip:SetUnitBuff(uid, buffId, "HELPFUL")
			else
				GameTooltip:SetSpellByID(buffId)
			end
				GameTooltip:Show()
		end)
		debuffFrame:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	----------------------------------------------------------------------------------------------------------------------------------------------
	--SmokeBomb
	----------------------------------------------------------------------------------------------------------------------------------------------
	if spellId == 88611 then -- Smoke Bomb
		if unitCaster and SmokeBombAuras[UnitGUID(unitCaster)] then
			if UnitIsEnemy("player", unitCaster) then --still returns true for an enemy currently under mindcontrol I can add your fix.
				duration = SmokeBombAuras[UnitGUID(unitCaster)].duration --Add a check, i rogue bombs in stealth there is a unitCaster but the cleu doesnt regester a time
				expirationTime = SmokeBombAuras[UnitGUID(unitCaster)].expirationTime
				debuffFrame.icon:SetDesaturated(1) --Destaurate Icon
				debuffFrame.icon:SetVertexColor(1, .25, 0); --Red Hue Set For Icon
			elseif not UnitIsEnemy("player", unitCaster) then --Add a check, i rogue bombs in stealth there is a unitCaster but the cleu doesnt regester a time
				duration = SmokeBombAuras[UnitGUID(unitCaster)].duration --Add a check, i rogue bombs in stealth there is a unitCaster but the cleu doesnt regester a time
				expirationTime = SmokeBombAuras[UnitGUID(unitCaster)].expirationTime
			end
		end
	end

	-----------------------------------------------------------------------------------------------------------------
	--Enemy Duel
	-----------------------------------------------------------------------------------------------------------------
	if spellId == 207736 then --Shodowey Duel enemy on friendly, friendly frame (red)
		if DuelAura[UnitGUID(uid)] then --enemyDuel
			debuffFrame.icon:SetDesaturated(1) --Destaurate Icon
			debuffFrame.icon:SetVertexColor(1, .25, 0); --Red Hue Set For Icon
		else
		end
	end

	if count then
		if ( count > 1 ) then
			local countText = count;
			if ( count >= 100 ) then
			 countText = BUFF_STACKS_OVERFLOW;
			end
			debuffFrame.count:Show();
			debuffFrame.count:SetText(countText);
		else
			debuffFrame.count:Hide();
		end
	end

	local enabled = expirationTime and expirationTime ~= 0;
	if enabled then
		local startTime = expirationTime - duration;
		CooldownFrame_Set(debuffFrame.cooldown, startTime, duration, true);
	else
		CooldownFrame_Clear(debuffFrame.cooldown);
	end
	local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
	debuffFrame.border:SetVertexColor(color.r, color.g, color.b);
	if strfind(uid,"pet") and not scf.vehicle then
		debuffFrame:SetSize(overlaySize*scale*1.5,overlaySize*scale*1.5);
	elseif scf.vehicle then
		debuffFrame:SetSize(overlaySize*scale*1,overlaySize*scale*1);
	else
		debuffFrame:SetSize(overlaySize*scale,overlaySize*scale);
	end
	debuffFrame:Show();
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Debuff Main Loop
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function DebuffFilter:UpdateDebuffs(scf, uid)
	local f = scf.f
	local filter = nil
	local debuffNum = 1
	local index = 1
	if ( f.optionTable.displayOnlyDispellableDebuffs ) then
		filter = "RAID"
	end
	--Biggest Debuffs
		while debuffNum <= DEFAULT_BIGDEBUFF do
			local debuffName = UnitDebuff(uid, index, filter)
			if ( debuffName ) then
				if isBiggestDebuff(uid, index, filter) then
					local debuffFrame = scf.debuffFrames[debuffNum]
					SetdebuffFrame(scf, f, debuffFrame, uid, index, "HARMFUL", BIGGEST)
					debuffNum = debuffNum + 1
				end
			else
				break
			end
			index = index + 1
		end
		index = 1
		--Bigger Debuff
		while debuffNum <= DEFAULT_BIGDEBUFF do
			local debuffName = UnitDebuff(uid, index, filter);
			if ( debuffName ) then
				if isBiggerDebuff(uid, index, filter) and not isBiggestDebuff(uid, index, filter) then
					local debuffFrame = scf.debuffFrames[debuffNum]
					SetdebuffFrame(scf, f, debuffFrame, uid, index, "HARMFUL", BIGGEST)
					debuffNum = debuffNum + 1
				end
			else
				break
			end
			index = index + 1
		end
		index = 1
		--Big Debuff
		while debuffNum <= DEFAULT_BIGDEBUFF do
			local debuffName = UnitDebuff(uid, index, filter);
			if ( debuffName ) then
				if isBigDebuff(uid, index, filter) and not isBiggestDebuff(uid, index, filter) and not isBiggerDebuff(uid, index, filter) then
					local debuffFrame = scf.debuffFrames[debuffNum]
					SetdebuffFrame(scf, f, debuffFrame, uid, index, "HARMFUL", BIG)
					debuffNum = debuffNum + 1
				end
			else
				break
			end
			index = index + 1
		end
		index = 1
		--isBossDeBuff
		while debuffNum <= DEFAULT_DEBUFF do
			local debuffName = UnitDebuff(uid, index, filter);
			if ( debuffName ) then
				if CompactUnitFrame_UtilIsBossDebuff(uid, index, filter) and not isBiggestDebuff(uid, index, filter) and not isBiggerDebuff(uid, index, filter) and not isBigDebuff(uid, index, filter) then
					local debuffFrame = scf.debuffFrames[debuffNum]
					SetdebuffFrame(scf, f, debuffFrame, uid, index, "HARMFUL", BOSSDEBUFF)
					debuffNum = debuffNum + 1
				end
			else
				break
			end
			index = index + 1
		end
		index = 1
		--isBossBuff
		while debuffNum <= DEFAULT_DEBUFF do
			local debuffName = UnitBuff(uid, index, filter);
			if ( debuffName ) then
				if CompactUnitFrame_UtilIsBossAura(uid, index, filter) and not isBiggestDebuff(uid, index, filter) and not isBiggerDebuff(uid, index, filter) and not isBigDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossDebuff(uid, index, filter) then
					local debuffFrame = scf.debuffFrames[debuffNum]
					SetdebuffFrame(scf, f, debuffFrame, uid, index, "HELPFUL", BOSSBUFF)
					debuffNum = debuffNum + 1
				end
			else
				break
			end
			index = index + 1
		end
		index = 1
		--isWarning
		while debuffNum <= DEFAULT_DEBUFF do
			local debuffName = UnitDebuff(uid, index, filter)
			if ( debuffName ) then
				if  isWarning(uid, index, filter) and not isBiggestDebuff(uid, index, filter) and not isBiggerDebuff(uid, index, filter) and not isBigDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossAura(uid, index, filter) then
					local debuffFrame = scf.debuffFrames[debuffNum]
					SetdebuffFrame(scf, f, debuffFrame, uid, index, "HARMFUL", WARNING)
					debuffNum = debuffNum + 1
				end
			else
				break
			end
			index = index + 1
		end
		index = 1
		--Prio
		while debuffNum <= DEFAULT_DEBUFF do
			local debuffName = UnitDebuff(uid, index, filter)
			if ( debuffName ) then
				if isPriority(uid, index, filter) and not isBiggestDebuff(uid, index, filter) and not isBiggerDebuff(uid, index, filter) and not isBigDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossAura(uid, index, filter) and not isWarning(uid, index, filter) then
					local debuffFrame = scf.debuffFrames[debuffNum]
					SetdebuffFrame(scf, f, debuffFrame, uid, index, "HARMFUL", PRIORITY)
					debuffNum = debuffNum + 1
				end
			else
				break
			end
			index = index + 1
		end
		index = 1
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--Magic
		while debuffNum <= DEFAULT_DEBUFF do
			local debuffName = UnitDebuff(uid, index, filter)
			if ( debuffName ) then
				if isMagicPriority(uid, index, filter) and not isBiggestDebuff(uid, index, filter) and not isBiggerDebuff(uid, index, filter) and not isBigDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossAura(uid, index, filter) and not isWarning(uid, index, filter) and not isPriority(uid, index, filter) then
					local debuffFrame = scf.debuffFrames[debuffNum]
					SetdebuffFrame(scf, f, debuffFrame, uid, index, "HARMFUL", DEBUFF)
					debuffNum = debuffNum + 1
				end
			else
				break
			end
			index = index + 1
		end
		index = 1
		--Curse & Disease
		while debuffNum <= DEFAULT_DEBUFF do
			local debuffName = UnitDebuff(uid, index, filter)
			if ( debuffName ) then
				if isDispelPriority(uid, index, filter) and not isBiggestDebuff(uid, index, filter) and not isBiggerDebuff(uid, index, filter) and not isBigDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossAura(uid, index, filter) and not isWarning(uid, index, filter) and not isPriority(uid, index, filter) and not isMagicPriority(uid, index, filter)  then
					local debuffFrame = scf.debuffFrames[debuffNum]
					SetdebuffFrame(scf, f, debuffFrame, uid, index, "HARMFUL", DEBUFF)
					debuffNum = debuffNum + 1
				end
			else
				break
			end
			index = index + 1
		end
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--[[Curse & Disease
		while debuffNum <= DEFAULT_DEBUFF do
			local debuffName = UnitDebuff(uid, index, filter)
			if ( debuffName ) then
				if isDispelPriority(uid, index, filter) and not isBiggestDebuff(uid, index, filter) and not isBiggerDebuff(uid, index, filter) and not isBigDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossAura(uid, index, filter) and not isWarning(uid, index, filter) and not isPriority(uid, index, filter) then
					local debuffFrame = scf.debuffFrames[debuffNum]
					SetdebuffFrame(scf, f, debuffFrame, uid, index, "HARMFUL", DEBUFF)
					debuffNum = debuffNum + 1
				end
			else
				break
			end
			index = index + 1
		end
		index = 1
		--Magic
		while debuffNum <= DEFAULT_DEBUFF do
			local debuffName = UnitDebuff(uid, index, filter)
			if ( debuffName ) then
				if isMagicPriority(uid, index, filter) and not isBiggestDebuff(uid, index, filter) and not isBiggerDebuff(uid, index, filter) and not isBigDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossAura(uid, index, filter) and not isWarning(uid, index, filter) and not isPriority(uid, index, filter) and not isDispelPriority(uid, index, filter) then
					local debuffFrame = scf.debuffFrames[debuffNum]
					SetdebuffFrame(scf, f, debuffFrame, uid, index, "HARMFUL", DEBUFF)
					debuffNum = debuffNum + 1
				end
			else
				break
			end
			index = index + 1
		end]]
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------
		index = 1
		while debuffNum <= DEFAULT_DEBUFF do
			local debuffName = UnitDebuff(uid, index, filter)
			if ( debuffName ) then
				if ( isDebuff(uid, index, filter) and not isBiggestDebuff(uid, index, filter) and not isBiggerDebuff(uid, index, filter) and not isBigDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossDebuff(uid, index, filter) and not CompactUnitFrame_UtilIsBossAura(uid, index, filter) and not isWarning(uid, index, filter) and not isPriority(uid, index, filter) and not isDispelPriority(uid, index, filter) and not isMagicPriority(uid, index, filter)) then
					local debuffFrame = scf.debuffFrames[debuffNum]
					SetdebuffFrame(scf, f, debuffFrame, uid, index, "HARMFUL", DEBUFF)
					debuffNum = debuffNum + 1
				end
			else
				break
			end
			index = index + 1
		end
		for i=debuffNum, DEFAULT_DEBUFF do
		local debuffFrame = scf.debuffFrames[i];
		if debuffFrame then
			debuffFrame:Hide()
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Buff Filtering & Scale
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



local function buffTooltip(buffFrame, uid, index, spellId, filter)
	buffFrame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(buffFrame.icon, "ANCHOR_RIGHT")
		if index and uid and filter ==  "HELPFUL" then
			GameTooltip:SetUnitBuff(uid, index, "HELPFUL")
		elseif index and uid and filter ==  "HARMFUL" then
			GameTooltip:SetUnitDebuff(uid, index, "HARMFUL")
		elseif spellId then
			GameTooltip:SetSpellByID(spellId)
		end
		GameTooltip:Show()
	end)
	buffFrame:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
end


local function buffCount(buffFrame, count, backCount)
	if count or backCount then
		if backCount then count = backCount end
		if ( count > 1 ) then
			local countText = count;
			if ( count >= 100 ) then
				countText = BUFF_STACKS_OVERFLOW;
			end
				buffFrame.count:Show();
				buffFrame.count:SetText(countText);
		else
			buffFrame.count:Hide();
		end
	end
end




function DebuffFilter:SetBuffIcon(scf, uid, j, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, destGUID, position, index, filter, BUFFSIZE)
	local f = scf.f
	local frameWidth, frameHeight = f:GetSize()
	local componentScale = min(frameHeight / NATIVE_UNIT_FRAME_HEIGHT, frameWidth / NATIVE_UNIT_FRAME_WIDTH);
	local overlaySize = 11 * componentScale
	local buffFrame = scf.buffFrames[j]

	if name then 

		if icon then
			buffFrame.icon:SetTexture(icon);
			buffFrame.icon:SetDesaturated(nil) --Destaurate Icon
			buffFrame.icon:SetVertexColor(1, 1, 1);
			buffFrame.icon:SetTexCoord(0.01, .99, 0.01, .99)
		end

		buffFrame.SpellId = spellId

		buffTooltip(buffFrame, uid, index, spellId, filter)

		if j == 4 or j == 5 or j == 6 or j == 7 then
			if name == GetSpellInfo(2791) then --Fort
				--ActionButton_ShowOverlayGlow(buffFrame)
			else
				ActionButton_HideOverlayGlow(buffFrame)
			end
			SetPortraitToTexture(buffFrame.icon, icon)
			buffFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93);
		end

		if j == 8 then
			scf.buffFrames[4]:ClearAllPoints() -- Buff Icons
			scf.buffFrames[4]:SetPoint("RIGHT", f, "RIGHT", -5.5, 5)
		end

		if j == 13 then
			if count == 1 or count == 2 then
				buffFrame.count:SetTextColor(.9, 0 ,0, 1)
			elseif count == 3 or count == 4 then 
				buffFrame.count:SetTextColor(1, 1 ,0, 1)
			else
				buffFrame.count:SetTextColor(1, 1 ,1, 1)
			end
		end



		buffCount(buffFrame, count, backCount)

		buffFrame:SetID(j);
		if expirationTime then
			local startTime = expirationTime - duration;
			if expirationTime - startTime > 60 then
				CooldownFrame_Clear(buffFrame.cooldown);
			else
				CooldownFrame_Set(buffFrame.cooldown, startTime, duration, true);
			end
		end
		buffFrame:SetSize(overlaySize*BUFFSIZE,overlaySize*BUFFSIZE);
		buffFrame:Show();
		
		if filter == "HARMFUL" then 
			local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
			buffFrame.debuffBorder:SetVertexColor(color.r, color.g, color.b, 1);
			buffFrame.debuffBorder:Show()
		else
			buffFrame.debuffBorder:Hide()
		end
		
	else
		local buffFrame = scf.buffFrames[j];
		if buffFrame then
			buffFrame:SetSize(overlaySize*BUFFSIZE,overlaySize*BUFFSIZE);
			buffFrame:Hide()
			--buffFrame.debuffBorder:Hide()
			if j == 8 then --BuffOverlay Right 
				scf.buffFrames[4]:ClearAllPoints() --Cleares SMall Buff Icon Positions
				scf.buffFrames[4]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5.5, -6.5)
			end
		end
	end
end

function DebuffFilter:frameBuffs(scf, uid, tbl1, tbl2, tbl3)

	----------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Used for Raid Buffs
	----------------------------------------------------------------------------------------------------------------------------------------------------------
	if tbl2 then
		if tbl2[1] then 
			local j = 4
			for i = 1, 4 do  
				if tbl2[i] then
					local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, destGUID, position, index, filter = unpack(tbl2[i])
					DebuffFilter:SetBuffIcon(scf, uid, j, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, destGUID, position, index, filter, tbl2.BUFFSIZE)
				else
					DebuffFilter:SetBuffIcon(scf, uid, j, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, destGUID, position, index, filter, tbl2.BUFFSIZE)
				end
				j = j + 1
			end
		else
			for j = 4, 7 do  
				DebuffFilter:SetBuffIcon(scf, uid, j, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, destGUID, position, index, filter, tbl2.BUFFSIZE)
			end
		end
	end

	----------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Main Row Used for Buff 123 and BOL, BOR
	----------------------------------------------------------------------------------------------------------------------------------------------------------
	if tbl1 then
		if tbl1[1] then
			local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, destGUID, position, index, filter = unpack(tbl1[1])

			-----------------------------------------------------------------------------------------------------------------------------------------------------------------
			--Icon Change
			-----------------------------------------------------------------------------------------------------------------------------------------------------------------
			if spellId == 387636 then --Soulburn: Healthstone
				icon = 538745
			end

			if spellId == 55277 then 
				icon = 136097
			end

			if spellId == 87153 then 
				icon = "Interface\\Icons\\ability_priest_darkarchangel"
			end

			-----------------------------------------------------------------------------------------------------------------
			--Barrier Check
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 81782 then
				if unitCaster then 
					local guidCaster = UnitGUID(unitCaster)
					if guidCaster and Barrier[guidCaster] then
						duration = Barrier[guidCaster].duration
						expirationTime = Barrier[guidCaster].expiration
					end
				end
			end

			-----------------------------------------------------------------------------------------------------------------
			--Earthern Check
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 201633 then -- Earthen Totem (Totems Need a Spawn Time Check)
				if unitCaster and not UnitIsEnemy("player", unitCaster) then
					local sourceGUID = UnitGUID(unitCaster)
					if Earthen[sourceGUID] then
						duration = Earthen[sourceGUID].duration
						expirationTime = Earthen[sourceGUID].expirationTime
					else
						local spawnTime
						local unitType, _, _, _, _, _, spawnUID = strsplit("-", sourceGUID)
						if unitType == "Creature" or unitType == "Vehicle" then
							local spawnEpoch = GetServerTime() - (GetServerTime() % 2^23)
							local spawnEpochOffset = bit_band(tonumber(substring(spawnUID, 5), 16), 0x7fffff)
							spawnTime = spawnEpoch + spawnEpochOffset
							--print("Earthen Buff Check at: "..spawnTime)
						end
						if Earthen[spawnTime] then
							duration = Earthen[spawnTime].duration
							expirationTime = Earthen[spawnTime].expirationTime
						end
					end
				end
			end


			if spellId == 58833 or spellId == 58831 or spellId == 58834 or spellId == 33831 then -- Trees and Mirror Image Count
				local sourceGUID = UnitGUID(uid)
				if not count then count = 0 end
				for i = 1, #CLEUBOR[sourceGUID] do
					if CLEUBOR[sourceGUID][i][10] == 58833  or CLEUBOR[sourceGUID][i][10] == 58831 or CLEUBOR[sourceGUID][i][10] == 58834 or CLEUBOR[sourceGUID][i][10] == 33831 then
						count = count + 1
					end
				end
			end

			--------------------------------------~---------------------------------------------------------------------------
			--Warbanner
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 236321 then -- Warbanner (Totems Need a Spawn Time Check)
				if unitCaster and not UnitIsEnemy("player", unitCaster) then
					if WarBanner[UnitGUID(unitCaster)] then
						duration = WarBanner[UnitGUID(unitCaster)].duration
						expirationTime = WarBanner[UnitGUID(unitCaster)].expirationTime
					end
				end
			end

			DebuffFilter:SetBuffIcon(scf, uid, tbl1.j, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, destGUID, position, index, filter, tbl1.BUFFSIZE)
		else
			DebuffFilter:SetBuffIcon(scf, uid, tbl1.j, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, destGUID, position, index, filter, tbl1.BUFFSIZE)
		end
	end

	----------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Used for row 2 Buffs j == 10  to 12 , Mainly Druid Healing 
	----------------------------------------------------------------------------------------------------------------------------------------------------------
	--[[if tbl3 then 		
		if tbl3[1] then 
			local j = 10
			for i = 1, 3 do  
				if tbl3[i] then
					local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, destGUID, position, index, filter = unpack(tbl3[i])
					DebuffFilter:SetBuffIcon(scf, uid, j, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, destGUID, position, index, filter, tbl3.BUFFSIZE)
				else
					DebuffFilter:SetBuffIcon(scf, uid, j, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, destGUID, position, index, filter, tbl3.BUFFSIZE)
				end
				j = j + 1
			end
		else
			for j = 10, 12 do  
				DebuffFilter:SetBuffIcon(scf, uid, j, name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, destGUID, position, index, filter, tbl3.BUFFSIZE)
			end
		end
	end]]
end

local function compare_tbl1(a,b)
	return a[13] < b[13]
  end
  
  
  local function compare_tbl2(a, b)
	  if a[13] < b[13] then return true end
	  if a[13] > b[13] then return false end
	  return a[6] > b[6]
  end


local function Position(tbl, name, spellId)
	local position = tbl[name] or tbl[spellId]
	return position
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Filters Buff and Debuffs to Correct Loops
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function DebuffFilter:BuffFilter(scf, uid)

	local buffTableBOL = {}; buffTableBOL.j = 9; buffTableBOL.BUFFSIZE = BOL_BUFF_SIZE
	local buffTableBOR = {}; buffTableBOR.j = 8; buffTableBOR.BUFFSIZE = BOR_BUFF_SIZE
	local buffTableBuff1 = {} buffTableBuff1.j = 1; buffTableBuff1.BUFFSIZE = row1BUFF_SIZE
	local buffTableBuff2 = {} buffTableBuff2.j = 2; buffTableBuff2.BUFFSIZE = row1BUFF_SIZE
	local buffTableBuff3 = {} buffTableBuff3.j = 3; buffTableBuff3.BUFFSIZE = row1BUFF_SIZE
	local buffTableBuffs = {}; buffTableBuffs.BUFFSIZE = SMALL_BUFF_SIZE
	local buffTableBuffs4 = {}; buffTableBuffs4.BUFFSIZE = SMALL_BUFF_SIZE
	local MagicCountPlayerTableBuffs = {};MagicCountPlayerTableBuffs.j = 13; MagicCountPlayerTableBuffs.BUFFSIZE = SMALL_BUFF_SIZE
	local MagicCountPlayer = 0 
	
	for i = 1, 40 do
		local filter = "HELPFUL"
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitBuff(uid, i)
		if not name or not spellId then break end
		if BOLBuffs[name] or BOLBuffs[spellId] then
			tblinsert(buffTableBOL, {name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, _, Position(BOLBuffs, name, spellId), i, filter})
		elseif BORBuffs[name] or BORBuffs[spellId] then
			tblinsert(buffTableBOR, {name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, _, Position(BORBuffs, name, spellId), i, filter})
		elseif (row1Buffs[1][name] or row1Buffs[1][spellId]) then -- and unitCaster == "player" then
			tblinsert(buffTableBuff1, {name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, _, Position(row1Buffs[1], name, spellId), i, filter})
		elseif (row1Buffs[2][name] or row1Buffs[2][spellId]) and unitCaster == "player" then
			tblinsert(buffTableBuff2, {name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, _, Position(row1Buffs[2], name, spellId), i, filter})
		elseif (row1Buffs[3][name] or row1Buffs[3][spellId]) and unitCaster == "player" then
			tblinsert(buffTableBuff3, {name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, _, Position(row1Buffs[3], name, spellId), i, filter})
		elseif smallBuffs[name] or smallBuffs[spellId] then
			tblinsert(buffTableBuffs, {name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, _, Position(smallBuffs, name, spellId), i, filter})
		--elseif row2Buffs[name] or row2Buffs[spellId] then
			--tblinsert(buffTableBuffs4, {name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, _, Position(row2Buffs, name, spellId), i, filter})
		end
		if debuffType == "Magic" and UnitIsUnit(uid, "player") then 
			MagicCountPlayer = MagicCountPlayer + 1
		end
		if  MagicCountPlayer > 0 then 
			MagicCountPlayerTableBuffs[1] = {"MagicCount", nil, MagicCountPlayer, nil, nil, nil, nil, nil, nil, nil, nil, nil, 1, nil, nil}
		end
	end

	for i = 1, 40 do
		local filter = "HARMFUL"
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitDebuff(uid, i)
		if not name or not spellId then break end
		if row1Buffs[1][name] or row1Buffs[1][spellId] then -- Currently Only Filtering Debuffs for Buff 1 Weakeend Soul
			tblinsert(buffTableBuff1, {name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura, _, Position(row1Buffs[1], name, spellId), i, filter})
		end
	end

	local sourceGUID = UnitGUID(uid)
	if CLEUBOR[sourceGUID] then
		for k, v in pairs(CLEUBOR[sourceGUID]) do
			tblinsert(buffTableBOR, v )
		end
	end

	tblsort(buffTableBOR, compare_tbl1)
	tblsort(buffTableBOR, compare_tbl2)
	tblsort(buffTableBOL, compare_tbl1)
	tblsort(buffTableBuff1, compare_tbl1)
	tblsort(buffTableBuff2, compare_tbl1)
	tblsort(buffTableBuff3, compare_tbl1)
	tblsort(buffTableBuffs, compare_tbl1)
	--tblsort(buffTableBuffs4, compare_tbl1)
	

	self:frameBuffs(scf, uid, buffTableBuff1)
	self:frameBuffs(scf, uid, buffTableBuff2)
	self:frameBuffs(scf, uid, buffTableBuff3)
	self:frameBuffs(scf, uid, buffTableBOR, buffTableBuffs)
	self:frameBuffs(scf, uid, buffTableBOL)
	--self:frameBuffs(scf, uid, nil, nil, buffTableBuffs4) -- Used for row 2 Buffs j == 10  to 12 , Mainly Druid Healing 
	self:frameBuffs(scf, uid, MagicCountPlayerTableBuffs)

end




local function DebuffFilter_UpdateAuras(scf, unitAuraUpdateInfo, event)
	--print(event.." "..scf.displayedUnit)
	
	local debuffsChanged = false;
	local buffsRow1 = false;
	local buffsRow2 = false;
	local buffsBOR = false;
	local buffsBOL = false;
	local buffsBOC = false;
	local magicCount = false;
	local weakenedSoul = false;
	local buffChanged = false;

	local function HandleAura(aura)
		if aura then 
			if aura.isHarmful or aura.isBossAura then
				scf.debuffs[aura.auraInstanceID] = aura;
			elseif aura.isHelpful then
				scf.buffs[aura.auraInstanceID] = aura;
			end
		end
	end

	if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or (scf.unit and scf.displayedUnit and scf.unit ~= scf.displayedUnit) or scf.debuffs == nil then
		scf.debuffs = {};scf.buffs = {}
		--AuraUtil.ForEachAura(scf.displayedUnit, "HELPFUL", nil, HandleAura, true)
		--AuraUtil.ForEachAura(scf.displayedUnit, "HARMFUL", nil, HandleAura, true)
		debuffsChanged = true;
		buffsRow1 = true;
		buffsRow2 = true;
		buffsBOR = true;
		buffsBOL = true;
		buffsBOC = true;
		magicCount = true;
		buffChanged = true;
		weakenedSoul = true;
	else
		if unitAuraUpdateInfo.addedAuras ~= nil then
			for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
				if aura and (aura.isHarmful or aura.isBossAura) then
					--scf.debuffs[aura.auraInstanceID] = aura;
					debuffsChanged = true;
					weakenedSoul = true;
				elseif aura and aura.isHelpful then
					--[[
					scf.buffs[aura.auraInstanceID] = aura;
					if (aura.sourceUnit and aura.sourceUnit == "player") and ((aura.spellId and row1Buffs[aura.spellId]) or (aura.name and row1Buffs[aura.name])) then
						buffsRow1 = true
					end
					if (aura.sourceUnit and aura.sourceUnit == "player") and ((aura.spellId and row2Buffs[aura.spellId]) or (aura.name and row2Buffs[aura.name])) then
						buffsRow2 = true
					end
					if (aura.spellId and BORBuffs[aura.spellId]) or (aura.name and BORBuffs[aura.name]) then
						buffsBOR = true
					end
					if (aura.spellId and BOLBuffs[aura.spellId]) or (aura.name and BOLBuffs[aura.name]) then
						buffsBOL = true
					end]]
					buffsRow1 = true
					buffsRow2 = true
					buffsBOR = true
					buffsBOL = true
					magicCount = true
					buffChanged = true;
				end
			end
		end

		if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
				local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(scf.displayedUnit, auraInstanceID)
				if aura and (aura.isHarmful or aura.isBossAura) then --todo: is aura shown, if not you do not need to fire
					--scf.debuffs[aura.auraInstanceID] = aura;
					debuffsChanged = true;
					weakenedSoul = true;
				elseif aura and aura.isHelpful then --todo: is aura, if not you do not need to fire
					--[[scf.buffs[aura.auraInstanceID] = aura;
					if (aura.sourceUnit and aura.sourceUnit == "player") and ((aura.spellId and row1Buffs[aura.spellId]) or (aura.name and row1Buffs[aura.name])) then
						buffsRow1 = true
					end
					if (aura.sourceUnit and aura.sourceUnit == "player") and ((aura.spellId and row2Buffs[aura.spellId]) or (aura.name and row2Buffs[aura.name])) then
						buffsRow2 = true
					end
					if (aura.spellId and BORBuffs[aura.spellId]) or (aura.name and BORBuffs[aura.name]) then
						buffsBOR = true
					end
					if (aura.spellId and BOLBuffs[aura.spellId]) or (aura.name and BOLBuffs[aura.name]) then
						buffsBOL = true
					end]]
					buffsRow1 = true
					buffsRow2 = true
					buffsBOR = true
					buffsBOL = true
					magicCount = true
					buffChanged = true;
				end
			end
		end

		if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
			debuffsChanged = true;
			weakenedSoul = true;
			buffsRow1 = true
			buffsRow2 = true
			buffsBOR = true
			buffsBOL = true
			magicCount = true
			buffChanged = true;
			--[[for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
				if scf.debuffs[auraInstanceID] ~= nil then --todo: is aura shown, if not you do not need to fire
					local aura = scf.buffs[auraInstanceID]
					scf.debuffs[auraInstanceID] = nil;
					debuffsChanged = true;
				elseif scf.buffs[auraInstanceID] ~= nil then --todo: is aura shown, if not you do not need to fire
					local aura = scf.buffs[auraInstanceID]
					scf.buffs[auraInstanceID] = nil;
					if (aura.sourceUnit and aura.sourceUnit == "player") and ((aura.spellId and row1Buffs[aura.spellId]) or (aura.name and row1Buffs[aura.name])) then
						buffsRow1 = true
					end
					if (aura.sourceUnit and aura.sourceUnit == "player") and ((aura.spellId and row2Buffs[aura.spellId]) or (aura.name and row2Buffs[aura.name])) then
						buffsRow2 = true
					end
					if (aura.spellId and BORBuffs[aura.spellId]) or (aura.name and BORBuffs[aura.name]) then
						buffsBOR = true
					end
					if (aura.spellId and BOLBuffs[aura.spellId]) or (aura.name and BOLBuffs[aura.name]) then
						buffsBOL = true
					end
				end
			end]]
		end
	end

	if debuffsChanged then
		DebuffFilter:UpdateDebuffs(scf, scf.displayedUnit)
	end

	--[[if buffsRow1 then
		DebuffFilter:buffsRow1(scf, scf.displayedUnit)
	end
	if buffsRow2 then
		DebuffFilter:buffsRow2(scf, scf.displayedUnit)
	end
	if buffsBOR then
		DebuffFilter:buffsBOR(scf, scf.displayedUnit)
	end
	if buffsBOL then
		DebuffFilter:buffsBOL(scf, scf.displayedUnit)
	end
	if buffsBOC then
	end
	if magicCount then 
		if UnitIsUnit("player", scf.displayedUnit) then
			DebuffFilter:magicCount(scf, scf.displayedUnit)
		end
	end
	if weakenedSoul then
		if UNIT_CLASS == "PRIEST" then
			DebuffFilter:weakenedSoul(scf, scf.displayedUnit, true)
		end
	end]]

	if buffChanged or weakenedSoul then 
		DebuffFilter:BuffFilter(scf, scf.displayedUnit)
	end
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Applys all Buff and Debuff Shell Icons to the Frame
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function DebuffFilter:ApplyFrame(f)
	--print(f.displayedUnit)
	local frameWidth, frameHeight = f:GetSize()

	local componentScale = min(frameHeight / NATIVE_UNIT_FRAME_HEIGHT, frameWidth / NATIVE_UNIT_FRAME_WIDTH);
	local overlaySize =  11 * componentScale

	local scf = self.cache[f]

	if not scf.buffFrames then scf.buffFrames = {} end
	if not scf.debuffFrames then scf.debuffFrames = {} end

	for j = 1, DEFAULT_DEBUFF do
		scf.debuffFrames[j] = _G["scfDebuff"..f:GetName()..j] or CreateFrame("Button" , "scfDebuff"..f:GetName()..j, UIParent, "CompactDebuffTemplate")
		local debuffFrames = scf.debuffFrames[j]
		debuffFrames:ClearAllPoints()
		debuffFrames:SetParent(f)
		if j == 1 then
			if strfind(f.unit,"pet") then
				debuffFrames:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT",3, 3)
			else
				debuffFrames:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT",3,10)
			end
		else
			debuffFrames:SetPoint("BOTTOMLEFT",scf.debuffFrames[j-1],"BOTTOMRIGHT",0,0)
		end
		debuffFrames:SetSize(overlaySize, overlaySize)  --ensures position is prelocked before showing , avoids the growing of row
		debuffFrames:Hide()
	end
	for j = 1,#f.debuffFrames do
		f.debuffFrames[j]:Hide()
		f.debuffFrames[j]:SetScript("OnShow", function(self) self:Hide() end)
	end

	for j = 1, DEFAULT_BUFF do
		if strfind(f.unit,"pet") then
			if j == 8 then --BUffOverlay Right
				scf.buffFrames[j] = _G["scfPetBORBuff"..f:GetName()..j] or CreateFrame("Button" , "scfPetBORBuff"..f:GetName()..j, UIParent, "CompactAuraTemplate")
			elseif j == 9 then --BUffOverlay Left
				scf.buffFrames[j] = _G["scfPetBOLBuff"..f:GetName()..j] or CreateFrame("Button" , "scfPetBOLBuff"..f:GetName()..j, UIParent, "CompactAuraTemplate")
			elseif j == 14 then
				scf.buffFrames[j] = _G["scfPetBuff"..f:GetName()..j] or CreateFrame("Button" , "scfPetBuff"..f:GetName()..j, UIParent, "CompactDebuffTemplate")
			else
				scf.buffFrames[j] = _G["scfPetBuff"..f:GetName()..j] or CreateFrame("Button" , "scfPetBuff"..f:GetName()..j, UIParent, "CompactAuraTemplate")
			end
		else
			if j == 8 then --BUffOverlay Right
				scf.buffFrames[j] = _G["scfBORBuff"..f:GetName()..j] or CreateFrame("Button" , "scfBORBuff"..f:GetName()..j, UIParent, "CompactAuraTemplate")
			elseif j == 9 then --BUffOverlay Left
				scf.buffFrames[j] = _G["scfBOLBuff"..f:GetName()..j] or CreateFrame("Button" , "scfBOLBuff"..f:GetName()..j, UIParent, "CompactAuraTemplate")
			elseif j == 14 then
				scf.buffFrames[j] = _G["scfBuff"..f:GetName()..j] or CreateFrame("Button" , "scfBuff"..f:GetName()..j, UIParent, "CompactDebuffTemplate")
			else
				scf.buffFrames[j] = _G["scfBuff"..f:GetName()..j] or CreateFrame("Button" , "scfBuff"..f:GetName()..j, UIParent, "CompactAuraTemplate")
			end
		end
		local buffFrame = scf.buffFrames[j]
		buffFrame.cooldown:SetDrawSwipe(true)
		buffFrame.cooldown:SetSwipeColor(0, 0, 0, 0.7)
		buffFrame.cooldown:SetReverse(true)
		buffFrame:ClearAllPoints()
		buffFrame:SetParent(f)
		if j == 1 or j == 14 then --Buff One
			if not strfind(f.unit,"pet") then
				if j == 1 then 
					buffFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2.5, 9.5)
				else
					buffFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -3.25, 10)
				end
			else
				if j == 1 then 
					buffFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2.5, 1)
				else
					buffFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -3.25, 10)
				end
			end
		elseif j == 2 then --Buff Two
			buffFrame:SetPoint("BOTTOMRIGHT", scf.buffFrames[j-1], "BOTTOMLEFT", 0, 0)
		elseif j ==3 then --Buff Three
			buffFrame:SetPoint("BOTTOMRIGHT", scf.buffFrames[j-1], "BOTTOMLEFT", 0, 0)
		elseif j == 4 or j == 5 or j == 6 or j == 7 then
			if j == 4 then
				if not strfind(f.unit,"pet") then
					buffFrame:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5.5, -6.5)
				else
					buffFrame:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5.5, -6.5)
				end
			else
				if not strfind(f.unit,"pet") then
					buffFrame:SetPoint("RIGHT", scf.buffFrames[j -1], "LEFT", 0, 0)
				else
					buffFrame:SetPoint("RIGHT", scf.buffFrames[j -1], "LEFT", 0, 0)
				end
			end
				buffFrame:SetScale(.6)
		elseif j ==8 then --Upper Right Count Only)
			if not strfind(f.unit,"pet") then
				buffFrame:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -1.5)
			else
				buffFrame:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -1.5)
			end
			buffFrame:SetScale(1.15)
		elseif j ==9 then --Upper Left Count Only
			if not strfind(f.unit,"pet") then
				buffFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -1.5)
			else
				buffFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -1.5)
			end
			buffFrame:SetScale(1.15)
		elseif j == 10 or j == 11 or j == 12 then --Second Row 123
			if j == 10 then
				if not strfind(f.unit,"pet") then
					buffFrame:SetPoint("BOTTOM", scf.buffFrames[1], "TOP", 0, 0)
				else
					buffFrame:SetPoint("BOTTOM", scf.buffFrames[1], "TOP", 0, 0)
				end
			else
				if not strfind(f.unit,"pet") then
					buffFrame:SetPoint("RIGHT", scf.buffFrames[j -1], "LEFT", 0, 0)
				else
					buffFrame:SetPoint("RIGHT", scf.buffFrames[j -1], "LEFT", 0, 0)
				end
			end
		elseif j == 13 then --Second Row 123
			if not strfind(f.unit,"pet") then
				buffFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
			else
				--buffFrame:SetPoint("RIGHT", f, "RIGHT", 0, 0)
			end
		end
		if j == 1 or j == 2 or j == 3 or j == 10 or j == 11 or j == 12 or j == 14 then 
			if strfind(f.unit,"pet") then
				buffFrame.count:ClearAllPoints()
				buffFrame.count:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE") --, MONOCHROME")
				buffFrame.count:SetPoint("TOPRIGHT", -3, 4);
				buffFrame.count:SetJustifyH("RIGHT");
				buffFrame.count:SetTextColor(1, 1 ,0, 1)
			else
				buffFrame.count:ClearAllPoints()
				buffFrame.count:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE") --, MONOCHROME")
				buffFrame.count:SetPoint("TOPRIGHT", -10, 6.5);
				buffFrame.count:SetJustifyH("RIGHT");
				buffFrame.count:SetTextColor(1, 1 ,0, 1)
			end
		elseif j == 13 then
			if strfind(f.unit,"pet") then
				buffFrame.count:ClearAllPoints()
				buffFrame.count:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE") --, MONOCHROME")
				buffFrame.count:SetPoint("RIGHT", 0,0);
				buffFrame.count:SetJustifyH("RIGHT");
				buffFrame.count:SetTextColor(1, 1 ,1, 1)
			else
				buffFrame.count:ClearAllPoints()
				buffFrame.count:SetFont("Fonts\\FRIZQT__.TTF", 10.5, "OUTLINE") --, MONOCHROME")
				buffFrame.count:SetPoint("RIGHT", 0, 2);
				buffFrame.count:SetJustifyH("RIGHT");
				buffFrame.count:SetTextColor(1, 1 ,1, 1)
			end
		else
			if strfind(f.unit,"pet") then
				buffFrame.count:ClearAllPoints()
				buffFrame.count:SetFont("Fonts\\FRIZQT__.TTF", 7, "OUTLINE") --, MONOCHROME")
				buffFrame.count:SetPoint("BOTTOMRIGHT", 3, -2);
				buffFrame.count:SetJustifyH("RIGHT");
			else
				buffFrame.count:ClearAllPoints()
				buffFrame.count:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE") --, MONOCHROME")
				buffFrame.count:SetPoint("BOTTOMRIGHT", 2, -4);
				buffFrame.count:SetJustifyH("RIGHT");
			end
		end
		
		buffFrame.debuffBorder = _G[buffFrame:GetName().."debuffBorder"] or buffFrame:CreateTexture(buffFrame:GetName().."debuffBorder", 'OVERLAY')
		buffFrame.debuffBorder:SetTexture("Interface/Buttons/UI-Debuff-Overlays")
		buffFrame.debuffBorder:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
		buffFrame.debuffBorder:SetAllPoints(buffFrame)

		buffFrame:SetSize(overlaySize, overlaySize) --ensures position is prelocked before showing , avoids the growing of row
		buffFrame:Hide()
	end
	for j = 1,#f.buffFrames do
		f.buffFrames[j]:Hide() --Hides Blizzards Frames
		f.buffFrames[j]:SetScript("OnShow", function(self) self:Hide() end)
	end
	f.dispelDebuffFrames[1]:SetAlpha(0); --Hides Dispel Icons in Upper Right
	f.dispelDebuffFrames[2]:SetAlpha(0); --Hides Dispel Icons in Upper Right
	f.dispelDebuffFrames[3]:SetAlpha(0); --Hides Dispel Icons in Upper Right
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Resets all Icons from the frame and the Events
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function DebuffFilter:ResetFrame(f)
	local scf = self.cache[f]
	if scf.guid then 
		self.cache[scf.guid] = nil
	end
	if scf.displayedguid then
		self.cache[scf.displayedguid] = nil
	end
	for k,v in pairs(scf.debuffFrames) do
		if v then
			v:Hide()
		end
	end
	for k,v in pairs(scf.buffFrames) do
		if v then
			v:Hide()
		end
	end
	for j = 1,#f.debuffFrames do
		f.debuffFrames[j]:SetScript("OnShow",nil)
		f.debuffFrames[j]:SetScript("OnEnter",nil)
	end
	for j = 1,#f.buffFrames do
		f.buffFrames[j]:SetScript("OnShow",nil)
		f.buffFrames[j]:SetScript("OnEnter",nil)
	end
	scf:UnregisterAllEvents()
	scf:SetScript("OnEvent", nil)
	scf.debuff = nil
	scf.buffs = nil
	scf = nil
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Frame Handler
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function scf_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5 = ...
	if ( event == 'PLAYER_ENTERING_WORLD' ) then
		DebuffFilter_UpdateAuras(self, nil, event)
	elseif ( event == 'ZONE_CHANGED_NEW_AREA' ) then
		DebuffFilter_UpdateAuras(self, nil, event)
	else
		local unitMatches = arg1 == self.unit or arg1 == self.displayedUnit
		if ( unitMatches ) then
			if ( event == 'UNIT_AURA' ) then
				local unitAuraUpdateInfo = arg2
				DebuffFilter_UpdateAuras(self, unitAuraUpdateInfo, event)
			end
		end
		--if ( unitMatches or arg1 == "player" then
		if ( unitMatches or arg1 == "player" )  then
			if ( event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "PLAYER_GAINS_VEHICLE_DATA" or event == "PLAYER_LOSES_VEHICLE_DATA" ) then
				if event == "UNIT_ENTERED_VEHICLE" or event == "PLAYER_GAINS_VEHICLE_DATA" then 
					self.vehicle = true 
				elseif event == "UNIT_EXITED_VEHICLE" or event == "PLAYER_LOSES_VEHICLE_DATA" then
					self.vehicle = nil
				end
				local f = _G[self.name]
				self:RegisterUnitEvent('UNIT_AURA', f.unit, f.displayedUnit)
				self:RegisterUnitEvent('PLAYER_GAINS_VEHICLE_DATA', f.unit, f.displayedUnit)
				self:RegisterUnitEvent('PLAYER_LOSES_VEHICLE_DATA', f.unit, f.displayedUnit)
				DebuffFilter_UpdateAuras(self, nil, event)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Frame Register
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function DebuffFilter:RegisterUnit(f, forced)
	local frame = _G["scf"..f:GetName()]
	local guid = UnitGUID(f.unit)
	local displayedguid = UnitGUID(f.displayedUnit) or UnitGUID(f.unit)

	if not guid or not displayedguid then return end
	if not forced and ( frame and frame.unit and frame.unit == f.unit and frame.displayedUnit == f.displayedUnit and frame.guid == guid and frame.displayedguid == displayedguid ) then return end 
	if forced and ( not f.unit or not f.displayedUnit ) then return end

	if not DebuffFilter.cache[f] then 
		DebuffFilter.cache[f] = frame or CreateFrame("Frame", "scf"..f:GetName()) 
	end

	local scf = DebuffFilter.cache[f]
	DebuffFilter.cache[guid] = DebuffFilter.cache[f]
	DebuffFilter.cache[displayedguid] = DebuffFilter.cache[f]
	scf.f = f
	scf.name = f:GetName()
	scf.guid = guid
	scf.displayedguid = displayedguid
	scf.unit = f.unit
	scf.displayedUnit = f.displayedUnit
	scf:SetScript("OnEvent", scf_OnEvent)
	--scf:RegisterUnitEvent('UNIT_PET', f.unit, f.displayedUnit)
	scf:RegisterUnitEvent('UNIT_AURA', f.unit, f.displayedUnit)
	scf:RegisterUnitEvent('PLAYER_GAINS_VEHICLE_DATA', f.unit, f.displayedUnit)
	scf:RegisterUnitEvent('PLAYER_LOSES_VEHICLE_DATA', f.unit, f.displayedUnit)
	scf:RegisterEvent('PLAYER_ENTERING_WORLD')
	scf:RegisterEvent('ZONE_CHANGED_NEW_AREA')
	scf:RegisterEvent('UNIT_EXITED_VEHICLE')
	scf:RegisterEvent('UNIT_ENTERED_VEHICLE')

	DebuffFilter:ApplyFrame(f)
	DebuffFilter_UpdateAuras(scf, nil, "RegisterUnit "..f.unit)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Finding Used Frames and Unused Fames from API
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function  DebuffFilter:findFrames(forced, event)
	--print("DebufF_Filter_Frames: "..event)
	if CompactRaidFrameManager.container.groupMode == "flush"  then
		for i = 1, 80 do
			local f = _G["CompactRaidFrame"..i]
			if f and f.unit then
				self:RegisterUnit(f, forced)
			elseif self.cache[f] then 
				self:ResetFrame(f)
			end
		end
	elseif CompactRaidFrameManager.container.groupMode == "discrete"  then
		for i = 1, 8 do
			for j = 1, 5 do
				local f = _G["CompactRaidGroup"..i.."Member"..j]
				if f and f.unit then
					self:RegisterUnit(f, forced)
				elseif self.cache[f] then 
					self:ResetFrame(f)
				end
			end
		end
		for i = 1, 10 do
			local f = _G["CompactRaidFrame"..i]
			if f and f.unit and UnitIsPlayer(f.unit) and not strfind(f.unit, "target") then
				self:RegisterUnit(f, forced)
			elseif self.cache[f] then 
				self:ResetFrame(f)
			end
		end
	end
	for i = 1, 5 do
		local f = _G["CompactPartyFrameMember"..i]
		if f and f.unit then
			self:RegisterUnit(f, forced)
		elseif self.cache[f] then 
			self:ResetFrame(f)
		end
	end


	for i = 1, 5 do
		local f = _G["CompactPartyFramePet"..i]
		if f and f.unit then
			self:RegisterUnit(f, forced)
		elseif self.cache[f] then 
			self:ResetFrame(f)
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--API Events
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




hooksecurefunc("CompactRaidFrameContainer_SetGroupMode", function(groupMode)
	DebuffFilter:findFrames(false, "CompactRaidFrameContainer_SetGroupMode")
	--print("groupMode")
end)

hooksecurefunc("CompactRaidFrameContainer_SetFlowFilterFunction", function(flowFilterFunc)
	DebuffFilter:findFrames(false,"CompactRaidFrameContainer_SetFlowFilterFunction")
	--print("flowFilterFunc")
end)

hooksecurefunc("CompactRaidFrameContainer_SetGroupFilterFunction", function(groupFilterFunc)
	DebuffFilter:findFrames(false, "CompactRaidFrameContainer_SetGroupFilterFunction")
	--print("groupFilterFunc")
end)

hooksecurefunc("CompactRaidFrameContainer_SetFlowSortFunction", function(flowSortFunc)
	DebuffFilter:findFrames(false, "CompactRaidFrameContainer_SetFlowSortFunction")
	--print("flowSortFunc")
end)



-- Event handling
local function OnEvent(self,event,...)
	local arg1, arg2, arg3, arg4 = ...
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then 
		self:DFCLEU()
		self:BOLCLEU()
		self:BORCLEU()
		self:BOCCLEU()
	elseif ( event == 'GROUP_ROSTER_UPDATE' ) then
		self:findFrames(false, event)
	elseif ( event == 'UNIT_PET' ) then
		self:findFrames(false, event)
	elseif ( event == 'PLAYER_ENTERING_WORLD' ) then
		local CRFC =_G["CompactRaidFrameContainer"]
		--local CPF = _G["CompactPartyFrame"]
		--CPF:SetScript("OnShow", find_frames)
		CRFC:SetScript("OnShow", find_frames)
		--CPF:SetScript("OnHide", find_frames)
		CRFC:SetScript("OnHide", find_frames)
		self:findFrames(true, event)
	elseif ( event == 'ZONE_CHANGED_NEW_AREA' ) then
		self:findFrames(true, event)
	end
end

DebuffFilter:SetScript("OnEvent", OnEvent)
DebuffFilter:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
DebuffFilter:RegisterEvent('PLAYER_ENTERING_WORLD')
DebuffFilter:RegisterEvent('ZONE_CHANGED_NEW_AREA')
DebuffFilter:RegisterEvent('GROUP_ROSTER_UPDATE')
DebuffFilter:RegisterEvent('UNIT_PET')

DebuffFilter_Force = CreateFrame('CheckButton', 'DebuffFilter_Force', DebuffFilter_Force, 'UICheckButtonTemplate')
DebuffFilter_Force:SetScript('OnClick', function() DebuffFilter:findFrames(true, "player"); print("DebuffFilter Forced") end)
