--[[
                               
     Copland Awesome WM config 
     github.com/copycat-killer 
                               
--]]

-- {{{ Required libraries
local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
                  require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local drop      = require("scratchdrop")
local lain      = require("lain")
local eminent   = require("eminent")
local handTiler = require("hand-tiler")

-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart applications
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

run_once("urxvtd")
run_once("unclutter -root")
-- }}}

-- {{{ Variable definitions

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/copland/theme.lua")

-- common
modkey     = "Mod4"
altkey     = "Mod1"
terminal   = "urxvtc" or "xterm"
editor     = os.getenv("EDITOR") or "nano" or "vi"
editor_cmd = terminal .. " -e " .. editor

-- user defined
browser    = "firefox"
browser2   = "chromium"
gui_editor = "gvim"
graphics   = "gimp"

-- lain
lain.layout.termfair.nmaster   = 3
lain.layout.termfair.ncol      = 1
lain.layout.centerfair.nmaster = 3
lain.layout.centerfair.ncol    = 1

lain.layout.centerwork.top_left = 0
lain.layout.centerwork.top_right = 1
lain.layout.centerwork.bottom_left = 2
lain.layout.centerwork.bottom_right = 3

local layouts = {
    awful.layout.suit.floating,
 -- awful.layout.suit.fair,
--    awful.layout.suit.tile, 
    --lain.layout.uselesfair,
  --  lain.layout.uselessfair.horizontal,
  --  awful.layout.suit.magnifier
 -- lain.layout.uselessfair,
      lain.layout.centerfair,
 --   lain.layout.cascade,
    lain.layout.centerwork,
    lain.layout.uselesstile,
 -- lain.layout.uselesspiral.dwindle
}

-- }}}

-- {{{ Tags
tags = {
    names = { "I", "II", "III", "IV", "V" },
    layout = { layouts[1], layouts[1], layouts[1], layouts[1],layouts[2]  }
}
for s = 1, screen.count() do
   tags[s] = awful.tag(tags.names, s, tags.layout)
end

-- }}}

--[[ {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}]]

-- {{{ Menu
mymainmenu = awful.menu.new({ items = require("menugen").build_menu(),
                              theme = { height = 16, width = 130 }})
-- }}}

-- {{{ Wibox
markup = lain.util.markup
blue   = beautiful.fg_focus
red    = "#EB8F8F"
green  = "#8FEB8F"

-- Textclock
mytextclock = awful.widget.textclock("<span font='Terminus 5'> </span>%H:%M ")

-- Calendar
lain.widgets.calendar:attach(mytextclock)

--[[ Mail IMAP check
-- commented because it needs to be set before use
mailwidget = lain.widgets.imap({
    timeout  = 180,
    server   = "server",
    mail     = "mail",
    password = "keyring get mail",
    settings = function()
        mail  = ""
        count = ""

        if mailcount > 0 then
            mail = "<span font='Terminus 5'> </span>Mail "
            count = mailcount .. " "
        end

        widget:set_markup(markup(blue, mail) .. count)
    end
})
]]

-- MPD
mpdicon = wibox.widget.imagebox(beautiful.play)
mpdwidget = lain.widgets.mpd({
    settings = function()
        if mpd_now.state == "play" then
            title = mpd_now.title
            artist  = " - " .. mpd_now.artist  .. markup("#333333", " |<span font='Terminus 3'> </span>")
            mpdicon:set_image(beautiful.play)
        elseif mpd_now.state == "pause" then
            title = "mpd "
            artist  = "paused" .. markup("#333333", " |<span font='Terminus 3'> </span>")
            mpdicon:set_image(beautiful.pause)
        else
            title  = ""
            artist = ""
            mpdicon:set_image()
        end

        widget:set_markup(markup(blue, title) .. artist)
    end
})

-- Battery
baticon = wibox.widget.imagebox(beautiful.bat)
batbar = awful.widget.progressbar()
batbar:set_color(beautiful.fg_normal)
batbar:set_width(55)
batbar:set_ticks(true)
batbar:set_ticks_size(6)
batbar:set_background_color(beautiful.bg_normal)
batmargin = wibox.layout.margin(batbar, 2, 7)
batmargin:set_top(6)
batmargin:set_bottom(6)
batupd = lain.widgets.bat({
    settings = function()
       if bat_now.perc == "N/A" or bat_now.status == "Not present" then
            bat_perc = 100
            baticon:set_image(beautiful.ac)
        elseif bat_now.status == "Charging" then
            bat_perc = tonumber(bat_now.perc)
            baticon:set_image(beautiful.ac)

            if bat_perc >= 98 then
                batbar:set_color(green)
            elseif bat_perc > 50 then
                batbar:set_color(beautiful.fg_normal)
            elseif bat_perc > 15 then
                batbar:set_color(beautiful.fg_normal)
            else
                batbar:set_color(red)
            end
        else
            bat_perc = tonumber(bat_now.perc)

            if bat_perc >= 98 then
                batbar:set_color(green)
            elseif bat_perc > 50 then
                batbar:set_color(beautiful.fg_normal)
                baticon:set_image(beautiful.bat)
            elseif bat_perc > 15 then
                batbar:set_color(beautiful.fg_normal)
                baticon:set_image(beautiful.bat_low)
            else
                batbar:set_color(red)
                baticon:set_image(beautiful.bat_no)
            end
        end
        batbar:set_value(bat_perc / 100)
    end
})
batwidget = wibox.widget.background(batmargin)
batwidget:set_bgimage(beautiful.widget_bg)

-- /home fs
diskicon = wibox.widget.imagebox(beautiful.disk)
diskbar = awful.widget.progressbar()
diskbar:set_color(beautiful.fg_normal)
diskbar:set_width(55)
diskbar:set_ticks(true)
diskbar:set_ticks_size(6)
diskbar:set_background_color(beautiful.bg_normal)
diskmargin = wibox.layout.margin(diskbar, 2, 7)
diskmargin:set_top(6)
diskmargin:set_bottom(6)
fshomeupd = lain.widgets.fs({
    partition = "/home",
    settings  = function()
        if fs_now.used < 90 then
            diskbar:set_color(beautiful.fg_normal)
        else
            diskbar:set_color("#EB8F8F")
        end
        diskbar:set_value(fs_now.used / 100)
    end
})
diskwidget = wibox.widget.background(diskmargin)
diskwidget:set_bgimage(beautiful.widget_bg)

-- ALSA volume bar
volicon = wibox.widget.imagebox(beautiful.vol)
volume = lain.widgets.alsabar({width = 55, ticks = true, ticks_size = 6, step = "2%",
settings = function()
    if volume_now.status == "off" then
        volicon:set_image(beautiful.vol_mute)
    elseif volume_now.level == 0 then
        volicon:set_image(beautiful.vol_no)
    elseif volume_now.level <= 50 then
        volicon:set_image(beautiful.vol_low)
    else
        volicon:set_image(beautiful.vol)
    end
end,
colors =
{
    background = beautiful.bg_normal,
    mute = red,
    unmute = beautiful.fg_normal
}})
volmargin = wibox.layout.margin(volume.bar, 2, 7)
volmargin:set_top(6)
volmargin:set_bottom(6)
volumewidget = wibox.widget.background(volmargin)
volumewidget:set_bgimage(beautiful.widget_bg)

-- Weather
myweather = lain.widgets.weather({
    city_id = 6940463-- placeholder
})

-- Separators
spr = wibox.widget.textbox(' ')
small_spr = wibox.widget.textbox('<span font="Terminus 4"> </span>')
bar_spr = wibox.widget.textbox('<span font="Terminus 3"> </span>' .. markup("#333333", "|") .. '<span font="Terminus 3"> </span>')

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(small_spr)
    left_layout:add(mylayoutbox[s])
    left_layout:add(bar_spr)
    left_layout:add(mytaglist[s])
    left_layout:add(spr)
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(small_spr)
    right_layout:add(mpdicon)
    right_layout:add(mpdwidget)
    --right_layout:add(mailwidget)
    --right_layout:add(baticon)
    --right_layout:add(batwidget)
  --  right_layout:add(bar_spr)
   -- right_layout:add(diskicon)
    --right_layout:add(diskwidget)
   -- right_layout:add(bar_spr)
    right_layout:add(volicon)
    right_layout:add(volumewidget)
    right_layout:add(bar_spr)
    right_layout:add(mytextclock)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
  --  if s==2 then not mywibox[s].visible end
end

--mywibox[2].visible = false

-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Take a screenshot
    -- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
    awful.key({ altkey }, "p", function() os.execute("screenshot") end),

-----Tag browsing---------------------------------------------------------------------------------------------
    awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
--	awful.key({ modkey  }, "Left", 
--	function()
--	for i = 1, screen.count() do
--		awful.tag.viewprev(i)
--	    end
--	end ),
--
--	awful.key({ modkey }, "Right", 
--	function()
--	    for i = 1, screen.count() do
--		awful.tag.viewnext(i)
--	    end
--	end ),


----------------------------------------------------------------------------------------------------------
    awful.key({ modkey }, "Escape", awful.tag.history.restore),

	-- move/swap
    awful.key({ modkey,"Shift" }, "j", function (c) 
		if awful.client.floating.get(c) or awful.layout.getname(awful.layout.get(s)) == "floating" then
			awful.client.moveresize(  0,  15,   0,   0)
		else 
			awful.client.swap.global_bydirection("down")end    end),
    awful.key({ modkey,"Shift" }, "k", function (c) 
		if awful.client.floating.get(c) or awful.layout.getname(awful.layout.get(s)) == "floating" then
			awful.client.moveresize(  0,  -15,   0,   0)
		else 
			awful.client.swap.global_bydirection("up")end    end),
    awful.key({ modkey,"Shift" }, "h", function (c) 
		if awful.client.floating.get(c) or awful.layout.getname(awful.layout.get(s)) == "floating" then
			awful.client.moveresize(  -15,  0,   0,   0)
		else 
			awful.client.swap.global_bydirection("left")end    end),
    awful.key({ modkey,"Shift" }, "l", function (c) 
		if awful.client.floating.get(c) or awful.layout.getname(awful.layout.get(s)) == "floating" then
			awful.client.moveresize(  15,  0,   0,   0)
		else 
			awful.client.swap.global_bydirection("right")end    end),
			
	-- resize
	awful.key({ modkey }, "Next",  function (c) awful.client.moveresize( 0,  0, -40, -40) end), 
	awful.key({ modkey }, "Prior", function (c) awful.client.moveresize( 0, 0,  40,  40) end),  

	awful.key({ altkey }, "j", function (c) awful.client.moveresize( 0,   0,   0,   20) end),  
	awful.key({ altkey }, "k", function (c) awful.client.moveresize( 0,   0,   0,   -20) end),  
	awful.key({ altkey }, "l", function (c) awful.client.moveresize( 0,   0,   20,   0) end),  
	awful.key({ altkey }, "h", function (c) awful.client.moveresize( 0,   0,  -20,   0) end),  

	awful.key({ altkey,"Shift" }, "j", function (c) awful.client.moveresize( 0,   0,   0,   40) end),  
	awful.key({ altkey,"Shift"}, "k", function (c) awful.client.moveresize( 0,   0,   0,   -40) end),  
	awful.key({ altkey,"Shift" }, "l", function (c) awful.client.moveresize( 0,   0,   40,   0) end),  
	awful.key({ altkey,"Shift" }, "h", function (c) awful.client.moveresize( 0,   0,  -40,   0) end),  

--	awful.key({ altkey,"Shift"}, "j", function (c) awful.client.moveresize( 0,   20,   0,   -20) end),  
--	awful.key({ altkey,"Shift" }, "k", function (c) awful.client.moveresize( 0,  0,   0,   -20) end),  
--	awful.key({ altkey,"Shift" }, "l", function (c) awful.client.moveresize( 20,   0,   -20,   0) end),  
--	awful.key({ altkey,"Shift" }, "h", function (c) awful.client.moveresize( 0,   0,  -20,   0) end),  
	 
    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.global_bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),

    -- On the fly useless gaps change
    awful.key({ altkey, "Control" }, "=", function () lain.util.useless_gaps_resize(1) end),
    awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end),

    -- Layout manipulation
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative(1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ altkey, "Shift"   }, "l",      function () awful.tag.incmwfact( 0.05)     end),
    awful.key({ altkey, "Shift"   }, "h",      function () awful.tag.incmwfact(-0.05)     end),

    awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1)  end),
    awful.key({ modkey, "Control" }, "n",      awful.client.restore),

    awful.key({ modkey, "Control" }, "r",      awesome.restart),
    awful.key({ modkey, "Shift"   }, "q",      awesome.quit),

    -- Dropdown terminal
    awful.key({ modkey,	          }, "z",      function () drop(terminal) end),

    -- Widgets popups
    awful.key({ altkey,           }, "c",      function () lain.widgets.calendar:show(7) end),
    --awful.key({ altkey,           }, "h",      function () fshomeupd.show(7) end),
    awful.key({ altkey,           }, "w",      function () myweather.show(7) end),

    -- ALSA volume control
    awful.key({ altkey }, "Up",
        function ()
		os.execute(string.format("amixer set %s %s+", volume.channel, volume.step))
		volume.update()
        end),
    awful.key({ altkey }, "Down",
        function ()
            os.execute(string.format("amixer set %s %s-", volume.channel, volume.step))
            volume.update()
        end),
    awful.key({ altkey }, "m",
        function ()
            os.execute(string.format("amixer set %s toggle", volume.channel))
            volume.update()
        end),
    awful.key({ altkey, "Control" }, "m",
        function ()
            os.execute(string.format("amixer set %s 100%%", volume.channel))
            volume.update()
        end),


    -- Copy to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),
    --awful.key({ modkey }, "v", function () os.execute("xsel") end),


    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

	--  dmenu
	awful.key({ modkey },            ",",     function ()
    awful.util.spawn("dmenu_run -i -fn 'Tamsyn-10'  -nb '" .. 
 		beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal .. 
		"' -sb '" .. beautiful.bg_focus .. 
		"' -sf '" .. beautiful.fg_focus .. "'")
	end)


)

clientkeys = awful.util.table.join(


	awful.key({ modkey},  "[",     function (c) handTiler.tp(c, 'right-top')    end),
    awful.key({ modkey },  "p",     function (c) handTiler.tp(c, 'left-top')     end),
    awful.key({ modkey },  ";",     function (c) handTiler.tp(c, 'left-bottom')  end),
    awful.key({ modkey},  "'",     function (c) handTiler.tp(c, 'right-bottom') end),
    awful.key({ modkey,"Shift"},   "'",     function (c) handTiler.tp(c, 'middle')    end),
    awful.key({ modkey, "Shift"},   ";",     function (c) handTiler.tp(c, 'left-middle')    end),
    awful.key({ modkey, "Shift"},   "\\",     function (c) handTiler.tp(c, 'right-middle')    end),


    awful.key({ altkey, "Shift"   }, "m",      lain.util.magnify_client                         ),
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ altkey }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.--------------------------------------------------------------------------------------
   --     awful.key({ modkey }, "#" .. i + 9,
     --             function ()
       --                 local screen = mouse.screen
         --               local tag = awful.tag.gettags(screen)[i]
           --             if tag then
             --              awful.tag.viewonly(tag)
               --         end
                --  end),
		--
	
		awful.key({ modkey }, "#" .. i + 9,
		function ()
			for screen = 1, screen.count() do
				local tag = awful.tag.gettags(screen)[i]
				if tag then
					awful.tag.viewonly(tag)
				end
			end
		end
		),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, function (c)
		client.focus = c; c:raise()
		awful.mouse.client.move(c) end ),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons,
	                   size_hints_honor = false } },

    -- { rule = { class = "URxvt" },
    --       properties = { height = 336} },

    { rule = { name = "TeamSpeak 3" },
          properties = { width = 350 ,
	  					 height = 450} },

    { rule = { class = "TeamSpeak 3" },
		  properties = { floating = on}},

    -- { rule = { class = "MPlayer" },
    --       properties = { floating = true } },

    { rule = { instance = "Firefox" },
          properties = { height = 1035 } },

    { rule = { class = "Dwb" },
          properties = { tag = tags[1][1] } },

    { rule = { class = "Iron" },
          properties = { tag = tags[1][1] } },

    { rule = { instance = "plugin-container" },
          properties = { tag = tags[1][1] } },

	  { rule = { class = "Gimp" },
     	    properties = { tag = tags[1][3] } },

    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized_horizontal = true,
                         maximized_vertical = true } }

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
local sloppyfocus_last = {c=nil}
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    client.connect_signal("mouse::enter", function(c)
         if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
             -- Skip focusing the client if the mouse wasn't moved.
             if c ~= sloppyfocus_last.c then
                 client.focus = c
                 sloppyfocus_last.c = c
             end
         end
     end)
   	if not startup then
		
		awful.client.setslave(c)

		if not c.size_hints.user_position and not c.size_hints.program_position then 
			awful.placement.center_horizontal(c)
			awful.placement.center_vertical(c)
	  		awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
	--		awful.placement.centered(c,nil)
	end

     end


    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c,{size=16}):set_widget(layout)
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_color = beautiful.border_normal
        else
            c.border_color = beautiful.border_focus
        end
--		if c.class == "Firefox" then
--			c.border_color = beautiful.border_normal
--		end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout  = awful.layout.getname(awful.layout.get(s))
--TODO border firefox
        if #clients > 0 then -- Fine grained borders and floaters control
            for _, c in pairs(clients) do -- Floaters always have borders
                if awful.client.floating.get(c) or layout == "floating" then
                    c.border_width = beautiful.border_width

                -- No borders with only one visible client
                elseif #clients == 1 or layout == "max" then
                    c.border_width = 0
                else
                    c.border_width = beautiful.border_width
                end
            end
        end
      end)
end
-- }}}

-- vim: fdm=marker:fdl=0

