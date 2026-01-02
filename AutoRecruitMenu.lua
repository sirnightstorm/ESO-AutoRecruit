if AutoRecruit == nil then AutoRecruit = {} end
local AR = AutoRecruit

function AR.MakeMenu()

	local guilds = {}

	for guild = 1, GetNumGuilds() do
		table.insert(guilds, GetGuildName(GetGuildId(guild)))
	end


	local panelData = {
    		type = "panel",
    		name = "Auto Recruit",
    		displayName = "Auto Recruit",
    		author = "|c6C00FFpeniku8|r, |c4444CCSirNightstorm|r",
        version = AR.version,
        --slashCommand = "/autorecruit",
        registerForRefresh = true,
        registerForDefaults = true,
        website = "https://www.esoui.com/downloads/info2571-AutoRecruit.html",
	}



  function AR.makeGuildMenu()

    local guildMenu = {}

      table.insert(guildMenu,
          {
        			type = "description",
        			text = "Note: The message previews require you to reload the UI to update.\n",
          }
      )

    local guild = AR.getGuildIndex(AR.getIDfromName(AR.settings.recruitFor))
      --for guild=1, 5 do

     	   -- table.insert(guildMenu,
          -- 		{
          --			  type = "header",
          --			  name = guilds[guild],
          --        width = "full",
          --    }
          --)

     	    table.insert(guildMenu,
              {
                  type = "checkbox",
                  name = "Chat Notifications",
                  getFunc = function() return AR.settings.guild[guild] end,
                  setFunc = function(value) AR.settings.guild[guild] = value end,
                  width = "full",
                  default = false,
              }
          )

     	    table.insert(guildMenu,
              {
                  type = "editbox",
                  name = "Recruitment Message",
                  tooltip = function() if string.len(AR.settings.ad[guild])>0 then return "Quickly paste this to your chat via keybind:\n\n" .. AR.settings.ad[guild] end end,
                  getFunc = function() return AR.settings.ad[guild] end,
                  setFunc = function(value) AR.settings.ad[guild] = value end,
                  isMultiline = true,
                  isExtraWide = true,
                  width = "full",
                  default = "",
              }
          )

     	    table.insert(guildMenu,
              {
                  type = "checkbox",
                  name = "Enable Welcome Message",
                  tooltip = "Enable automatically pasting the following welcome message into guild chat when a new member is recruited",
                  getFunc = function() return AR.settings.welcome[guild] end,
                  setFunc = function(value) AR.settings.welcome[guild] = value end,
                  width = "full",
                  default = false,
              }
          )

     	    table.insert(guildMenu,
              {
                  type = "editbox",
                  name = "Welcome Message",
                  tooltip = function()
                    return "Message automatically pasted into guild chat when a new member is recruited.\nUse @ for the new member's userID\n\n" .. AR.settings.welcomeText[guild]
                  end,
                  getFunc = function() return AR.settings.welcomeText[guild] end,
                  setFunc = function(value) AR.settings.welcomeText[guild] = value end,
                  isMultiline = true,
                  isExtraWide = true,
                  width = "full",
                  default = "",
              }
          )

     	    table.insert(guildMenu,
              {
                  type = "slider",
                  name = "Welcome message cooldown",
                  tooltip = "Set a cooldown in minutes to not spam the guild chat",
                  min = 0,
                  max = 60,
                  step = 1,
                  getFunc = function() return AR.settings.welcomeCooldown[guild] end,
                  setFunc = function(value) AR.settings.welcomeCooldown[guild] = value end,
                  width = "full",
                  default = 30,
              }
          )

     	    table.insert(guildMenu,
              {
                  type = "slider",
                  name = "Recruitment message zone cooldown",
                  tooltip = "Set a cooldown in minutes to not spam the same zone",
                  min = 0,
                  max = 60,
                  step = 1,
                  getFunc = function() return AR.settings.adCooldown[guild] end,
                  setFunc = function(value) AR.settings.adCooldown[guild] = value end,
                  width = "full",
                  default = 30,
              }
          )

          table.insert(guildMenu, {type = "custom"})

      --end

    return guildMenu

  end



  local optionsTable = {
		{
			  type = "header",
			  name = "Whisper Auto-Recruiting",
        width = "full",
    },

        {
            type = "checkbox",
            name = "Enabled",
            tooltip = "Enable Whisper Auto-Recruiting",
            getFunc = function() return AR.settings.whisperEnabled end,
            setFunc = function(value) AR.settings.whisperEnabled = value end,
            width = "full",
            default = AR.defaults.whisperEnabled,
        },

        {
            type = "checkbox",
            name = "Standard Keywords",
            tooltip = "Listen to keywords like 'invite' 'inv' '+' 'join' and more",
            getFunc = function() return AR.settings.standardEnabled end,
            setFunc = function(value) AR.settings.standardEnabled = value end,
            width = "full",
            default = AR.defaults.standardEnabled,
        },

        {
            type = "editbox",
            name = "Keyword",
            tooltip = "Check recieved whispers for this keyword",
            getFunc = function() return AR.settings.keyword end,
            setFunc = function(value) AR.settings.keyword = value end,
            isMultiline = false,
            width = "full",
            default = AR.defaults.keyword,
        },

        {
            type = "checkbox",
            name = "Case Sensitive",
            tooltip = "Make your keyword case sensitive",
            getFunc = function() return AR.settings.caseSensitive end,
            setFunc = function(value) AR.settings.caseSensitive = value end,
            width = "full",
            default = AR.defaults.caseSensitive,
        },


		{
			  type = "header",
			  name = "Display Settings",
        width = "full",
    },

        {
            type = "checkbox",
            name = "Chat Notifications",
            tooltip = "Enable chat notifications",
            getFunc = function() return AR.settings.notifications end,
            setFunc = function(value) AR.settings.notifications = value end,
            width = "full",
            default = AR.defaults.notifications,
        },

        {
            type = "checkbox",
            name = "Guild Trader Notification",
            tooltip = "Notifies you when your guild has no guild trader",
            getFunc = function() return AR.settings.trader end,
            setFunc = function(value) AR.settings.trader = value end,
            width = "full",
            default = AR.defaults.trader,
        },

        {
            type = "slider",
            name = "Space Warning",
            tooltip = "Notifies you when your guild is almost full. 0 = off",
            min = 0,
            max = 20,
            step = 1,
            getFunc = function() return AR.settings.warning end,
            setFunc = function(value) AR.settings.warning = value end,
            width = "full",
            default = AR.defaults.warning,
        },

        {
            type = "checkbox",
            name = "Show Info Overlay",
            tooltip = "Display a status information message onscreen",
            getFunc = function() return AR.settings.shown end,
            setFunc = function(value) AR.settings.shown = value end,
            width = "full",
            default = AR.defaults.shown,
        },

        {
            type = "checkbox",
            name = "Show Pending Applications on Overlay",
            tooltip = "List a pending applications count on the info overlay",
            getFunc = function() return AR.settings.showPending end,
            setFunc = function(value) AR.settings.showPending = value end,
            width = "full",
            default = AR.defaults.showPending,
        },


		{
			  type = "header",
			  name = "Teleporter Settings",
        width = "full",
    },
    
        {
            type = "dropdown",
            name = "Auto-Port mode:",
            tooltip = "Manual: Port to the next zone via keybind\nSemi-auto: Automatically port to the next zone once the recruitment message is sent to the zone chat\nFull-auto: Continuously port through the zones without stopping",
            choices = {"Manual", "Semi-auto", "Full-auto"},
            getFunc = function() return AR.settings.portMode end,
            setFunc = function(value) AR.settings.portMode = value end,
            width = "full",
            default = AR.defaults.portMode,
        },

				{
					type = "dropdown",
					name = "Included zones:",
					tooltip = "Major: main base and DLC chapter zones\nAll: all public map zones",
					choices = {"Major", "All"},
					getFunc = function() return AR.settings.includedZones end,
					setFunc = function(value)
						AR.settings.includedZones = value
						AR.getZones()
					end,
					width = "full",
					default = AR.defaults.includedZones,
				},
        
        {
            type = "checkbox",
            name = "Post recruitment ad upon arrival",
            getFunc = function() return AR.settings.postAd end,
            setFunc = function(value) AR.settings.postAd = value end,
            width = "full",
            default = AR.defaults.postAd,
        },
        
        {
            type = "checkbox",
            name = "Skip zones on cooldown",
            tooltip = "Don't port to zones, which you've recently posted an ad to",
            getFunc = function() return AR.settings.skipZoneOnCD end,
            setFunc = function(value) AR.settings.skipZoneOnCD = value end,
            width = "full",
            default = AR.defaults.skipZoneOnCD,
        },
        
        {
            type = "checkbox",
            name = "Multiple rounds",
            tooltip = "Teleport through all zones again after a certain time",
            getFunc = function() return AR.settings.keepPorting end,
            setFunc = function(value) AR.settings.keepPorting = value end,
            width = "full",
            default = AR.defaults.keepPorting,
        },
        
        {
            type = "slider",
            name = "Multiple rounds cooldown",
            tooltip = "How long to wait after every round",
            min = 5,
            max = 60,
            step = 1,
            getFunc = function() return AR.settings.portingTime end,
            setFunc = function(value) AR.settings.portingTime = value end,
            width = "full",
            default = AR.defaults.portingTime,
        },

    {
      type = "header",
      name = "Guild Settings",
      width = "full",
    },

    {
      type = "dropdown",
      name = "Recruit for:",
      tooltip = "Select the guild you want to recruit for",
      choices = guilds,
      getFunc = function() return AR.settings.recruitFor end,
      setFunc = function(value)
        AutoRecruitGuildSettings.data.disabled = value ~= AutoRecruitGuildSettings.data.guild
        AutoRecruitGuildSettings:UpdateDisabled()
        AR.settings.recruitFor = value
      end,
      width = "full",
      default = guilds[1],
      requiresReload = true,
    },
  }

  table.insert(optionsTable,
    {
        type = "submenu",
        name = AR.settings.recruitFor .. " Settings",
        controls = AR.makeGuildMenu(),
        reference = "AutoRecruitGuildSettings",
        disabled = false,
        guild = AR.settings.recruitFor
    }
  )

  local menu = LibAddonMenu2
	local arPanel = menu:RegisterAddonPanel("Auto_Recruit", panelData)
	menu:RegisterOptionControls("Auto_Recruit", optionsTable)

  CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
    if panel ~= arPanel then return end
    AutoRecruitGuildSettings.open = true
    AutoRecruitGuildSettings.animation:PlayFromStart()
  end)

	SLASH_COMMANDS["/autorecruit"] = function(extra)
		if extra == "save 1" then
			AR.settings.saveLastPosted = true -- Store last posted times so that cooldowns survive /reloadui or a game restart
			d("Auto Recruit: Save last posted times: enabled")
		elseif extra == "save 0" then
			AR.settings.saveLastPosted = false
			d("Auto Recruit: Save last posted times: disabled")
		else
			menu:OpenToPanel(panel)
		end
	end
end