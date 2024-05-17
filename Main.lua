-- Author      : Akkiowar
-- Create Date : 5/11/2024 4:57:06 PM

local playerClass = {}
local newPlayers = {}

local playerFrame = CreateFrame("Frame", "PlayerFrame", UIParent, "BackdropTemplate")
playerFrame:Hide()
playerFrame:SetMovable(true)
playerFrame:RegisterForDrag("LeftButton")
playerFrame:SetSize(400, 300)  -- Set the size of the frame
playerFrame:SetPoint("CENTER") -- Position the frame at the center of the screen
playerFrame:EnableMouse(true)
playerFrame:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)
playerFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

local closeButton = CreateFrame("Button", "MyAddonCloseButton", playerFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", playerFrame, "TOPRIGHT", 0, 20)

playerFrame:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 32,
	insets = { left = 11, right = 12, top = 12, bottom = 11 }
}) -- Set the backdrop for the frame	

local scrollFrame = CreateFrame("ScrollFrame", "PlayerScrollFrame", playerFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -10)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)


---@class PlayerContentFrame : Frame
local contentFrame = CreateFrame("Frame", "PlayerContentFrame", scrollFrame, "BackdropTemplate")
contentFrame:SetSize(390, 380)
contentFrame:SetPoint("TOPLEFT", playerFrame, "TOPLEFT", 20, -20)
scrollFrame:SetScrollChild(contentFrame)
contentFrame.entries = {} -- Initialize entries as an empty table	


-- Function to clear all player entries from the content frame
local function ClearPlayerEntries()
	for i, entry in ipairs(contentFrame.entries) do
		entry.playerText:Hide()
		entry.playerPoints:Hide()
		entry.rollText:Hide()
		entry.totalPoints:Hide()
		entry.typeOfRole:Hide()
	end
	contentFrame.entries = {} -- Clear the entries table
	contentFrame:SetHeight(0) -- Reset the height of the content frame
end


local function CreateImportFrame()
	local ImportFrame = CreateFrame("Frame", "ImportFrame", UIParent, "BackdropTemplate")
	ImportFrame:SetSize(700, 700)
	ImportFrame:SetPoint("CENTER")
	local closeButton = CreateFrame("Button", "MyAddonCloseButton", ImportFrame, "UIPanelCloseButton")
	closeButton:SetSize(50, 50)
	closeButton:SetPoint("TOPRIGHT", ImportFrame, "TOPRIGHT", -8, -8)

	-- Set backdrop for the frame including color
	ImportFrame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
		backgroundColor = { 0, 0, 0, 0.7 } -- Adjust transparency as needed
	})
	ImportFrame:SetBackdropColor(5, 5, 5, 0.7)
	return ImportFrame
end

local function CreateImportButton(parentFrame)
	local importButton = CreateFrame("Button", "ImportButton", parentFrame, "UIPanelButtonTemplate")
	importButton:SetSize(100, 30)
	importButton:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -20, 10)
	importButton:SetText("Import")
	return importButton
end

local function CreateImportEditBox(parentFrame)
	local padding = 20

	local ImportEditBox = CreateFrame("EditBox", "ImportFrameEditBox", parentFrame, "BackdropTemplate")
	ImportEditBox:SetSize(700 - (padding * 2), 700 - (padding * 2))
	ImportEditBox:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", padding, -padding)
	ImportEditBox:SetPoint("BOTTOM", parentFrame, "BOTTOMLEFT", -padding, 40)
	ImportEditBox:SetMultiLine(true)
	ImportEditBox:SetFontObject(ChatFontNormal)
	ImportEditBox:SetAutoFocus(false)
	ImportEditBox:SetTextInsets(padding, padding, padding, padding)
	ImportEditBox:SetScript("OnEscapePressed", function() ImportEditBox:ClearFocus() end)

	local fontObject = CreateFont("MyFont")
	fontObject:SetFont(ChatFontNormal:GetFont(), 14, "")
	fontObject:SetJustifyH("LEFT")
	ImportEditBox:SetFontObject(fontObject)

	-- Set backdrop for the edit box including color
	ImportEditBox:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
		backgroundColor = { 0, 0, 0, 0.5 } -- Adjust transparency as needed
	})
	ImportEditBox:SetBackdropColor(0, 0, 0, 1)
	return ImportEditBox
end

function playerClass:new(name, ItemName, bonusPoints)
	local newPlayer = {
		name = name,
		ItemName = ItemName,
		bonusPoints = bonusPoints
	}

	function newPlayer:getName()
		return self.name
	end

	function newPlayer:getBonusPoints()
		return self.bonusPoints
	end

	function newPlayer:getItemName()
		return self.ItemName
	end

	return newPlayer
end

local function GetImportedText(self)
	return self:GetText()
end

local function ImportHandler(ImportEditBox)
	local testText = GetImportedText(ImportEditBox)
	newPlayers = ParseMultiLineString(testText)

	for i, item in ipairs(newPlayers) do
		print("Imported player Number " .. i .. ":")
		print("Name: " .. item:getName())
		print("Item ID: " .. item:getItemName())
		print("Bonus Points: " .. item:getBonusPoints())
	end
end

function ParseMultiLineString(str)
	local players = {}

	-- Iterate over each line in the input string
	for line in str:gmatch("[^\r\n]+") do
		local name, itemName, points = line:match("([^,]+),%s*([^,]+),%s*(%d+)")

		-- Check if all parts were extracted
		if name and itemName and points then
			local newPlayer = playerClass:new(name, itemName, tonumber(points))
			table.insert(players, newPlayer)
		else
			print("Parsing failed for line:", line)
		end
	end

	return players
end

local function CreateImportUI()
	ImportFrame = CreateImportFrame() --globalScope
	local importButton = CreateImportButton(ImportFrame)
	local ImportEditBox = CreateImportEditBox(ImportFrame)

	importButton:SetScript("OnClick", function() ImportHandler(ImportEditBox) end)
end

local function findTextInSquareBrackets(str)
	local pattern = "%[(.-)%]"
	local matchingValue = ""

	-- Use string.gmatch to iterate over all occurrences of the pattern in the string
	for match in str:gmatch(pattern) do
		matchingValue = match
	end

	return matchingValue
end

local function findPlayerByItemName(players, itemName)
	local foundPlayersWithSRs = {}
	for i, player in ipairs(players) do
		if player:getItemName() == itemName then
			table.insert(foundPlayersWithSRs, player)
		end
	end
	if next(foundPlayersWithSRs) ~= nil then
		return foundPlayersWithSRs
	end
end


local function AnnouncePlayerWithPointsToRaid(message)
	SendChatMessage(message, "RAID")
end

local function SetRollFrame()
	for _, entry in ipairs(contentFrame.entries) do
		if entry.playerText then
			entry.playerText:Show()
			entry.playerPoints:Show()
		end
		if entry.rollText then
			entry.rollText:Show()
			entry.playerPoints:Show()
			entry.typeOfRole:Show()
		end
	end
end

-- Function to add a player entry to the content frame
local function AddPlayerEntry(players, rollData, r, g, b)
	-- Create headers for player name, points, roll, and total
	local playerNameHeader = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	playerNameHeader:SetText("Player Name")
	playerNameHeader:SetPoint("TOPLEFT", 0, 0)

	local playerPointsHeader = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	playerPointsHeader:SetText("Points")
	playerPointsHeader:SetPoint("TOPLEFT", 100, 0)

	local rollHeader = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	rollHeader:SetText("Roll")
	rollHeader:SetPoint("TOPLEFT", 150, 0)

	local totalPointsHeader = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	totalPointsHeader:SetText("Total")
	totalPointsHeader:SetPoint("TOPLEFT", 200, 0)

	local typeOfRollHeader = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	typeOfRollHeader:SetText("MS/OS")
	typeOfRollHeader:SetPoint("TOPLEFT", 250, 0)

	local yOffset = -20

	for _, player in ipairs(players) do
		print("Adding player entry for:", player:getName())
		print(player.getName)
		local entry = {} -- Create a table to hold playerText and playerPoints
		if rollData and rollData.playerName == player:getName() then
			--player names
			entry.playerText = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			entry.playerText:SetText(player:getName())
			entry.playerText:SetPoint("TOPLEFT", 0, yOffset - ((#contentFrame.entries * 20) or 20))
			entry.playerText:SetFont("Fonts\\FRIZQT__.TTF", 12) -- Set font size to 12
			entry.playerText:SetTextColor(r, g, b)     -- Set text color to white (RGB values)

			--player points
			entry.playerPoints = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			entry.playerPoints:SetText(player:getBonusPoints())
			entry.playerPoints:SetPoint("TOPLEFT", 100, yOffset - ((#contentFrame.entries * 20) or 20))


			entry.rollText = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			entry.rollText:SetText(rollData.roll or "No roll")
			entry.rollText:SetPoint("TOPLEFT", 150, yOffset - ((#contentFrame.entries * 20) or 20))

			--Add total points calculations here aswell later
			local totalPoints = rollData.roll + player:getBonusPoints()
			entry.totalPoints = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			entry.totalPoints:SetText(totalPoints)
			entry.totalPoints:SetPoint("TOPLEFT", 200, yOffset - ((#contentFrame.entries * 20) or 20))

			--MS / OS
			entry.typeOfRole = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			entry.typeOfRole:SetText(rollData.msOs)
			entry.typeOfRole:SetPoint("TOPLEFT", 250, yOffset - ((#contentFrame.entries * 20) or 20))

			table.insert(contentFrame.entries, entry) -- Store the entry table for future reference
		end
	end

	contentFrame:SetHeight(#contentFrame.entries * 20) -- Adjust the height of the content frame
	playerFrame:Show()
	SetRollFrame()
end

local processedMessages = {}

-- Function to clear old entries from the processedMessages table periodically
local function clearProcessedMessages()
	local currentTime = GetTime()
	for k, timestamp in pairs(processedMessages) do
		if currentTime - timestamp > 20 then
			processedMessages[k] = nil
		end
	end
	-- Schedule the function to run again after a certain period
	--C_Timer.After(60, clearProcessedMessages)
end


-- Function to handle chat messages
local function OnChatMessage(self, event, message, sender, _, _, _, _, _, _, _, _, _, guid)
	local currentTime = GetTime()     -- Get the current time in seconds
	local messageKey = message .. sender -- Create a unique key using message content and sender

	-- Check if the message has already been processed
	if processedMessages[messageKey] then
		return
	end

	-- Mark this message as processed with the current timestamp
	processedMessages[messageKey] = currentTime

	-- Filter chat messages here based on requirements
	if string.find(message, "You have 30 seconds") then
		print('find roll is being called')
		local rolledItem = findTextInSquareBrackets(message)
		print(rolledItem)
		FoundPlayers = findPlayerByItemName(newPlayers, rolledItem)
		print(FoundPlayers)
		if FoundPlayers then
			AnnouncePlayerWithPointsToRaid("--Players that has bonus points on " .. rolledItem .. "--")
			for i, player in ipairs(FoundPlayers) do
				AnnouncePlayerWithPointsToRaid(player:getName() .. " " .. player:getBonusPoints())
			end
			AnnouncePlayerWithPointsToRaid("--END GL ON UR ROLLS--")
		else
			AnnouncePlayerWithPointsToRaid("--No player has points on " .. rolledItem .. "--")
		end
		ClearPlayerEntries()
		clearProcessedMessages()
	end

	local _, _, playerName, roll, minRoll, maxRoll = string.find(message, "(.+) rolls (%d+) %((%d+)%-(%d+)%)")
	if playerName and roll and minRoll and maxRoll then
		-- Get the class color of the player
		local _, playerNameToColour = UnitClass(playerName) -- Note: UnitClass requires the unit name
		local classColor = RAID_CLASS_COLORS[playerNameToColour]
		local r, g, b = classColor.r, classColor.g, classColor.b


		RollData = {
			playerName = playerName,
			roll = tonumber(roll),
			minRoll = tonumber(minRoll),
			maxRoll = tonumber(maxRoll),
			msOs = tonumber(maxRoll) < 100 and "OS" or "MS"
		}
		if FoundPlayers and RollData then
			AddPlayerEntry(FoundPlayers, RollData, r, g, b)
			playerFrame:Show()
			clearProcessedMessages()
			RollData = nil
			print("AddPlayerEntry fired")
		else
			print("FoundPlayers or RollData not found")
		end
	end
end

-- Register for chat events
--ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", OnChatMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", OnChatMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", OnChatMessage)
--local ChatEventFrame = CreateFrame("Frame")
-- Set up event handler for the CHAT_MSG_CHANNEL event
--ChatEventFrame:SetScript("OnEvent", OnChatMessage)
-- Add more chat events as needed


local function CloseFrame()
	ImportFrame:Hide()
end
SLASH_IMPORT1 = '/atimport'
SLASH_ATCLOSE1 = '/atclose'

SlashCmdList["ATCLOSE"] = CloseFrame
SlashCmdList['IMPORT'] = CreateImportUI
