local ALName, ALPrivate = ...

local _G = _G
local AtlasLoot = _G.AtlasLoot
local AL, ALIL = AtlasLoot.Locales, AtlasLoot.IngameLocales
local ClickHandler = AtlasLoot.ClickHandler
local Token = AtlasLoot.Data.Token

local TYPE, ID_INV, ID_ICON, ID_ABILITY, ID_ADDON, ID_CLASS, ID_SLOT, ID_SPECIAL = "Dummy", "INV_", "ICON_", "ABILITY_", "ADDON_", "CLASS_", "SLOT_", "SPECIAL_"
local Dummy = AtlasLoot.Button:AddType(TYPE, ID_INV)
AtlasLoot.Button:DisableDescriptionReplaceForce(TYPE, true)
local Dummy_ID_ICON = AtlasLoot.Button:AddIdentifier(TYPE, ID_ICON)
local Ability_ID_ICON = AtlasLoot.Button:AddIdentifier(TYPE, ID_ABILITY)
local Dummy_ID_ADDON = AtlasLoot.Button:AddIdentifier(TYPE, ID_ADDON)
local Dummy_ID_CLASS = AtlasLoot.Button:AddIdentifier(TYPE, ID_CLASS)
local Dummy_ID_SLOT = AtlasLoot.Button:AddIdentifier(TYPE, ID_SLOT)
local Dummy_ID_SPECIAL = AtlasLoot.Button:AddIdentifier(TYPE, ID_SPECIAL)

-- lua
local tonumber = tonumber
local format, str_match, str_find = string.format, _G.string.match, string.find

-- WoW


local ITEM_DESC_EXTRA_SEP = "%s | %s"
local DUMMY_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local INTERFACE_PATH = "Interface\\Icons\\"


local SLOT_ICONS = {
	CLOTH = "interface\\icons\\inv_fabric_linen_01",
	LEATHER = "interface\\icons\\inv_misc_leatherscrap_02",
	MAIL = "interface\\icons\\inv_chest_chain",
	PLATE = "interface\\icons\\inv_misc_wartornscrap_plate",

	HEAD = "interface\\icons\\inv_helmet_29",
	SHOULDERS = "interface\\icons\\inv_shoulder_09",
	CHEST = "interface\\icons\\inv_chest_cloth_23",
	WRIST = "interface\\icons\\inv_bracer_07",
	HANDS = "interface\\icons\\inv_gauntlets_27",
	WAIST = "interface\\icons\\inv_belt_04",
	LEGS = "interface\\icons\\inv_pants_02",
	FEET = "interface\\icons\\inv_boots_05",

	NECK = "interface\\icons\\inv_jewelry_necklace_08",
	BACK = "interface\\icons\\inv_misc_cape_01",
	FINGER = "interface\\icons\\inv_jewelry_ring_03",
	TRINKET = "interface\\icons\\inv_jewelry_talisman_08",

	WEAPON = "interface\\icons\\inv_sword_04",
	OFFHAND = "interface\\icons\\inv_misc_lantern_01",

	TABARD = "interface\\icons\\inv_shirt_guildtabard_01",
	SHIRT = "interface\\icons\\inv_shirt_05",
}

local ACHIEVEMENT_SEARCH_STRING = "ac(%d+)"
local SPECIAL_ICONS = {
	ACHIEVEMENT = function(button)	-- gold ac icon
	
		button.icon:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-ACHIEVEMENT-SHIELDS-NOPOINTS.BLP")
		local isCompleted = true
		if button.Extra then
			local tokenData = Token.GetTokenData(button.Extra)
			if tokenData then
				-- check if all ac's are completed
				for i, entry in ipairs(tokenData) do
					if type(entry) == "string" and str_find(entry, ACHIEVEMENT_SEARCH_STRING) then
						local _, name, _, completed = GetAchievementInfo(tonumber(str_match(entry, ACHIEVEMENT_SEARCH_STRING)))
						if not completed then
							isCompleted = false
							break
						end
					end
				end
			end
		end
		if isCompleted then
			button.icon:SetTexCoord(0,0.5,0,1)
		else
			button.icon:SetTexCoord(0.5,1,0,1)
		end
	end,
}


local ItemClickHandler = nil
ClickHandler:Add(
	"Dummy",
	{
		ShowExtraItems = { "LeftButton", "None" },
		types = {
			ShowExtraItems = true,
		},
	},
	{
		{ "ShowExtraItems", AL["Show extra items"], 	AL["Shows extra items (tokens,mats)"] },
	}
)

local function OnInit()
	if not ItemClickHandler then
		ItemClickHandler = ClickHandler:GetHandler("Dummy")
	end
	Dummy.ItemClickHandler = ItemClickHandler
end
AtlasLoot:AddInitFunc(OnInit)

function Dummy.OnSet(button, second)
	if not button then return end
	if second and button.__atlaslootinfo.secType then
		button.secButton.Texture = button.__atlaslootinfo.secType[2]
		button.secButton.Name = button.__atlaslootinfo.Name
		button.secButton.Description = button.__atlaslootinfo.Description
		button.secButton.Extra = button.__atlaslootinfo.Extra
		Dummy.Refresh(button.secButton)
	else
		button.Texture = button.__atlaslootinfo.type[2]
		button.Name = button.__atlaslootinfo.Name
		button.Description = button.__atlaslootinfo.Description
		button.Extra = button.__atlaslootinfo.Extra
		Dummy.Refresh(button)
	end
end

function Dummy.OnClear(button)
	button.Texture = nil
	button.Name = nil
	button.Description = nil
	button.Extra = nil
	if button.icon then
		button.icon:SetTexCoord(0,1,0,1)
	end
	button.secButton.Texture = nil
	button.secButton.Name = nil
	button.secButton.Description = nil
	button.secButton.Extra = nil
	button.secButton.icon:SetTexCoord(0,1,0,1)

	if button.ExtraFrameShown then
		AtlasLoot.Button:ExtraItemFrame_ClearFrame()
		button.ExtraFrameShown = false
	end
end

function Dummy.Refresh(button)
	if button.type == "secButton" then

	else
		button.name:SetText(button.Name)
		local desc
		if button.Extra and Token.IsToken(button.Extra) then
			local tokenDesc = Token.GetTokenDescription(button.Extra)
			if button.Description and Token.TokenTypeAddDescription(button.Extra) then
				desc = format(ITEM_DESC_EXTRA_SEP, button.Description, tokenDesc)
			else
				desc = tokenDesc
			end
		else
			desc = button.Description
		end
		button.extra:SetText(desc)
	end
	button.overlay:Hide()
	if type(button.Texture) == "function" then
		button.Texture(button)
	else
		button.icon:SetTexture(tonumber(button.Texture) or (button.Texture and button.Texture or DUMMY_ICON))
	end
end

function Dummy.OnMouseAction(button, mouseButton)
	if not mouseButton then return end

	mouseButton = ItemClickHandler:Get(mouseButton) or mouseButton
	if mouseButton == "ShowExtraItems" then
		if button.Extra and Token.IsToken(button.Extra) then
			button.ExtraFrameShown = true
			AtlasLoot.Button:ExtraItemFrame_GetFrame(button, Token.GetTokenData(button.Extra))
		end
	end

end

function Dummy.GetStringContent(str)
	return INTERFACE_PATH..ID_INV..str
end

function Dummy_ID_ICON.GetStringContent(str)
	return INTERFACE_PATH..str
end

function Dummy_ID_ADDON.GetStringContent(str)
	return ALPrivate.ICONS_PATH..str
end

function Dummy_ID_CLASS.GetStringContent(str)
	return ALPrivate.CLASS_ICON_PATH[str]
end

function Dummy_ID_SLOT.GetStringContent(str)
	return SLOT_ICONS[str]
end

function Dummy_ID_SPECIAL.GetStringContent(str)
	return SPECIAL_ICONS[str]
end