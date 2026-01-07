-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
local _G = getfenv(0)
local tonumber = _G.tonumber
local ipairs = _G.ipairs

-- ----------------------------------------------------------------------------
-- AddOn namespace.
-- ----------------------------------------------------------------------------
local addonname = ...

local GetAddOnMetadata = _G.GetAddOnMetadata
local addonVersion = GetAddOnMetadata(addonname, "Version")

local versionT = { string.match(addonVersion, "v(%d+)%.(%d+)%.(%d+)%-?(%a*)(%d*)") }
local addonRevision = ""

for k,v in ipairs(versionT) do
	if k < 4 then
		local it = k == 3 and (4 - #v) or (2 - #v)
		for i = 1, it do
			versionT[k] = "0"..versionT[k]
		end
		addonRevision = addonRevision..versionT[k]
	end
end

_G.AtlasLoot = {
	__addonrevision = tonumber(addonRevision),
	__addonversion = versionT[4] == "dev" and "dev-"..(GetTime() or 0) or addonVersion
}

local AddonNameVersion = string.format("%s-%d", addonname, _G.AtlasLoot.__addonrevision)
local MainMT = {
	__tostring = function(self)
		return AddonNameVersion
	end,
}
setmetatable(_G.AtlasLoot, MainMT)

-- DB
AtlasLootClassicDB = {}

-- Translations
_G.AtlasLoot.Locale = {}

-- Init functions
_G.AtlasLoot.Init = {}

-- Data table
_G.AtlasLoot.Data = {}


AtlasLoot.RETAIL_VERSION_NUM  = 99
AtlasLoot.CLASSIC_VERSION_NUM = 1
AtlasLoot.BC_VERSION_NUM      = 2
AtlasLoot.WRATH_VERSION_NUM   = 3

AtlasLoot.IS_CLASSIC = false
AtlasLoot.IS_BC      = false
AtlasLoot.IS_WRATH   = true
AtlasLoot.IS_RETAIL  = false

local CurrentGameVersion = AtlasLoot.WRATH_VERSION_NUM
AtlasLoot.CURRENT_VERSION_NUM = CurrentGameVersion


AtlasLoot.GAME_VERSION_TEXTURES = {
	[AtlasLoot.CLASSIC_VERSION_NUM] = "Interface\\GLUES\\COMMON\\Glues-WoW-Logo",
	[AtlasLoot.BC_VERSION_NUM] = "Interface\\GLUES\\COMMON\\GLUES-WOW-BCLOGO",
	[AtlasLoot.WRATH_VERSION_NUM] = "Interface\\GLUES\\COMMON\\Glues-WOW-WoltkLogo",
}

function AtlasLoot:GetGameVersion()
	return CurrentGameVersion
end

-- equal
function AtlasLoot:GameVersion_EQ(gameVersion, ret, retFalse)
	if CurrentGameVersion == gameVersion then
		return ret or true
	else
		return retFalse
	end
end

-- not equal
function AtlasLoot:GameVersion_NE(gameVersion, ret, retFalse)
	if CurrentGameVersion ~= gameVersion then
		return ret or true
	else
		return retFalse
	end
end

-- not greater then
function AtlasLoot:GameVersion_GT(gameVersion, ret, retFalse)
	if CurrentGameVersion > gameVersion then
		return ret or true
	else
		return retFalse
	end
end

-- not lesser then
function AtlasLoot:GameVersion_LT(gameVersion, ret, retFalse)
	if CurrentGameVersion < gameVersion then
		return ret or true
	else
		return retFalse
	end
end

-- not greater equal
function AtlasLoot:GameVersion_GE(gameVersion, ret, retFalse)
	if CurrentGameVersion >= gameVersion then
		return ret or true
	else
		return retFalse
	end
end

-- not lesser equal
function AtlasLoot:GameVersion_LE(gameVersion, ret, retFalse)
	if CurrentGameVersion <= gameVersion then
		return ret or true
	else
		return retFalse
	end
end
