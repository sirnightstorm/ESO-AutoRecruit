local wm = GetWindowManager()

if AutoRecruit == nil then AutoRecruit = {} end
local AR = AutoRecruit


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
	win.backdrop:SetEdgeColor(0,0,0)

	if ZO_CompassFrame:IsHandlerSet("OnShow") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnShow")
		ZO_CompassFrame:SetHandler("OnShow", function(...) oldHandler(...) if AR.settings.shown then AR.window:SetHidden(false) end end)
	else
		ZO_CompassFrame:SetHandler("OnShow", function(...) if AR.settings.shown then AR.window:SetHidden(false) end end)
	end
	if ZO_CompassFrame:IsHandlerSet("OnHide") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnHide")
		ZO_CompassFrame:SetHandler("OnHide", function(...) oldHandler(...) if AR.settings.shown then AR.window:SetHidden(true) end end)
	else
		ZO_CompassFrame:SetHandler("OnHide", function(...) if AR.settings.shown then AR.window:SetHidden(true) end end)
	end
	
end

function AR.PopulateWindow(text, active)
	if AR.window == nil then AR.MakeWindow() end
	AR.window.text:SetText(text)
	
	AR.window:SetHidden(ZO_CompassFrame:IsHidden() or not AR.settings.shown)
	AR.window.backdrop:SetHidden(not active)
	AR.window.title:SetColor(ZO_ColorDef.HexToFloats(active and "9E33FF" or "6C00FF"))
end

local function getActivityMessage()
	if AR.status == 2 and AR.settings.keepPorting then
		local delay = AR.runner:GetNextRoundDelay()
		if delay>120 then
			return "Starting another loop in " .. math.floor(delay/60) .. " minutes...", false
		elseif delay>60 then
			return "Starting another loop in ~1 minute...", false
		elseif delay>5 then
			return "Starting another loop in " .. delay .. " seconds...", false
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
end
