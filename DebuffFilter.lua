


local DebuffFilter = CreateFrame("Frame")
DebuffFilter.cache = {}

local DEFAULT_DEBUFF = 3
local DEFAULT_BIGDEBUFF = 5
local DEFAULT_BUFF = 14 --This Number Needs to Equal the Number of tracked Table Buf
local BIGGEST = 1.6
local BIGGER = 1.45
local BIG = 1.45
local BOSSDEBUFF = 1.45
local BOSSBUFF = 1.45
local WARNING = 1.3
local PRIORITY = 1.1
local DEBUFF = .925

local class_Name, class_Filename, class_Id = UnitClass("player")
local UNIT_CLASS = class_Filename

local BUFF_SIZE = .95

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

PriorityBuff[14] = {
	"Weakened Soul",
}

PriorityBuff[1] = {
	"Power Word: Shield",
	"Arcane Intellect",
	"Arcane Brilliance",
	"Dalaran Brilliance",
}

PriorityBuff[2] = {
	"Renew",
	"Dampen Magic",
	"Amplify Magic",
}

PriorityBuff[3] = {
	"Prayer of Mending",
	"Focus Magic"
}

local row1Buffs = {}
local row1BuffsCount = 1
for i = 1, 3 do
	for _, v in ipairs(PriorityBuff[i]) do
		row1Buffs[v] = row1BuffsCount
		row1BuffsCount = row1BuffsCount + 1
	end
end

	--Second Row 1
PriorityBuff[10] = {
	--"Regrowth",
}
	
	--Second Row 2
PriorityBuff[11] = {
	--"Wild Growth",
}
	--Second Row 3
PriorityBuff[12] = {
	--"Adaptive Swarm",
}

local row2Buffs = {}
local row2BuffsCount = 1
for i = 10, 12 do
	for _, v in ipairs(PriorityBuff[i]) do
		row2Buffs[v] = row2BuffsCount
		row2BuffsCount = row2BuffsCount + 1
	end
end

--Upper Circle Right on Icon 1
PriorityBuff[4] = {
	"Power Word: Fortitude",
	"Prayer of Fortitude",
	"Fortitude"
}

--Upper Circle Right on Icon 2
PriorityBuff[5] = {
	"Divine Spirit",
	"Prayer of Spirit",
}

--Upper Circle Right on Icon 3
PriorityBuff[6] = {
	"Shadow Protection",
	"Prayer of Shadow Protection",
	"Mark of the Wild",
	GetSpellInfo(26992), --Thorns (Friendly and Enemy spellId)
	"Battle Shout",
}
--Upper Circle Right on Icon 4
PriorityBuff[7] = {
	"Vampiric Embrace",
	"Arcane Intellect",
	"Arcane Brilliance",
	"Dalaran Brilliance",
}

--------------------------------------------------------------------------------------------------------------------------------------------------
--UPPER RIGHT PRIO COUNT (Buff Overlay Right)
--------------------------------------------------------------------------------------------------------------------------------------------------
PriorityBuff[8] = {
 	--**Resets**--

	14185, --Preparation
	11958, --Cold Snap
	23989,  --Readiness

	--**Class Stealth**--

	"Prowl", 
	"Stealth",
	"Camouflage",
	5384, --Feign Death
	GetSpellInfo(66), --Invisibility

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

	--**Class Perm Passive Buffs & DMG CDs**--

	51271, --Unbreakable Armor
	49206, --Ebon Gargoyle
	49028, --Dancing Rune Weapon
	"Blood Presence",
	"Frost Presence",
	"Unholy Presence",

	"Dire Bear Form", 
	50334, --Berserk
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
	--"Aspect of the Viper", 
	--"Aspect of the Dragonhawk",

	GetSpellInfo(11129), --Combustion
	12043, --Presence of Mind (talent)
	12472, --Icy Veins
	12042, --Arcane Power
	11426, --Ice Barrier
	GetSpellInfo(11426), --Ice Barrier
	"Mana Shield",
	"Frost Ward",
	"Fire Ward",
	58833, --Mirror Image
	58834, --Mirror Image
	58831, --Mirror Image
	31687, --Water Elemental
	"Mage Armor",
	"Frost Armor",
	"Molten Armor",
	"Ice Armor",

	54428, --Divine Plea
	31842, --Divine Illumination (talent)
	
	34433,  --Disc Pet Summmon Sfiend
	"Shadowform", --Shadowform
	"Inner Fire", --Inner Fire

	13750,  --Adrenline Rush
	51690, --Killing Spree
	13877, --Blade FLurry
	57934, --Tricksing the Target
	14177, --Cold Blood

	2645,   --Ghost Wolf
	GetSpellInfo(16166), --Elemental Mastery (talent)
	51533, --Feral Spirits (Summon or Buff)

	1122, --Infernals
	"Shadow Ward",
	"Soul Link",

	1719,  --Recklessness
	12292, --Death Wish

}

local BORBuffs = {}
local BORBuffsCount = 1
for i = 4, 8 do
	for _, v in ipairs(PriorityBuff[i]) do
		BORBuffs[v] = BORBuffsCount 
		BORBuffsCount = BORBuffsCount  + 1
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------
--UPPER LEFT PRIO COUNT (Buff Overlay Right)
--------------------------------------------------------------------------------------------------------------------------------------------------
PriorityBuff[9] = {

	"Food",
	"Drink",
	"Food & Drink",
	"Refreshment",
	
	--**Immunity Raid**-----------------------------------------------------------------------
	
	--**Healer CDs Given**--------------------------------------------------------------------

	1022, --Blessing of Protection
	5599, --Blessing of Protection
	10278, --Blessing of Protection
	6940, ---Hand of Sacrifice (30%)
	64205, --Divine Sacrifice
	31821, --Aura Mastery

	33206, --Pain Suppression
	47788, --Guardian Spirit
	64901, --Hym of Hope
	64844, --Divine Hymn Stacks
	64843, --Divine Hymn

	GetSpellInfo(53312), --Nature's Grasp (Has Stacks)
	"Tranquility", --Tranquility (Has Stacks)
	--98007, --Spirit Link Totem
	--325174, --Spirit Link Totem
	
	--**Class Healing CDs**---------------------------------------------------------------------

	50461, --Anti-Magic Zone
	--97463, --Rallying Cry
		
	--**Class Healing & DMG CDs Given**---------------------------------------------------------
	
	"Power Infusion",
	GetSpellInfo(2825), --Bloodlust
	GetSpellInfo(32182), --Heroism
	29166, --Innervate
	16191, --Mana Tide

	--** Healer CDs Given w/ Short CD**---------------------------------------------------------

	GetSpellInfo(552), --Abolish Disease
	GetSpellInfo(2893), --Abolish Poison

	--**CC Help**-------------------------------------------------------------------------------

	49016, --Unholy Frenzy
	6346, --Fear Ward
	
	--**Passive Buffs Given**------------------------------------------------------------------
	53601, --Sacred Shield
	--GetSpellInfo(26992), --Thorns (Friendly and Enemy spellId)
	--974, --Earth Shield (Has Stacks)
	--Beacons
	--317920, --Concentration Aura
	--465, --Devotion Aura
	--32223, --Crusader Aura
}

local BOLBuffs = {}
local BOLBuffsCount = 1
for i = 9, 9 do
	for _, v in ipairs(PriorityBuff[i]) do
		BOLBuffs[v] = BOLBuffsCount 
		BOLBuffsCount = BOLBuffsCount  + 1
	end
end

local Buff = {}
for i = 1, DEFAULT_BUFF do
	for k, v in ipairs(PriorityBuff[i]) do
		if not Buff[i] then Buff[i] = {} end
		Buff[i][v] = k
	end
end

 --------------------------------------------------------------------------------------------------------------------------------------------------
 --Debuffs
 --------------------------------------------------------------------------------------------------------------------------------------------------
local spellIds = {

--DONT SHOW
	[57723] = "Hide", --Exhaustion
	[390435] = "Hide", --Exhaustion
	[57724] = "Hide", --Sated
	[6788] = "Hide", --Weakened Soul

	[69127] = "Hide", --Weakened Soul


---GENERAL DANGER---
--DEATH KNIGHT
	[49206] = "Biggest", --Ebon Gargoyle
	[45524] = "Big", --Chains of Ice
	[GetSpellInfo(49194)] = "Warning", --Unholy Blight

--DRUID
	[GetSpellInfo(58181)] = "Big", -- Infected Wounds
	[GetSpellInfo(770)] = "Warning", -- "Faerie Fire
	[GetSpellInfo(16857)] = "Warning", --"Faerie Fire (Feral)
	[GetSpellInfo(5570)] = "Warning", --"Faerie Fire (Feral)



--HUNTER
	[63672]  = "Big", -- Black Arrow
	[GetSpellInfo(63672)] = "Big", -- Black Arrow
	[1130] = "Warning", -- Hunter's Mark
	[GetSpellInfo(1130)] = "Warning", -- Hunter's Mark
	[49050] = "Priority", --Aimed Shot MS
	[GetSpellInfo(49050)]  = "Priority", --Aimed Shot MS

--MAGE
	[41425] = "Warning", --Hypothermia

--PALLY
	[25771] = "Warning", --Forbearance

--PRIEST
	[GetSpellInfo(48300)] = "Big", --Devouring Plague

--ROGUE
	[GetSpellInfo(13218)]  = "Priority",			-- Wound Poison (rank 1) (healing effects reduced by 50%)
	[GetSpellInfo(13222)]  = "Priority",			-- Wound Poison II (rank 2) (healing effects reduced by 50%)
	[GetSpellInfo(13223)]  = "Priority",			-- Wound Poison III (rank 3) (healing effects reduced by 50%)
	[GetSpellInfo(13224)]  = "Priority",			-- Wound Poison IV (rank 4) (healing effects reduced by 50%)
	[GetSpellInfo(27189)]  = "Priority",			-- Wound Poison V (rank 5) (healing effects reduced by 50%)
	[GetSpellInfo(57974)]  = "Priority",			-- Wound Poison VI (rank 6) (healing effects reduced by 50%)
	[GetSpellInfo(57975)]  = "Priority",			-- Wound Poison VII (rank 7) (healing effects reduced by 50%)

--SHAMAN

--WARLOCK
	[GetSpellInfo(48181)] = "Bigger", -- Haunt
	[GetSpellInfo(30910)] = "Warning", -- Doom (Demo)

--WARRIOR
	[GetSpellInfo(772)]  = "Big", -- Rend		
	[GetSpellInfo(12294)]  = "Priority", -- Mortal Strike

--TRINKETS


--------------------------------------------------------------------------------------------------------------------------------------------------
--BGs & Pets
--------------------------------------------------------------------------------------------------------------------------------------------------
}

-- data from LoseControl
local bgBiggerspellIds = { --Always Shows for Pets
	
}

-- data from LoseControl
local bgBigspellIds = { --Always Shows for Pets
--CC--
	[51209] = "CC",  --Hungering Cold (talent)
	[47481] = "CC",  --Gnaw

	[33786] = "CC", 	--Cyclone
	[5211] = "CC",	-- Bash (rank 1)
	[6798] = "CC",	-- Bash (rank 2)
	[8983] = "CC", 	-- Bash (rank 3)
	[9005] = "CC",-- Pounce (rank 1)
	[9823] = "CC", 	-- Pounce (rank 2)
	[9827] = "CC",	-- Pounce (rank 3)
	[27006] = "CC", 	-- Pounce (rank 4)
	[49803] = "CC", 	-- Pounce (rank 5)
	[22570] = "CC", 	-- Maim (rank 1)
	[49802] = "CC", -- Maim (rank 2)
	[GetSpellInfo(16922)] = "CC",-- Imp Starfire Stun
	[2637] = "CC", 	-- Hibernate (rank 1)
	[18657] = "CC", 	-- Hibernate (rank 2)
	[18658] = "CC",	-- Hibernate (rank 3)

	[1513] = "CC",			-- Scare Beast (rank 1)
	[14326] = "CC", 			-- Scare Beast (rank 2)
	[14327] = "CC", 			-- Scare Beast (rank 3)
	[3355] = "CC", 		-- Freezing Trap (rank 1)
	[14308] = "CC", 	-- Freezing Trap (rank 2)
	[14309] = "CC",		-- Freezing Trap (rank 3)
	[60210] = "CC",			-- Freezing Arrow Effect
	[19386] = "CC", 			-- Wyvern Sting (talent) (rank 1)
	[24132] = "CC", 			-- Wyvern Sting (talent) (rank 2)
	[24133] = "CC", 			-- Wyvern Sting (talent) (rank 3)
	[27068] = "CC", 			-- Wyvern Sting (talent) (rank 4)
	[49011] = "CC", 			-- Wyvern Sting (talent) (rank 5)
	[49012] = "CC", 			-- Wyvern Sting (talent) (rank 6)
	[19503] = "CC", 			-- Scatter Shot (talent)

	[24394] = "CC", 				-- Intimidation (talent)
	[50519] = "CC", 				-- Sonic Blast (rank 1) (Bat)
	[53564] = "CC", 				-- Sonic Blast (rank 2) (Bat)
	[53565] = "CC", 				-- Sonic Blast (rank 3) (Bat)
	[53566] = "CC", 				-- Sonic Blast (rank 4) (Bat)
	[53567] = "CC", 				-- Sonic Blast (rank 5) (Bat)
	[53568] = "CC", 				-- Sonic Blast (rank 6) (Bat)
	[50518] = "CC", 				-- Ravage (rank 1) (Ravager)
	[53558] = "CC", 				-- Ravage (rank 2) (Ravager)
	[53559] = "CC", 				-- Ravage (rank 3) (Ravager)
	[53560] = "CC", 				-- Ravage (rank 4) (Ravager)
	[53561] = "CC", 				-- Ravage (rank 5) (Ravager)
	[53562] = "CC", 				-- Ravage (rank 6) (Ravager)

	["Polymorph"] = "CC", 
	[118] =   "CC", 				-- Polymorph (rank 1)
	[12824] = "CC", 				-- Polymorph (rank 2)
	[12825] = "CC", 				-- Polymorph (rank 3)
	[12826] = "CC", 				-- Polymorph (rank 4)
	[28271] = "CC", 				-- Polymorph: Turtle
	[28272] = "CC", 				-- Polymorph: Pig
	[61305] = "CC", 				-- Polymorph: Black Cat
	[61721] = "CC", 				-- Polymorph: Rabbit
	[61780] = "CC", 				-- Polymorph: Turkey
	[71319] = "CC", 				-- Polymorph: Turkey
	[61025] = "CC", 				-- Polymorph: Serpent
	[59634] = "CC", 				-- Polymorph - Penguin (Glyph)
	[12355] = "CC", 				-- Impact (talent)
	[31661] = "CC", 				-- Dragon's Breath (rank 1) (talent)
	[33041] = "CC", 				-- Dragon's Breath (rank 2) (talent)
	[33042] = "CC", 				-- Dragon's Breath (rank 3) (talent)
	[33043] = "CC", 				-- Dragon's Breath (rank 4) (talent)
	[42949] = "CC", 				-- Dragon's Breath (rank 5) (talent)
	[42950] = "CC", 				-- Dragon's Breath (rank 6) (talent)
	[44572] = "CC", 				-- Deep Freeze (talent)

	[853] = "CC", 				-- Hammer of Justice (rank 1)
	[5588] = "CC", 				-- Hammer of Justice (rank 2)
	[5589] = "CC", 				-- Hammer of Justice (rank 3)
	[10308] = "CC", 				-- Hammer of Justice (rank 4)
	[2812] = "CC", 				-- Holy Wrath (rank 1)
	[10318] = "CC", 				-- Holy Wrath (rank 2)
	[27139] = "CC", 				-- Holy Wrath (rank 3)
	[48816] = "CC", 				-- Holy Wrath (rank 4)
	[48817] = "CC", 				-- Holy Wrath (rank 5)
	[20170] = "CC", 				-- Stun (Seal of Justice)
	[10326] = "CC", 				-- Turn Evil
	[20066] = "CC", 				-- Repentance (talent)

	[605] = "CC", 					-- Mind Control
	[8122] = "CC", 				-- Psychic Scream (rank 1)
	[8124] = "CC", 				-- Psychic Scream (rank 2)
	[10888] = "CC", 				-- Psychic Scream (rank 3)
	[10890] = "CC", 				-- Psychic Scream (rank 4)
	[9484] = "CC", 				-- Shackle Undead (rank 1)
	[9485] = "CC", 				-- Shackle Undead (rank 2)
	[10955] = "CC", 				-- Shackle Undead (rank 3)
	[64044] = "CC", 				-- Psychic Horror (talent)

	[2094] = "CC", 				-- Blind
	[408] = "CC", 				-- Kidney Shot (rank 1)
	[8643] = "CC", 				-- Kidney Shot (rank 2)
	[1833] = "CC", 				-- Cheap Shot
	[6770] = "CC", 				-- Sap (rank 1)
	[2070] = "CC", 				-- Sap (rank 2)
	[11297] = "CC", 			-- Sap (rank 3)
	[51724] = "CC", 			-- Sap (rank 4)
	[1776] = "CC", 				-- Gouge


	["Hex"] = "CC", 
	[58861] = "CC",  --Bash (Spirit Wolf)
	[39796] = "CC",   --Stoneclaw Stun (Stoneclaw Totem)

	[710] = "CC",  			-- Banish (rank 1)
	[18647] = "CC",  				-- Banish (rank 2)
	[5782] = "CC",  					-- Fear (rank 1)
	[6213] = "CC",  					-- Fear (rank 2)
	[6215] = "CC",  					-- Fear (rank 3)
	[5484] = "CC",  					-- Howl of Terror (rank 1)
	[17928] = "CC",  				-- Howl of Terror (rank 2)
	[6789] = "CC",  					-- Death Coil (rank 1)
	[17925] = "CC",  					-- Death Coil (rank 2)
	[17926] = "CC",  					-- Death Coil (rank 3)
	[27223] = "CC",  					-- Death Coil (rank 4)
	[47859] = "CC",  					-- Death Coil (rank 5)
	[47860] = "CC",  					-- Death Coil (rank 6)
	[22703] = "CC",  					-- Inferno Effect
	[30283] = "CC",  					-- Shadowfury (rank 1) (talent)
	[30413] = "CC",  					-- Shadowfury (rank 2) (talent)
	[30414] = "CC",  					-- Shadowfury (rank 3) (talent)
	[47846] = "CC",  					-- Shadowfury (rank 4) (talent)
	[47847] = "CC",  					-- Shadowfury (rank 5) (talent)
	[60995] = "CC",  					-- Demon Charge (metamorphosis talent)
	[54786] = "CC",  					-- Demon Leap (metamorphosis talent)
	[30153] = "CC",  				-- Intercept Stun (rank 1) (Felguard)
	[30195] = "CC",  				-- Intercept Stun (rank 2) (Felguard)
	[30197] = "CC",  				-- Intercept Stun (rank 3) (Felguard)
	[47995] = "CC",  				-- Intercept Stun (rank 4) (Felguard)
	[6358] = "CC",  				-- Seduction (Succubus)
	[19482] = "CC",  				-- War Stomp (Doomguard)
	[32752] = "CC",  				-- Summoning Disorientation

	[7922] = "CC",  					-- Charge (rank 1/2/3)
	[20253] = "CC",  				-- Intercept
	[5246] = "CC",  				-- Intimidating Shout
	[20511] = "CC",  				-- Intimidating Shout
	[12809] = "CC",  			-- Concussion Blow (talent)
	[46968] = "CC",  			-- Shockwave (talent)

	[20549] = "CC", 				-- War Stomp (tauren racial)


	[47476] = "Silence",  -- Strangulate
	[34490] = "Silence",  --Silencing Shot
	[18469] = "Silence", 	-- Counterspell - Silenced (rank 1) (Improved Counterspell talent)
	[55021] = "Silence", 			-- Counterspell - Silenced (rank 2) (Improved Counterspell talent)
	[63529] = "Silence", 		-- Silenced - Shield of the Templar (talent)
	[15487] = "Silence", 			-- Silence (talent)
	[1330] = "Silence",  --Garrote - Silence_Arena
	[18425] = "Silence",  --Kick - Silenced (talent)
	[31117] = "Silence",  --Unstable Affliction
	[24259] = "Silence",  --Spell Lock (Felhunter)
	[74347] = "Silence", 			-- Silenced - Gag Order (Improved Shield Bash talent)
	[18498] = "Silence", 		-- Silenced - Gag Order (Improved Shield Bash talent
	[25046] = "Silence", 			-- Arcane Torrent (blood elf racial)
	[28730] = "Silence", 			-- Arcane Torrent (blood elf racial)
	[50613] = "Silence", 			-- Arcane Torrent (blood elf racial)


	--[212638] = "RootPhyiscal_Special"},				-- Tracker's Net (pvp honor talent) -- Also -80% hit chance melee & range physical (CC and Root category)

	[339] = "Root", -- Entangling Roots (rank 1)
	[1062] = "Root", -- Entangling Roots (rank 2)
	[5195] = "Root", -- Entangling Roots (rank 3)
	[5196] = "Root", -- Entangling Roots (rank 4)
	[9852] = "Root", -- Entangling Roots (rank 5)
	[9853] = "Root", -- Entangling Roots (rank 6)
	[26989] = "Root",  -- Entangling Roots (rank 7)
	[53308] = "Root",  -- Entangling Roots (rank 8)
	[19975] = "Root", -- Entangling Roots (rank 1) (Nature's Grasp spell)
	[19974] = "Root", -- Entangling Roots (rank 2) (Nature's Grasp spell)
	[19973] = "Root", -- Entangling Roots (rank 3) (Nature's Grasp spell)
	[19972] = "Root", -- Entangling Roots (rank 4) (Nature's Grasp spell)
	[19971] = "Root", -- Entangling Roots (rank 5) (Nature's Grasp spell)
	[19970] = "Root", -- Entangling Roots (rank 6) (Nature's Grasp spell)
	[27010] = "Root", -- Entangling Roots (rank 7) (Nature's Grasp spell)
	[53313] = "Root", -- Entangling Roots (rank 8) (Nature's Grasp spell)
	[GetSpellInfo(16979)] = "Root",	-- Feral Charge Effect (Feral Charge talent)
	[45334] = "Root", 		-- Feral Charge Effect (Feral Charge talent)
	[19306] = "Root", 			-- Counterattack (talent) (rank 1)
	[20909] = "Root", 			-- Counterattack (talent) (rank 2)
	[20910] = "Root", 			-- Counterattack (talent) (rank 3)
	[27067] = "Root", 			-- Counterattack (talent) (rank 4)
	[48998] = "Root", 			-- Counterattack (talent) (rank 5)
	[48999] = "Root", 			-- Counterattack (talent) (rank 6)
	[19185] = "Root", 			-- Entrapment (talent) (rank 1)
	[64803] = "Root", 			-- Entrapment (talent) (rank 2)
	[64804] = "Root", 			-- Entrapment (talent) (rank 3)
	[4167] = "Root", 			-- Web (rank 1) (Spider)
	[4168] = "Root", 			-- Web II
	[4169] = "Root", 			-- Web III
	[54706] = "Root", 			-- Venom Web Spray (rank 1) (Silithid)
	[55505] = "Root", 			-- Venom Web Spray (rank 2) (Silithid)
	[55506] = "Root", 			-- Venom Web Spray (rank 3) (Silithid)
	[55507] = "Root", 			-- Venom Web Spray (rank 4) (Silithid)
	[55508] = "Root", 			-- Venom Web Spray (rank 5) (Silithid)
	[55509] = "Root", 			-- Venom Web Spray (rank 6) (Silithid)
	[50245] = "Root", 			-- Pin (rank 1) (Crab)
	[53544] = "Root", 			-- Pin (rank 2) (Crab)
	[53545] = "Root", 			-- Pin (rank 3) (Crab)
	[53546] = "Root", 			-- Pin (rank 4) (Crab)
	[53547] = "Root", 			-- Pin (rank 5) (Crab)
	[53548] = "Root", 			-- Pin (rank 6) (Crab)
	[53148] = "Root", 			-- Charge (Bear and Carrion Bird)
	[25999] = "Root", 			-- Boar Charge (Boar)
	[122] = "Root", 				-- Frost Nova (rank 1)
	[865] = "Root", 				-- Frost Nova (rank 2)
	[6131] = "Root", 			-- Frost Nova (rank 3)
	[10230] = "Root", 			-- Frost Nova (rank 4)
	[27088] = "Root", 			-- Frost Nova (rank 5)
	[42917] = "Root", 			-- Frost Nova (rank 6)
	[12494] = "Root", 			-- Frostbite (talent)
	[55080] = "Root", 			-- Shattered Barrier (talent)
	[33395] = "Root", 			-- Freeze
	[64695] = "Root",  		-- Earthgrab
	[63685] = "Root",  		-- Freeze (Frozen Power talent)
	[23694] = "Root",  		-- Imp Hamstring

	[53359] = "Disarm",  			--Chimera Shot - Scorpid (talent)
	[54404] = "Disarm", 			-- Dust Cloud (chance to hit reduced by 100%) (Tallstrider)
	[50541] = "Disarm", 			-- Snatch (rank 1) (Bird of Prey)
	[53537] = "Disarm", 			-- Snatch (rank 2) (Bird of Prey)
	[53538] = "Disarm", 			-- Snatch (rank 3) (Bird of Prey)
	[53540] = "Disarm", 			-- Snatch (rank 4) (Bird of Prey)
	[53542] = "Disarm", 			-- Snatch (rank 5) (Bird of Prey)
	[53543] = "Disarm", 			-- Snatch (rank 6) (Bird of Prey)
	[64346] = "Disarm", 			-- Fiery Payback (talent)
	[64058] = "Disarm", 			-- Psychic Horror (talent)
	[51722] = "Disarm", 			-- Dismantle
	[676] = "Disarm", 			-- Disarm

}

-- data from LoseControl Warning 
local bgWarningspellIds = { --Always Shows for Pets
	[GetSpellInfo(30108)] = "True", -- UA
	[30108] = "True", -- UA
	[233490] = "True", -- UA
	[233497] = "True", -- UA
	[233496] = "True", -- UA
	[233498] = "True", -- UA
	[233499] = "True", -- UA	
	[342938] = "True", -- UA Shadowlands
	[316099] = "True", -- UA
	[43522] = "True", -- UA
	[34438] = "True", -- UA
	[34439] = "True", -- UA
	[251502] = "True", -- UA
	[65812] = "True", -- UA
	[35183] = "True", -- UA
	[211513] = "True", -- UA
	[285142] = "True", -- UA
	[285143] = "True", -- UA
	[285144] = "True", -- UA
	[285145] = "True", -- UA
	[285146] = "True", -- UA
	[34914] = "True", -- VT
	[GetSpellInfo(34914)] = "True", -- VT

	[49206] = "Biggest", --Ebon Gargoyle
	[45524] = "Big", --Chains of Ice

	[GetSpellInfo(58181)] = "Big", -- Infected Wounds

	[GetSpellInfo(48181)] = "Bigger", -- Warlock: Soulrot 

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
  return a[6] < b[6]
end


local function compare_2(a, b)
	if a[6] < b[6] then return true end
	if a[6] > b[6] then return false end
	return a[3] > b[3]
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
		local duration = 10
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
		DebuffFilter:buffsBOL(scf, uid)
	end
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--BOR CLEU Events
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local CLEUBOR = {}
local summonedAura = {
	[49206]  = 40, --Ebon Gargoyle

	[33831] = 30, --Trees

	[31687] = 45, -- Water Ele DOESNT WORK SPELL CAST SUCCESS
	[58833] = 30, --Mirror Image
	[58834] = 30, --Mirror Image
	[58831] = 30, --Mirror Image

	[34433]  = 15, --Disc Pet Summmon Sfiend "Shadowfiend" same Id has sourceGUID

	[51533] = 45, --Feral Spirits

	[1122] = 60, --Warlock Infernals,  has sourceGUID (spellId and Summons are different) [spellbookid]


}



local castedAura = {
--Casted Spells
	[14185] = 2, --Preparation
	[11958] = 2, --Cold Snap
	[23989] = 2,  --Readiness
	--[202770] = 8, --Fury of Elune


}

function DebuffFilter:BORCLEU()
	local _, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellId, _, _, _, _, spellSchool = CombatLogGetCurrentEventInfo()
	local scf, uid

	-----------------------------------------------------------------------------------------------------------------
	--Summoned
	-----------------------------------------------------------------------------------------------------------------
	if (event == "SPELL_SUMMON") or (event == "SPELL_CREATE") or (event == "SPELL_CAST_SUCCESS" and spellId == 31687) then --Summoned CDs
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
			tblinsert(CLEUBOR[sourceGUID], {icon, duration, expirationTime, spellId, destGUID, BORBuffs[spellId], sourceName, namePrint})
			tblsort(CLEUBOR[sourceGUID], compare_1)
			tblsort(CLEUBOR[sourceGUID], compare_2)
			local ticker = 1
			Ctimer(duration, function()
				if CLEUBOR[sourceGUID] then
					for k, v in pairs(CLEUBOR[sourceGUID]) do
						if v[4] == spellId then
							--print(v[7].." ".."Timed Out".." "..v[8].." "..substring(v[5], -7).." left w/ "..string.format("%.2f", v[3]-GetTime()).." BOR C_Timer")
							tremove(CLEUBOR[sourceGUID], k)
							tblsort(CLEUBOR[sourceGUID], compare_1)
							tblsort(CLEUBOR[sourceGUID], compare_2)
							if #CLEUBOR[sourceGUID] ~= 0 then DebuffFilter:buffsBOR(scf, uid) end
							if #CLEUBOR[sourceGUID] == 0 then
								CLEUBOR[sourceGUID] = nil
								DebuffFilter:buffsBOR(scf, uid)
							end
						end
					end
				end
			end)
			self.ticker = C_Timer.NewTicker(.1, function()
				if CLEUBOR[sourceGUID] then
					for k, v in pairs(CLEUBOR[sourceGUID]) do
						if (v[5] and (v[4] ~= 394243 and v[4] ~= 387979 and v[4] ~= 394235)) then --Dimmensional Rift Hack to Not Deswpan
							if substring(v[5], -5) == substring(guid, -5) then --string.sub is to help witj Mirror Images bug
								if ObjectDNE(v[5]) then
								--print(v[7].." "..ObjectDNE(v[5], ticker, v[8], v[7]).." "..v[8].." "..substring(v[5], -7).." left w/ "..string.format("%.2f", v[3]-GetTime()).." BOR C_Ticker")
								tremove(CLEUBOR[sourceGUID], k)
								tblsort(CLEUBOR[sourceGUID], compare_1)
								tblsort(CLEUBOR[sourceGUID], compare_2)
								if #CLEUBOR[sourceGUID] ~= 0 then DebuffFilter:buffsBOR(scf, uid) end
								if #CLEUBOR[sourceGUID] == 0 then
									CLEUBOR[sourceGUID] = nil
									DebuffFilter:buffsBOR(scf, uid)
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
			tblinsert(CLEUBOR[sourceGUID], {icon, duration, expirationTime, spellId, destGUID, BORBuffs[spellId], sourceName, namePrint})
			tblsort(CLEUBOR[sourceGUID], compare_1)
			tblsort(CLEUBOR[sourceGUID], compare_2)
			Ctimer(duration, function()
				if CLEUBOR[sourceGUID] then
					for k, v in pairs(CLEUBOR[sourceGUID]) do
						if v[4] == spellId then
							--print(v[7].." ".."Timed Out".." "..v[8].." "..substring(v[5], -7).." left w/ "..string.format("%.2f", v[3]-GetTime()).." BOR C_Timer")
							tremove(CLEUBOR[sourceGUID], k)
							tblsort(CLEUBOR[sourceGUID], compare_1)
							tblsort(CLEUBOR[sourceGUID], compare_2)
							if #CLEUBOR[sourceGUID] ~= 0 then DebuffFilter:buffsBOR(scf, uid) end
							if #CLEUBOR[sourceGUID] == 0 then
								CLEUBOR[sourceGUID] = nil
								DebuffFilter:buffsBOR(scf, uid)
							end
						end
					end
				end
			end)
		end
	end

	if scf and uid then 
		DebuffFilter:buffsBOR(scf, uid)
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
	if ((event == "SPELL_CAST_SUCCESS") and (spellId == 212182 or spellId == 359053)) then
		if (sourceGUID ~= nil) then
		local duration = 5
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
	--[[if (spellId == 325216 or spellId == 386276) then --BoneDust Brew
		local id, specID
		if source then
			if strfind(source, "nameplate") then
				if (UnitGUID(source) == UnitGUID("arena1")) then id = 1 elseif (UnitGUID(source) == UnitGUID("arena2")) then id = 2 elseif (UnitGUID(source) == UnitGUID("arena3")) then id = 3 end
			else
				if strfind(source, "arena1") then id = 1 elseif strfind(source, "arena2") then id = 2 elseif strfind(source, "arena3") then id = 3 end
			end
			specID = GetArenaOpponentSpec(id)
			if specID then
				if (specID == 270) then --Monk: Brewmaster: 268 / Windwalker: 269 / Mistweaver: 270
					spellIds[spellId] = "Warning"
					bgWarningspellIds[spellId] = "True"
				else
					spellIds[spellId] = "Big"
					bgWarningspellIds[spellId] = nil
				end
			end
		end
	end
	if (spellId == 391889) then --Adaptive Swarm
		local id, specID
		if source then
			if strfind(source, "nameplate") then
				if (UnitGUID(source) == UnitGUID("arena1")) then id = 1 elseif (UnitGUID(source) == UnitGUID("arena2")) then id = 2 elseif (UnitGUID(source) == UnitGUID("arena3")) then id = 3 end
			else
				if strfind(source, "arena1") then id = 1 elseif strfind(source, "arena2") then id = 2 elseif strfind(source, "arena3") then id = 3 end
			end
			specID = GetArenaOpponentSpec(id)
			if specID then
				if (specID == 105) then --Druid: Balance: 102 / Feral: 103 / Guardian: 104 /Restoration: 105
					spellIds[spellId] = "Priority"
					bgWarningspellIds[spellId] = "True"
				else
					spellIds[spellId] = "Warning"
					bgWarningspellIds[spellId] = nil
				end
			end
		end
	end]]
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
	--[[if (spellId == 188389) then --Flame Shock
		local id, specID
		if source then
			if strfind(source, "nameplate") then
				if (UnitGUID(source) == UnitGUID("arena1")) then id = 1 elseif (UnitGUID(source) == UnitGUID("arena2")) then id = 2 elseif (UnitGUID(source) == UnitGUID("arena3")) then id = 3 end
			else
				if strfind(source, "arena1") then id = 1 elseif strfind(source, "arena2") then id = 2 elseif strfind(source, "arena3") then id = 3 end
			end
			specID = GetArenaOpponentSpec(id)
			if specID then
				if (specID == 262) then --Shaman: Elemental: 262 / Enhancement: 263 / Resto 264
					spellIds[spellId] = "Warning"
					bgWarningspellIds[spellId] = "True"
				else
					spellIds[spellId] = "Priority"
					bgWarningspellIds[spellId] = nil
				end
			end
		end
	end]]
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
		if (spellIds[spellId] == "Priority" or spellIds[name] == "Priority") then
		return true
	else
		return false
	end
end

local function isDispelPriority(unit, index, filter)
    local  name, _, _, debuffType, _, _, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	if UNIT_CLASS == "PRIEST" and debuffType == "Disease" then
		return true
	elseif UNIT_CLASS == "MAGE" and debuffType == "Curse" then
		return true
	else
		return false
	end
end

local function isMagicPriority(unit, index, filter)
    local  name, _, _, debuffType, _, _, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
	if debuffType == "Magic" then
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
		--icon = 463560
		--icon = 236922
		icon = 236925
	end

	if spellId == 115196 then --Shiv
		icon = 135428
	end
	
	if spellId == 285515 then --Frost Shock to Frost Nove
		icon = 135848
	end

	debuffFrame.icon:SetTexture(icon);
	debuffFrame.icon:SetDesaturated(nil) --Destaurate Icon
	debuffFrame.icon:SetVertexColor(1, 1, 1);
	if filter == "HARMFUL" then 
		debuffFrame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(debuffFrame.icon, "ANCHOR_RIGHT")
			GameTooltip:SetUnitDebuff(uid, buffId, "HARMFUL")
			GameTooltip:Show()
		end)
		debuffFrame:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	elseif filter == "HELPFUL" then 
		debuffFrame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(debuffFrame.icon, "ANCHOR_RIGHT")
			GameTooltip:SetUnitBuff(uid, buffId, "HELPFUL")
			GameTooltip:Show()
		end)
		debuffFrame:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	----------------------------------------------------------------------------------------------------------------------------------------------
	--SmokeBomb
	----------------------------------------------------------------------------------------------------------------------------------------------
	if spellId == 212183 then -- Smoke Bomb
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
		--Curse & Disease
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
		end
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

local function isBuff(unit, index, filter, j)
	local name, _, _, _, _, _, _, _, _, spellId = UnitAura(unit, index, "HELPFUL");
  if Buff[j] and (Buff[j][spellId] or Buff[j][name]) then
	  return true
  else
	  return false
  end
end

local function isdeBuff(unit, index, filter, j)
local name, _, _, _, _, _, _, _, _, spellId = UnitAura(unit, index, "HARMFUL");
  if Buff[j] and (Buff[j][spellId] or Buff[j][name]) then
	  return true
  else
	  return false
  end
end

local function buffTooltip(buffFrame, uid, buffId, cleuSpell)
	buffFrame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(buffFrame.icon, "ANCHOR_RIGHT")
		if cleuSpell then
			GameTooltip:SetSpellByID(cleuSpell)
		elseif buffId then
			GameTooltip:SetUnitBuff(uid, buffId, "HELPFUL")
		end
		GameTooltip:Show()
	end)
	buffFrame:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
end

local function debuffTooltip(buffFrame, uid, buffId, cleuSpell)
	buffFrame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(buffFrame.icon, "ANCHOR_RIGHT")
		if cleuSpell then
			GameTooltip:SetSpellByID(cleuSpell)
		elseif buffId then
			GameTooltip:SetUnitDebuff(uid, buffId, "HARMFUL")
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

local function debuffFilter(uid, j, filter)
	local index, buff, backCount
	for i = 1, 40 do
		local buffName, _, count, debuffType, _, _, unitCaster, _, _, spellId = UnitAura(uid, i, filter)
		if ( buffName ) then
			if isdeBuff(uid, i, filter, j) then
				--if anybackCount[buffName] or anybackCount[spellId] then backCount = count end 	--Prayer of mending hack
				if Buff[j][buffName] then
						Buff[j][spellId] =  Buff[j][buffName]
				end
				if  Buff[j][spellId] then
					if not buff or  Buff[j][spellId] <  Buff[j][buff] then
						buff = spellId
						index = i
					end
				end
			end
		else
			break
		end
	end
	return index, buff, backCount
end

local function magicFilter(uid, j, filter)
	local magicBuffs = 0
	for i = 1, 40 do
		local buffName, _,  _, debuffType = UnitAura(uid, i, filter)
		if not buffName then break end
		if debuffType == "Magic" then
			magicBuffs = magicBuffs + 1
		end
	end
	return magicBuffs
end

local function buffFilter(uid, j, filter, player)
	local index, buff, backCount
	for i = 1, 40 do
		local buffName, _, count, debuffType, _, _, unitCaster, _, _, spellId = UnitAura(uid, i, filter)
		if ( buffName ) then
			if isBuff(uid, i, filter, j) then
				if anybackCount[buffName] or anybackCount[spellId] then backCount = count end 	--Prayer of mending hack
				if Buff[j][buffName] then
						Buff[j][spellId] =  Buff[j][buffName]
				end
				if  Buff[j][spellId] then
					if not buff or  Buff[j][spellId] <  Buff[j][buff] then
						buff = spellId
						index = i
					end
				end
			end
		else
			break
		end
	end
	return index, buff, backCount
end

local function buffFilterplayer(uid, j, filter)
	local index, buff, backCount
	for i = 1, 40 do
		local buffName, _, count, _, _, _, unitCaster, _, _, spellId = UnitAura(uid, i, filter)
		if ( buffName ) then
			if unitCaster == "player" and isBuff(uid, i, filter, j) then
				if (playerbackCount[buffName] or playerbackCount[spellId]) and unitCaster == "player" then backCount = count end 	--Prayer of mending hack
				if Buff[j][buffName] then
						Buff[j][spellId] =  Buff[j][buffName]
				end
				if  Buff[j][spellId] then
					if not buff or  Buff[j][spellId] <  Buff[j][buff] then
						buff = spellId
						index = i
					end
				end
			end
		else
			break
		end
	end
	return index, buff, backCount
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Buff Frame Main Loop, Sets Icon and Count in this Loop
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function DebuffFilter:buffsBOL(scf, uid)
	local f = scf.f
	local frameWidth, frameHeight = f:GetSize()
	local localizedClass, englishClass, classIndex = UnitClass(uid);
	local componentScale = min(frameHeight / NATIVE_UNIT_FRAME_HEIGHT, frameWidth / NATIVE_UNIT_FRAME_WIDTH);
	local overlaySize = 11 * componentScale
	local filter = "HELPFUL"
	for j = 9, 9 do
		local index, buff, backCount = buffFilter(uid, j, filter)
		local sourceGUID = UnitGUID(uid)
		local cleuSpell
		
		if index or CLEUBOL[sourceGUID] then
			local buffId = index
			local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura
			if CLEUBOL[sourceGUID] then
				if Buff[j][buff] == nil or (Buff[j][buff] > Buff[j][CLEUBOL[sourceGUID][1][4]]) then
					icon = CLEUBOL[sourceGUID][1][1]
					duration = CLEUBOL[sourceGUID][1][2]
					expirationTime = CLEUBOL[sourceGUID][1][3]
					spellId = CLEUBOL[sourceGUID][1][4]
					cleuSpell = spellId
					count = 0
				else
					name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitBuff(uid, index)
				end
			else
				name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitBuff(uid, index)
			end
			
			local buffFrame = scf.buffFrames[j]

			------------------------------------------------------------------------------------------------------------------------------------------------------------------
			----CLEU DeBuff Timer
			------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

			-----------------------------------------------------------------------------------------------------------------
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

			buffFrame.icon:SetTexture(icon);
			buffFrame.icon:SetDesaturated(nil) --Destaurate Icon
			buffFrame.icon:SetVertexColor(1, 1, 1);
			buffFrame.icon:SetTexCoord(0.01, .99, 0.01, .99)
			buffFrame.SpellId = spellId

			buffTooltip(buffFrame, uid, buffId, cleuSpell)
			buffCount(buffFrame, count, backCount)
			buffFrame:SetID(j);
			
			--[[if spellId == 199448 then --Ultimate Sac Glow
				ActionButton_ShowOverlayGlow(buffFrame)
			else
				ActionButton_HideOverlayGlow(buffFrame)
			end]]
			local startTime = expirationTime - duration;
			if expirationTime  - startTime > 61 then
				CooldownFrame_Clear(buffFrame.cooldown);
			else
				CooldownFrame_Set(buffFrame.cooldown, startTime, duration, true);
			end
			buffFrame:SetSize(overlaySize*1,overlaySize*1);
			buffFrame:Show();
		else
			local buffFrame = scf.buffFrames[j];
			if buffFrame then
				buffFrame:SetSize(overlaySize*1,overlaySize*1);
				buffFrame:Hide()
				ActionButton_HideOverlayGlow(buffFrame)
			end
		end
	index = nil; buff = nil; backCount= nil
	end
end

function DebuffFilter:buffsBOR(scf, uid)
	local f = scf.f
	local frameWidth, frameHeight = f:GetSize()
	local localizedClass, englishClass, classIndex = UnitClass(uid);
	local componentScale = min(frameHeight / NATIVE_UNIT_FRAME_HEIGHT, frameWidth / NATIVE_UNIT_FRAME_WIDTH);
	local overlaySize = 11 * componentScale
	local filter = "HELPFUL"
	local Z
	for j = 4, 8 do
		local index, buff, backCount = buffFilter(uid, j, filter)
		local sourceGUID = UnitGUID(uid)
		local cleuSpell
		local nameSpell = GetSpellInfo(buff)


		if UNIT_CLASS == "MAGE" and (nameSpell == "Arcane Intellect" or nameSpell == "Arcane Brilliance" or nameSpell == "Dalaran Brilliance") then index = nil end --Hack To Stop Showing Buffs on Certain Classes

		if index or (CLEUBOR[sourceGUID] and j == 8) then
			local buffId = index
			local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura
			if CLEUBOR[sourceGUID] and j == 8 then
				if Buff[j][buff] == nil or (Buff[j][buff] > Buff[j][CLEUBOR[sourceGUID][1][4]]) then
					icon = CLEUBOR[sourceGUID][1][1]
					duration = CLEUBOR[sourceGUID][1][2]
					expirationTime = CLEUBOR[sourceGUID][1][3]
					spellId = CLEUBOR[sourceGUID][1][4]
					cleuSpell = spellId
					if spellId == 58833 or spellId == 58831 or spellId == 58834 or spellId == 33831 then -- Trees and Mirror Image Count
						if not count then count = 0 end
						for i = 1, #CLEUBOR[sourceGUID] do
							if CLEUBOR[sourceGUID][i][4] == 58833  or CLEUBOR[sourceGUID][i][4] == 58831 or CLEUBOR[sourceGUID][i][4] == 58834 or CLEUBOR[sourceGUID][i][4] == 33831 then
								count = count + 1
							end
						end
					else
						count = 0
					end
				else
					name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitBuff(uid, index)
				end
			else
				name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitBuff(uid, index)
			end

			local buffFrame = scf.buffFrames[j]

			-----------------------------------------------------------------------------------------------------------------
			--Growing Buffs
			-----------------------------------------------------------------------------------------------------------------
			if j == 4 or j == 5 or j == 6 or j == 7 then
				if not Z then
					scf.buffFrames[4]:Hide();scf.buffFrames[5]:Hide();scf.buffFrames[6]:Hide();scf.buffFrames[7]:Hide();
					j = 4
					buffFrame = scf.buffFrames[j]; Z = j
				else
					buffFrame = scf.buffFrames[Z+1]
					Z = Z + 1
				end
			end
			
			------------------------------------------------------------------------------------------------------------------------------------------------------------------
			----CLEU DeBuff Timer
			------------------------------------------------------------------------------------------------------------------------------------------------------------------

			------------------------------------------------------------------------------------------------------------------------------------------------------------------
			----Two Debuff Conditions
			------------------------------------------------------------------------------------------------------------------------------------------------------------------
			-----------------------------------------------------------------------------------------------------------------
			--[[Icy Veins Stacks for Slick Ice
			-----------------------------------------------------------------------------------------------------------------
			if spellId == 12472 then
				for i = 1, 40 do
					local _, _, c, _, d, e, _, _, _, s = UnitAura(uid, i, "HELPFUL")
					if not s then break end
					if s == 382148 then
						count = c
					end
				end
			end
			]]
			-----------------------------------------------------------------------------------------------------------------------------------------------------------------
			--Icon Change
			-----------------------------------------------------------------------------------------------------------------------------------------------------------------
			if spellId == 387636 then --Soulburn: Healthstone
				icon = 538745
			end

			buffFrame.icon:SetTexture(icon);
			buffFrame.icon:SetDesaturated(nil) --Destaurate Icon
			buffFrame.icon:SetVertexColor(1, 1, 1);
			buffFrame.icon:SetTexCoord(0.01, .99, 0.01, .99)
			buffFrame.SpellId = spellId

			buffTooltip(buffFrame, uid, buffId, cleuSpell)
			buffCount(buffFrame, count, backCount)

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
			buffFrame:SetID(j);
			local startTime = expirationTime - duration;
			if expirationTime - startTime > 60 then
				CooldownFrame_Clear(buffFrame.cooldown);
			else
				CooldownFrame_Set(buffFrame.cooldown, startTime, duration, true);
			end
			buffFrame:SetSize(overlaySize*1,overlaySize*1);
			buffFrame:Show();
			
		else
			local buffFrame = scf.buffFrames[j];
			if buffFrame then
				buffFrame:SetSize(overlaySize*1,overlaySize*1);
				buffFrame:Hide()
				if j == 8 then --BuffOverlay Right 
					scf.buffFrames[4]:ClearAllPoints() --Cleares SMall Buff Icon Positions
					scf.buffFrames[4]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5.5, -6.5)
				end
			end
		end
	index = nil; buff = nil; backCount= nil
	end
end

function DebuffFilter:buffsRow2(scf, uid)
	local f = scf.f
	local frameWidth, frameHeight = f:GetSize()
	local componentScale = min(frameHeight / NATIVE_UNIT_FRAME_HEIGHT, frameWidth / NATIVE_UNIT_FRAME_WIDTH);
	local overlaySize = 11 * componentScale
	local filter = "HELPFUL"
	local Z
	for j = 10, 12 do --buffRow1 is J == 1, 2, 3
		local index, buff, backCount = buffFilterplayer(uid, j, filter)
		if index then
			local buffId = index
			local _, icon, count, _, duration, expirationTime, _, _, _, _ = UnitBuff(uid, index, filter);
			local buffFrame = scf.buffFrames[j]
			-----------------------------------------------------------------------------------------------------------------
			--Growing Buffs
			-----------------------------------------------------------------------------------------------------------------
			if j == 10 or j == 11 or j == 12 then
				if not Z then
					scf.buffFrames[10]:Hide();scf.buffFrames[11]:Hide();scf.buffFrames[12]:Hide();
					j = 10
					buffFrame = scf.buffFrames[j]; Z = j
				else
					buffFrame = scf.buffFrames[Z+1]
					Z = Z + 1
				end
			end
			buffFrame.icon:SetTexture(icon);
			buffFrame.icon:SetDesaturated(nil) --Destaurate Icon
			buffFrame.icon:SetVertexColor(1, 1, 1);
			buffFrame.icon:SetTexCoord(0.01, .99, 0.01, .99)
			buffTooltip(buffFrame, uid, buffId, cleuSpell)
			buffCount(buffFrame, count, backCount)
			buffFrame:SetID(j);
			local startTime = expirationTime - duration;
			if expirationTime  - startTime > 61 then
				CooldownFrame_Clear(buffFrame.cooldown);
			else
				CooldownFrame_Set(buffFrame.cooldown, startTime, duration, true);
			end
			buffFrame:SetSize(overlaySize*BUFF_SIZE,overlaySize*BUFF_SIZE);
			buffFrame:Show();
		else
			local buffFrame = scf.buffFrames[j];
			if buffFrame then
				buffFrame:SetSize(overlaySize*BUFF_SIZE,overlaySize*BUFF_SIZE);
				buffFrame:Hide()
			end
		end
	index = nil; buff = nil; backCount= nil
	end
end

function DebuffFilter:buffsRow1(scf, uid)
	local f = scf.f
	local frameWidth, frameHeight = f:GetSize()
	local componentScale = min(frameHeight / NATIVE_UNIT_FRAME_HEIGHT, frameWidth / NATIVE_UNIT_FRAME_WIDTH);
	local overlaySize = 11 * componentScale
	local filter = "HELPFUL"
	for j = 1, 3 do --
		local index, buff, backCount
		if j == 1 and UNIT_CLASS == "PRIEST" then
			index, buff, backCount = buffFilter(uid, j, filter)
			if GetSpellInfo(buff) ~= GetSpellInfo(48066) then index = nil end
		elseif j == 1 and UNIT_CLASS == "MAGE" then
			index, buff, backCount = buffFilter(uid, j, filter)
			if GetSpellInfo(buff) == GetSpellInfo(48066) then index = nil end
		else
			index, buff, backCount = buffFilterplayer(uid, j, filter)
		end
		if index then
			local buffId = index
			local _, icon, count, _, duration, expirationTime, _, _, _, _ = UnitBuff(uid, index, filter);
			local buffFrame = scf.buffFrames[j]
			buffFrame.icon:SetTexture(icon);
			buffFrame.icon:SetDesaturated(nil) --Destaurate Icon
			buffFrame.icon:SetVertexColor(1, 1, 1);
			buffFrame.icon:SetTexCoord(0.01, .99, 0.01, .99)
			buffTooltip(buffFrame, uid, buffId, cleuSpell)
			buffCount(buffFrame, count, backCount)
			buffFrame:SetID(j);
			local startTime = expirationTime - duration;
			if expirationTime  - startTime > 61 then
				CooldownFrame_Clear(buffFrame.cooldown);
			else
				CooldownFrame_Set(buffFrame.cooldown, startTime, duration, true);
			end
			buffFrame:SetSize(overlaySize*BUFF_SIZE,overlaySize*BUFF_SIZE);
			if j == 1 and UNIT_CLASS == "PRIEST" then
				scf.buffFrames[14]:Hide()
			end
			buffFrame:Show();
		else
			local buffFrame = scf.buffFrames[j];
			if buffFrame then
				buffFrame:SetSize(overlaySize*BUFF_SIZE,overlaySize*BUFF_SIZE);
				buffFrame:Hide()
				if j == 1 and UNIT_CLASS == "PRIEST" then
					DebuffFilter:weakenedSoul(scf, uid)
				end
			end
		end
	index = nil; buff = nil; backCount= nil
	end
end

function DebuffFilter:magicCount(scf, uid)
	local f = scf.f
	local frameWidth, frameHeight = f:GetSize()
	local componentScale = min(frameHeight / NATIVE_UNIT_FRAME_HEIGHT, frameWidth / NATIVE_UNIT_FRAME_WIDTH);
	local overlaySize = 11 * componentScale
	local filter = "HELPFUL"
	local j = 13
		local count = magicFilter(uid, j, filter)
		if count > 0 then
			local buffFrame = scf.buffFrames[j]
			buffFrame:SetID(j);
			if ( count > 0 ) then
				local countText = count;
				if ( count >= 100 ) then
					countText = BUFF_STACKS_OVERFLOW;
				end
					buffFrame.count:Show();
					buffFrame.count:SetText(countText);
			else
				buffFrame.count:Hide();
			end
			buffFrame:SetSize(overlaySize*BUFF_SIZE,overlaySize*BUFF_SIZE);
			if count == 1 then
				buffFrame.count:SetTextColor(1, 0 ,0, 1)
			elseif count == 3 or count == 4 then 
				buffFrame.count:SetTextColor(1, 1 ,0, 1)
			else
				buffFrame.count:SetTextColor(1, 1 ,1, 1)
			end
			buffFrame:Show();
		else
			local buffFrame = scf.buffFrames[j];
			if buffFrame then
				buffFrame:SetSize(overlaySize*BUFF_SIZE,overlaySize*BUFF_SIZE);
				buffFrame:Hide()
			end
		end
	index = nil; buff = nil; backCount= nil
end

function DebuffFilter:weakenedSoul(scf, uid, hide_only)
	local f = scf.f
	local frameWidth, frameHeight = f:GetSize()
	local componentScale = min(frameHeight / NATIVE_UNIT_FRAME_HEIGHT, frameWidth / NATIVE_UNIT_FRAME_WIDTH);
	local overlaySize = 11 * componentScale
	local filter = "HARMFUL"
	for j = 14, 14 do --buffRow1 is J == 1, 2, 3
		local index, buff, backCount = debuffFilter(uid, j, filter)
		if index then
			local buffId = index
			local _, icon, count, debuffType, duration, expirationTime, _, _, _, _ = UnitDebuff(uid, index, filter);
			local buffFrame = scf.buffFrames[j]
			buffFrame.icon:SetTexture(icon);
			buffFrame.icon:SetDesaturated(nil) --Destaurate Icon
			local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
			buffFrame.border:SetVertexColor(color.r, color.g, color.b);
			--buffFrame.icon:SetTexCoord(0.01, .99, 0.01, .99)
			debuffTooltip(buffFrame, uid, buffId, cleuSpell)
			buffCount(buffFrame, count, backCount)
			buffFrame:SetID(j);
			local startTime = expirationTime - duration;
			if expirationTime  - startTime > 61 then
				CooldownFrame_Clear(buffFrame.cooldown);
			else
				CooldownFrame_Set(buffFrame.cooldown, startTime, duration, true);
			end
			buffFrame:SetSize(overlaySize*BUFF_SIZE*.95,overlaySize*BUFF_SIZE*.95);
			if not hide_only then 
				buffFrame:Show();
			end
		else
			local buffFrame = scf.buffFrames[j];
			if buffFrame then
				buffFrame:SetSize(overlaySize*BUFF_SIZE,overlaySize*BUFF_SIZE);
				buffFrame:Hide()
			end
		end
	index = nil; buff = nil; backCount= nil
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Filters Buff and Debuffs to Correct Loops
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



local function DebuffFilter_UpdateAuras(scf, unitAuraUpdateInfo)

	local debuffsChanged = false;
	local buffsRow1 = false;
	local buffsRow2 = false;
	local buffsBOR = false;
	local buffsBOL = false;
	local buffsBOC = false;
	local magicCount = false;
	local weakenedSoul = false;

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
		--(scf.displayedUnit, "HELPFUL", nil, HandleAura, true)
		--AuraUtil.ForEachAura(scf.displayedUnit, "HARMFUL", nil, HandleAura, true)
		debuffsChanged = true;
		buffsRow1 = true;
		buffsRow2 = true;
		buffsBOR = true;
		buffsBOL = true;
		buffsBOC = true;
		magicCount = true;
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

	if buffsRow1 then
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
		DebuffFilter_UpdateAuras(self)
	elseif ( event == 'ZONE_CHANGED_NEW_AREA' ) then
		DebuffFilter_UpdateAuras(self)
	else
		local unitMatches = arg1 == self.unit or arg1 == self.displayedUnit
		if ( unitMatches ) then
			if ( event == 'UNIT_AURA' ) then
				local unitAuraUpdateInfo = arg2
				DebuffFilter_UpdateAuras(self, unitAuraUpdateInfo)
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
				DebuffFilter_UpdateAuras(self)
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
	DebuffFilter_UpdateAuras(scf)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Finding Used Frames and Unused Fames from API
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function  DebuffFilter:findFrames(forced, event)
	print("DebufF_Filter_Frames: "..event)
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
end)

hooksecurefunc("CompactRaidFrameContainer_SetFlowFilterFunction", function(flowFilterFunc)
	DebuffFilter:findFrames(false,"CompactRaidFrameContainer_SetFlowFilterFunction")
end)

hooksecurefunc("CompactRaidFrameContainer_SetGroupFilterFunction", function(groupFilterFunc)
	DebuffFilter:findFrames(false, "CompactRaidFrameContainer_SetGroupFilterFunction")
end)

hooksecurefunc("CompactRaidFrameContainer_SetFlowSortFunction", function(flowSortFunc)
	DebuffFilter:findFrames(false, "CompactRaidFrameContainer_SetFlowSortFunction")
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
		local className, classFilename, classId = UnitClass("player")
		UNIT_CLASS = classFilename
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
