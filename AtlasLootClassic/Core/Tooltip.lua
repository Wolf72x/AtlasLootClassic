local ALName, ALPrivate = ...

local _G = _G
local AtlasLoot = _G.AtlasLoot
local Tooltip = {}
AtlasLoot.Tooltip = Tooltip
local AL = AtlasLoot.Locales

-- lua
local pairs = _G.pairs
local type = _G.type

-- WoW
local UnitGUID = _G.UnitGUID

local STANDART_TOOLTIP = "AtlasLootTooltip"
local COLOR = "|cFF00ccff%s|r"
local GOLD, SILVER, COPPER = "|T"..ALPrivate.COIN_TEXTURE.GOLD.texture..":0|t "..COLOR, "|T"..ALPrivate.COIN_TEXTURE.SILVER.texture..":0|t "..COLOR, "|T"..ALPrivate.COIN_TEXTURE.COPPER.texture..":0|t "..COLOR

local AtlasLootTooltip = CreateFrame("GameTooltip", "AtlasLootTooltip", UIParent, "GameTooltipTemplate")
AtlasLootTooltip:Hide()
AtlasLootTooltip.shoppingTooltips = {ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3}

local TooltipList = {
	"GameTooltip",
	"AtlasLootTooltip",
}


function Tooltip.GetTooltip()
	return AtlasLoot.db.Tooltip.useGameTooltip and _G["GameTooltip"] or ( _G[AtlasLoot.db.Tooltip.tooltip or STANDART_TOOLTIP] or AtlasLootTooltip )
end

function Tooltip:AddTooltipSource(src)
	TooltipList[#TooltipList+1] = src
end

-- Hook
local HookInitDone = false
local HookTooltipList = {
    "AtlasLootTooltip",
    "GameTooltip",
    "ItemRefTooltip",
    "ShoppingTooltip1",
    "ShoppingTooltip2",
	"ShoppingTooltip3"
}
local HookedTooltipRegister = {}
local FunctionRegister = {}

local function RefreshHooks()
	for i = 1, #HookTooltipList do
		local tt = HookTooltipList[i]
		if not HookedTooltipRegister[tt] then
			HookedTooltipRegister[tt] = {}
		end
		local register = HookedTooltipRegister[tt]
		for script, scriptFunc in pairs(FunctionRegister) do
			if not register[script] then
				register[script] = {}
			end
			for func, state in pairs(scriptFunc) do
				if state and not register[script][func] then
					local hookTT = type(tt) == "string" and _G[tt] or tt
					if hookTT.HookScript then
						hookTT:HookScript(script, func)
						register[script][func] = true
					end
				end
			end
		end
	end
end

-- tt = "GameTooltip" or { "tt1", "tt2", myLocalTT }
function Tooltip:AddTooltipSource(tt, notRefresh)
	if not tt then return end
	if type(tt) == "table" then
		for i = 1, #tt do
			self:AddTooltipSource(tt[i], true)
		end
		if not notRefresh then
			RefreshHooks()
		end
	else
		local count = #HookTooltipList
		for i = 1, #HookTooltipList do
			if HookTooltipList[i] == tt then return end
		end
		HookTooltipList[count + 1] = tt
		if not notRefresh then
			RefreshHooks()
		end
	end
end

function Tooltip:AddHookFunction(script, func)
	if type(func) ~= "function" or not script then return end
	if not FunctionRegister[script] then
		FunctionRegister[script] = {}
	end
	if not FunctionRegister[script][func] then
		FunctionRegister[script][func] = true
		if HookInitDone then
			RefreshHooks()
		end
	end
end

local function HookInit()
	RefreshHooks()
	HookInitDone = true
end
AtlasLoot:AddInitFunc(HookInit)

-- #############################
-- Item ToolTip adds
-- #############################
local WHITE_TEXT = "|cffffffff%s|r"
local TooltipCache = {}

local function OnTooltipSetItem_Hook(self)
    if not AtlasLoot.db.showTooltipInfoGlobal then return end
    local _, item = self:GetItem()
    if not item then return end
	if not TooltipCache[item] then
        TooltipCache[item] = tonumber(strmatch(item, "item:(%d+)"))
    end

    item = TooltipCache[item]

    if item then
		if AtlasLoot.db.showCompanionLearnedInfo and AtlasLoot.Data.Companion.IsCompanion(item) then
			self:AddDoubleLine(AtlasLoot.Data.Companion.GetTypeName(item), AtlasLoot.Data.Companion.GetCollectedString(item))
		end
		if AtlasLoot.db.showIDsInTT then
			self:AddDoubleLine(AL["ItemID:"], format(WHITE_TEXT, item))
		end
		if AtlasLoot.db.showItemLvlInTT then
			local itemName, itemLink, itemQuality, itemLevel = GetItemInfo(item)
			if itemLevel and itemLevel > 0 then
				self:AddDoubleLine(AL["Item level:"], format(WHITE_TEXT, itemLevel))
			end
		end
    end
end
Tooltip:AddHookFunction("OnTooltipSetItem", OnTooltipSetItem_Hook)

