local wm = GetWindowManager()

if AutoRecruit == nil then AutoRecruit = {} end
local AR = AutoRecruit

-- INFO WINDOW

function AR.MakeWindow()
	AR.window = wm:CreateTopLevelWindow("ARWindow")
	local win = AR.window
	win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AR.settings.x, AR.settings.y)
	win:SetMovable(true)
	win:SetHidden(not AR.settings.shown)
	win:SetMouseEnabled(true)
	win:SetClampedToScreen(true)
	win:SetDimensions(0,0)
	win:SetResizeToFitDescendents(true)
	win:SetHandler("OnMoveStop", function()
		AR.settings.x = win:GetLeft()
		AR.settings.y = win:GetTop()
	end)

	win.title = wm:CreateControl("ARTitle", win, CT_LABEL)
	win.title:SetAnchor(TOPLEFT, win, TOPLEFT, 8, 5)
	win.title:SetFont("ZoFontWinH4")
	win.title:SetColor(ZO_ColorDef.HexToFloats("6C00FF"))
	win.title:SetStyleColor(0,0,0,1)
	win.title:SetText("Auto Recruit - ")
	win.title:SetHidden(false)

	win.text = wm:CreateControl("ARZone", win, CT_LABEL)
	win.text:SetAnchor(TOPLEFT, win.title, TOPRIGHT, 5, 0)
	win.text:SetFont("ZoFontGameMedium")
	win.text:SetColor(1, 1, 1, 1)
	win.text:SetStyleColor(0,0,0,1)
	win.text:SetText("-")

	win.backdrop = wm:CreateControl(nil, win, CT_BACKDROP) --BackdropControl#BackdropControl
	win.backdrop:SetAnchor(TOPLEFT, win.title, TOPLEFT, -6, -4)
	win.backdrop:SetAnchor(BOTTOMRIGHT, win.text, BOTTOMRIGHT, 6, 4)
	win.backdrop:SetCenterColor(0,0,0,0.75)
	win.backdrop:SetEdgeColor(0,0,0,0)

	win.buttonList = {}
	local cols = 4
	local rows = math.floor((#AR.zones+cols) / cols)
	d("AR.zones count = " .. #AR.zones)
	for i = 1, #AR.zones do
		--		local btn = CreateControlFromVirtual("AWBtn" .. i, win, "ZO_DefaultButton")
		local btn = wm:CreateControl("AWBtn" .. i, win, CT_BUTTON)
		btn:SetDimensions(76, 22)
		btn:SetFont('ZoFontGameSmall')
		btn:SetClickSound('Click')
		btn:SetNormalFontColor(0.9,0.87,0.68,1)
		btn:SetMouseOverFontColor(1,0.66,0.2,1)
		btn:SetDisabledFontColor(0.4, 0.8, 0.4, 1)
		btn:SetHorizontalAlignment(0)
		btn:SetVerticalAlignment(1)
		btn:SetText(AR.zones[i].name)
		btn.data = { zoneIndex = i }
		btn:SetHandler('OnClicked',function(_)
			local zoneIndex = btn.data.zoneIndex
			AR.PortToZone(AR.zones[zoneIndex])
		end)

		local y = math.floor((i - 1) / cols) * 22 + 4
		local x = ((i - 1) % cols) * 80 + 2
		btn:SetAnchor(TOPLEFT, win.title, BOTTOMLEFT, x, y)

		table.insert(win.buttonList, btn)
	end

	win.btnBackdrop = wm:CreateControl(nil, win, CT_BACKDROP) --BackdropControl#BackdropControl
	win.btnBackdrop:SetAnchor(TOPLEFT, win.backdrop, BOTTOMLEFT, 0, 0)
	win.btnBackdrop:SetDimensions(80*cols + 6, 22*rows+4)
	win.btnBackdrop:SetCenterColor(0,0,0,0.75)
	win.btnBackdrop:SetEdgeColor(0,0,0,0)
end

function AR.UpdateButtons()
	local guildIndex = AR.GetGuildIndex(AR.GetGuildIDFromName(AR.settings.recruitFor))
	local nextZone = AR.status == 1 and AR.runner:GetNextZone() or nil
	for i = 1, #AR.zones do
		local zone = AR.zones[i]
		local btn = AR.window.buttonList[i]
		if AR.lastPosted[zone.name] then
			local cooldown = AR.settings.adCooldown[guildIndex] * 60 - (GetTimeStamp() - AR.lastPosted[zone.name])
			btn:SetEnabled(cooldown < 10)
		else
			AR.window.buttonList[i]:SetEnabled(true)
		end
		local col = "AAAAAA"
		if zone == nextZone then
			col = "FFFFFF" --"9DA2FF"
		elseif zone.house then
			col = "BBEEFF"
		elseif zone.players then
			col = "E5DAB0"
		end
		btn:SetNormalFontColor(ZO_ColorDef.HexToFloats(col))
	end
end

function AR.OnCompassChanged(show)
	AR.window:SetHidden(not AR.settings.shown or not show)
end

function AR.AddCompassFrameHandlers()
	if ZO_CompassFrame:IsHandlerSet("OnShow") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnShow")
		ZO_CompassFrame:SetHandler("OnShow", function(...) oldHandler(...) AR.OnCompassChanged(true) end)
	else
		ZO_CompassFrame:SetHandler("OnShow", function(...) AR.OnCompassChanged(true) end)
	end
	if ZO_CompassFrame:IsHandlerSet("OnHide") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnHide")
		ZO_CompassFrame:SetHandler("OnHide", function(...) oldHandler(...) AR.OnCompassChanged(false) end)
	else
		ZO_CompassFrame:SetHandler("OnHide", function(...) AR.OnCompassChanged(false) end)
	end
end

function AR.PopulateWindow(text, active)
	if AR.window == nil then
		AR.MakeWindow()
		AR.AddCompassFrameHandlers()
	end

	AR.window.text:SetText(text)
	AR.OnCompassChanged(not ZO_CompassFrame:IsHidden())
	AR.window.backdrop:SetHidden(not active)
	AR.window.title:SetColor(ZO_ColorDef.HexToFloats(active and "9E33FF" or "6C00FF"))
end

local function getActivityMessage()
	if AR.status == 2 and AR.settings.keepPorting then
		local delay = AR.runner:GetNextRoundDelay()
		if delay>120 then
			return "Starting another loop in " .. math.floor(delay/60) .. " minutes...", true
		elseif delay>60 then
			return "Starting another loop in ~1 minute...", true
		elseif delay>5 then
			return "Starting another loop in " .. delay .. " seconds...", true
		else
			return "Starting another loop...", true
		end
	elseif AR.status == 2 then
		return "Auto-Port finished", false
	elseif AR.status == 1 then
		local s = zo_strformat("Auto-Port <<1>>/<<2>>", AR.runner:GetProgress(), #AR.zones)
		if AR.portingTo then
			s = s .. zo_strformat(" - |c9DA2FFporting to <<1>>|r", AR.portingTo)
		elseif ZO_ChatWindowTextEntryEditBox:GetText() == AR.settings.ad[AR.GetGuildIndex(AR.GetGuildIDFromName(AR.settings.recruitFor))] then
			s = s .. " - |cFAD20Ewaiting to post|r"
		end
		return s, true
	end
	return nil, false
end

function AR.RefreshWindow()
	local text, active = getActivityMessage()
	local recruitFor = AR.settings.recruitFor
	if AR.settings.showPending then
		local pending = GetGuildFinderNumGuildApplications(AR.GetGuildIDFromName(AR.settings.recruitFor))
		if pending > 0 then
			recruitFor = recruitFor .. " |c66ff66(" .. pending
			recruitFor = recruitFor .. (pending > 1 and " applications pending)|r" or " application pending)|r")
		end
	end

	if text then
		text = recruitFor .. " - " .. text
		if AR.settings.whisperEnabled	then
			text = text .. "; whisper enabled"
		end
	elseif AR.settings.whisperEnabled	then
		text = recruitFor .. " whisper enabled"
	else
		text = "|c999999" .. recruitFor .. "|r"
	end

	AR.PopulateWindow(text, active)

	AR.UpdateButtons()
end
