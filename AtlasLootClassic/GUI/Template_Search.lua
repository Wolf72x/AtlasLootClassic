local ALName, ALPrivate = ...
local AtlasLoot = _G.AtlasLoot
local GUI = AtlasLoot.GUI




local function InputBoxInstructions_OnTextChanged(self)
  if self:GetText() == "" then
    self.Instructions:Show();
  else
    self.Instructions:Hide();
  end
end

local function InputBoxInstructions_UpdateColorForEnabledState(self, color)
  if color then
    self:SetTextColor(color.r, color.g, color.b, color.a);
  end
end

local function InputBoxInstructions_OnDisable(self)
  InputBoxInstructions_UpdateColorForEnabledState(self, self.disabledColor);
end

local function InputBoxInstructions_OnEnable(self)
  InputBoxInstructions_UpdateColorForEnabledState(self, self.enabledColor);
end

local function SearchBoxTemplate_OnEditFocusLost(self)
  if ( self:GetText() == "" ) then
    self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
    self.clearButton:Hide();
  end
end

local function SearchBoxTemplate_OnEditFocusGained(self)
  self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
  self.clearButton:Show();
end

local function SearchBoxTemplate_OnTextChanged(self)
  if ( not self:HasFocus() and self:GetText() == "" ) then
    self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
    self.clearButton:Hide();
  else
    self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
    self.clearButton:Show();
  end
  InputBoxInstructions_OnTextChanged(self);
end

local function SearchBoxTemplate_ClearText(self)
  self:SetText("");
  self:ClearFocus();
end

local function SearchBoxTemplateClearButton_OnClick(self)
  PlaySound("igMainMenuOptionCheckBoxOn");
  SearchBoxTemplate_ClearText(self:GetParent());
end

local function GetParentName(frame)
  return frame:GetName() or frame
end

GUI.XMLTemplates = {
  -- InputBoxTemplate (Retail 11.1.7 (61967))
  ["InputBoxTemplate"] = function(frame)
    frame:EnableMouse(true)
    -- Left Texture
    local left = frame:CreateTexture(nil, "BACKGROUND")
    left:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\CommonSearch")
    left:SetSize(8, 20)
    left:SetPoint("LEFT", frame, "LEFT", -5, 0)
    left:SetTexCoord(0.886719, 0.949219, 0.335938, 0.648438)
    frame.Left = left
    -- Right Texture
    local right = frame:CreateTexture(nil, "BACKGROUND")
    right:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\CommonSearch")
    right:SetSize(8, 20)
    right:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    right:SetTexCoord(0.00390625, 0.0664062, 0.664062, 0.976562)
    frame.Right = right
    -- Middle Texture (zwischen Left und Right)
    local middle = frame:CreateTexture(nil, "BACKGROUND")
    middle:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\CommonSearch")
    middle:SetSize(10, 20)
    middle:SetTexCoord(0.00390625, 0.878906, 0.335938, 0.648438)
    middle:SetPoint("LEFT", left, "RIGHT")
    middle:SetPoint("RIGHT", right, "LEFT")
    frame.Middle = middle
    -- FontString
    frame:SetFontObject("ChatFontNormal")
    -- Scripts
    frame:SetScript("OnEscapePressed", function(self)
      EditBox_ClearFocus(self)
    end)
    frame:SetScript("OnEditFocusLost", function(self)
      EditBox_ClearHighlight(self)
    end)
    frame:SetScript("OnEditFocusGained", function(self)
      EditBox_HighlightText(self)
    end)
  end,

  -- InputBoxInstructionsTemplate (Retail 11.1.7 (61967))
  ["InputBoxInstructionsTemplate"] = function(frame)
    GUI.XMLTemplates["InputBoxTemplate"](frame) -- Inherits from InputBoxTemplate
    --[[ Optional
    frame.disabledColor = { r = 0.35, g = 0.35, b = 0.35, a = 1 }
    frame.enabledColor = { r = 1, g = 1, b = 1, a = 1 }
    ]]
    -- Instructions FontString
    local instructions = frame:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    instructions:SetJustifyH("LEFT")
    instructions:SetJustifyV("MIDDLE")
    instructions:SetAllPoints(frame)
    instructions:SetTextColor(0.35, 0.35, 0.35)
    frame.Instructions = instructions

    -- Skripts
    frame:SetScript("OnTextChanged", InputBoxInstructions_OnTextChanged)
    frame:SetScript("OnDisable", InputBoxInstructions_OnDisable)
    frame:SetScript("OnEnable", InputBoxInstructions_OnEnable)

    -- FontObject
    frame:SetFontObject("GameFontHighlightSmall")
  end,

  -- SearchBoxTemplate (Retail 11.1.7 (61967))
  ["SearchBoxTemplate"] = function(frame)
    GUI.XMLTemplates["InputBoxInstructionsTemplate"](frame) -- Inherits from InputBoxInstructionsTemplate
    frame:SetAutoFocus(false)
    frame:SetTextInsets(16, 20, 0, 0);
    frame.instructionText = SEARCH
    frame.Instructions:SetText(frame.instructionText);
    frame.Instructions:ClearAllPoints();
    frame.Instructions:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, 0);
    frame.Instructions:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 0);
    -- Search-Icon
    local searchIcon = frame:CreateTexture(GetParentName(frame) .. "SearchIcon", "OVERLAY")
    searchIcon:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\CommonSearch")
    searchIcon:SetSize(10, 10)
    searchIcon:SetPoint("LEFT", 1, -1)
    searchIcon:SetTexCoord(0.0742188, 0.167969, 0.664062, 0.851562)
    searchIcon:SetVertexColor(0.6, 0.6, 0.6);
    frame.searchIcon = searchIcon
    -- Clear-Button
    local clearButton = CreateFrame("Button", GetParentName(frame) .. "ClearButton", frame)
    clearButton:SetSize(17, 17)
    clearButton:SetPoint("RIGHT", -3, 0)
    clearButton:Hide()
    frame.clearButton = clearButton
    local texture = clearButton:CreateTexture(nil, "ARTWORK")
    texture:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\CommonSearch")
    texture:SetAlpha(0.5)
    texture:SetSize(10, 10)
    texture:SetPoint("TOPLEFT", 3, -3)
    texture:SetTexCoord(0.175781, 0.253906, 0.664062, 0.820312)
    clearButton.texture = texture
    -- Clear-Button Scripts
    clearButton:SetScript("OnEnter", function(self)
      self.texture:SetAlpha(1.0)
    end)
    clearButton:SetScript("OnLeave", function(self)
      self.texture:SetAlpha(0.5)
    end)
    clearButton:SetScript("OnMouseDown", function(self)
      if self:IsEnabled() then
        self.texture:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4)
      end
    end)
    clearButton:SetScript("OnMouseUp", function(self)
      self.texture:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3)
    end)
    clearButton:SetScript("OnClick", SearchBoxTemplateClearButton_OnClick)
    -- EditBox Scripts
    frame:SetScript("OnEscapePressed", EditBox_ClearFocus)
    frame:SetScript("OnEnterPressed", EditBox_ClearFocus)
    frame:SetScript("OnEditFocusLost", SearchBoxTemplate_OnEditFocusLost)
    frame:SetScript("OnEditFocusGained", SearchBoxTemplate_OnEditFocusGained)
    frame:SetScript("OnTextChanged", SearchBoxTemplate_OnTextChanged)
  end,

}

function GUI.CreateSearch(frame)
    return GUI.XMLTemplates["SearchBoxTemplate"](frame)
end