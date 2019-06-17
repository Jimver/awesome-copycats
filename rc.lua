--[[

    Awesome WM configuration template
    github.com/lcpz

--]]

-- {{{ Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears         = require("gears")
local awful         = require("awful")
require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
--local menubar       = require("menubar")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
                    require("awful.hotkeys_popup.keys")
local my_table      = awful.util.table or gears.table -- 4.{0,1} compatibility
local dpi           = require("beautiful.xresources").apply_dpi
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                    title = "Oops, there were errors during startup!",
                    text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                        title = "Oops, an error happened!",
                        text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart windowless processes

-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end

-- run_once({"blueman-applet"})
-- run_once({"nm-applet"})
-- run_once({"pasystray"})
-- run_once({"gtk-launch jetbrains-toolbox"})
-- run_once({"mate-power-manager"})
-- run_once({"octopi-notifier"})
-- run_once({"redshift-gtk"})
run_once({"optimus-manager-qt"})
run_once({"nvidia-settings --load-config-only"})
run_once({"fusuma"})
run_once({"compton"})
run_once({"dex -a"})
run_once({"systemctl --user import-environment PATH DBUS_SESSION_BUS_ADDRESS"})
run_once({"systemctl --no-block --user start xsession.target"})

-- run_once({ "urxvtd", "unclutter -root" }) -- entries must be separated by commas

function logout()
    run_once({"systemctl --no-block --user stop xsession.target"})
    awesome.quit()
end

-- This function implements the XDG autostart specification
--[[
awful.spawn.with_shell(
    'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
    'xrdb -merge <<< "awesome.started:true";' ..
    -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
    'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
)
--]]

-- }}}

-- {{{ Variable definitions
local themes = {
    "blackburn",       -- 1
    "copland",         -- 2
    "dremora",         -- 3
    "holo",            -- 4
    "multicolor",      -- 5
    "powerarrow",      -- 6
    "powerarrow-dark", -- 7
    "rainbow",         -- 8
    "steamburn",       -- 9
    "vertex",          -- 10
}
local chosen_theme = themes[6]
local modkey       = "Mod4"
local altkey       = "Mod1"
local controlkey = "Control"
local shiftkey = "Shift"
local escapekey = "Escape"
local terminal     = "alacritty"
local editor       = os.getenv("EDITOR") or "nano"
local gui_editor   = "kate"
local browser      = "firefox"
local guieditor    = "kate"
local scrlocker    = "i3lock-fancy-rapid 7 3"

awful.util.terminal = terminal
awful.util.tagnames = { "1", "2", "3", "4", "5" }
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.tile.left,
--     awful.layout.suit.tile.bottom,
--     awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
--     awful.layout.suit.max.fullscreen,
--     awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
    --lain.layout.cascade,
    --lain.layout.cascade.tile,
    --lain.layout.centerwork,
    --lain.layout.centerwork.horizontal,
    --lain.layout.termfair,
    --lain.layout.termfair.center,
}

awful.util.taglist_buttons = my_table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

awful.util.tasklist_buttons = my_table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            --c:emit_signal("request::activate", "tasklist", {raise = true})<Paste>

            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 2, function (c) c:kill() end),
    awful.button({ }, 3, function ()
        local instance = nil

        return function ()
            if instance and instance.wibox.visible then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({theme = {width = dpi(250)}})
            end
        end
    end),
    awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = dpi(2)
lain.layout.cascade.tile.offset_y      = dpi(32)
lain.layout.cascade.tile.extra_padding = dpi(5)
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))
-- }}}

-- {{{ Menu
local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
    { "restart", awesome.restart },
    { "quit", logout }
}

local mysystemmenu = {
    { "Logout", logout },
    {"Suspend", function() awful.spawn("systemctl suspend") end },
    {"Reboot", function() awful.spawn("reboot") end },
    {"Shutdown", function() awful.spawn("shutdown now") end }
}

awful.util.mymainmenu = freedesktop.menu.build({
    icon_size = beautiful.menu_height or dpi(16),
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
        { "Open terminal", terminal },
        { "System", mysystemmenu }
        -- other triads can be put here
    }
})
-- hide menu when mouse leaves it
--awful.util.mymainmenu.wibox:connect_signal("mouse::leave", function() awful.util.mymainmenu:hide() end)

--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it
-- }}}

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
    -- Refresh wallpaper
    refresh_screen_wallpaper(s)
end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function (s)
    local only_one = #s.tiled_clients == 1
    for _, c in pairs(s.clients) do
        if only_one and not c.floating or c.maximized then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
        end
    end
end)
-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)
-- }}}

-- {{{ Mouse bindings
root.buttons(my_table.join(
    awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}
    
-- {{{ Wallpapers per screen
-- This section sets random wallpapers from a folder
-- Set according to wallpaper directory
local path = os.getenv("HOME") .."/.wallpaper/Custom/"
-- Set to number of used tags
local num_tabs = #awful.util.tagnames
-- Interval to change wallpapers (in minutes)
local interval = 10
-- Other variables
local num_files = 0
local wp_all = {}
local wp_selected = {}
math.randomseed(os.time());
-- To guarantee unique random numbers on every platform, pop a few
for i = 1,10 do
    math.random()
end
-- 
-- LUA implementation of PHP scan dir
-- Returns all files (except . and ..) in "directory"
function scandir(directory)
    num_files, t, popen = 0, {}, io.popen
    for filename in popen('ls -a "'..directory..'"'):lines() do
        -- If case to disregard "." and ".."
        if(not(filename == "." or filename == "..")) then
            num_files = num_files + 1
            t[num_files] = filename
        end
    end
    return t
end

-- Quick clone method
function table.clone(org)
    return {table.unpack(org)}
end

-- Basically a modern Fisher-Yates shuffle
-- Returns "tabs" elements from an table "wp" of length "files_num"
-- Guarantees no duplicated elements in the return while having linear runtime 
function select_fisher_yates(wp,files_num,tabs)
    wp_orig = table.clone(wp)
    local selected = {}
    for i=1,tabs do
        position = math.random(1,files_num)
        -- Assign image to selected
        selected[i] = wp[position]
        -- Put last entry in the selected position
        wp[position] = wp[files_num]
        files_num = files_num - 1
        if(files_num == 0) then
            break
        end
    end
    if not(#selected == tabs) then
        num_left = tabs - #selected
        subresult = select_fisher_yates(wp_orig, files_num, num_left)
        for _, sub_v in pairs(subresult) do
            table.insert(selected, sub_v)
        end
    end
    return selected
end

-- Get the names of #screen files from "num_files" total files in "path"
function wp_selected()
    return select_fisher_yates(scandir(path),num_files,screen.count())
end

function refresh_screen_wallpaper(s)
    screen_index = s.index
    -- 	Set wallpaper on first tab (else it would be empty at start up)
    gears.wallpaper.maximized(path .. wp_selected()[screen_index], screen_index)
end

function refresh_wallpapers()
    -- For each screen
    for s in screen do
        refresh_screen_wallpaper(s)
    end
end

-- Initial set
awful.screen.connect_for_each_screen(function(s)
    -- do something
    refresh_screen_wallpaper(s)
end)

gears.timer {
    timeout   = interval * 60,
    call_now  = true,
    autostart = true,
    callback  = refresh_wallpapers
}
-- }}}

-- {{{ Key bindings
globalkeys = my_table.join(
    -- Take a screenshot
    -- https://github.com/lcpz/dots/blob/master/bin/screenshot
--     awful.key({ altkey }, "p", function() os.execute("screenshot") end,
--               {description = "take a screenshot", group = "hotkeys"}),
    -- Gnome System Monitor shortcut
    awful.key({controlkey, shiftkey}, "Escape", function()
              awful.spawn.with_shell("gnome-system-monitor") end),
    
    -- Tdrop toggle
    awful.key({}, "F12", function() 
              awful.spawn.with_shell("tdrop -a -m -w 90% -x 5% alacritty") end),
    
    -- Screenshots
    awful.key({ }, "Print", function() 
              awful.spawn.with_shell("maim | xclip -selection clipboard -t image/png") end, 
              {description = "Take fullscreen screenshot", group = "hotkeys"}),
    awful.key({altkey}, "Print", function() 
              awful.spawn.with_shell("maim -i $(xdotool getactivewindow) | xclip -selection clipboard -t image/png") end, 
              {description = "Take screenshot of current window", group = "hotkeys"}),
    awful.key({controlkey, altkey}, "Print", function() 
              awful.spawn.with_shell("maim -s | xclip -selection clipboard -t image/png") end, 
              {description = "Take selection screenshot", group = "hotkeys"}),
    
    -- Refresh wallpapers
    awful.key({ modkey}, "t", refresh_wallpapers, 
            {description = "refresh wallpapers", group = "screen"}),
    
    -- Rofi menu
    awful.key({ modkey}, "d", function() awful.spawn.with_shell("rofi -show combi") end, 
            {description = "rofi launcher", group = "launcher"}),

    -- X screen locker
    awful.key({ altkey, controlkey }, "l", function () awful.spawn(scrlocker) end,
            {description = "lock screen", group = "hotkeys"}),

    -- Hotkeys
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
            {description = "show help", group="awesome"}),
    -- Tag browsing
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
            {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
            {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
            {description = "go back", group = "tag"}),

    -- Non-empty tag browsing
    awful.key({ controlkey, altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end,
            {description = "view  previous nonempty", group = "tag"}),
    awful.key({ controlkey, altkey}, "Right", function () lain.util.tag_view_nonempty(1) end,
            {description = "view  previous nonempty", group = "tag"}),

    -- Default client focus
    awful.key({ altkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ altkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus down", group = "client"}),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.global_bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus up", group = "client"}),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus left", group = "client"}),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus right", group = "client"}),
    awful.key({ modkey,           }, "w", function () awful.util.mymainmenu:show() end,
            {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, shiftkey   }, "j", function () awful.client.swap.byidx(  1)    end,
            {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, shiftkey   }, "k", function () awful.client.swap.byidx( -1)    end,
            {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, controlkey }, "j", function () awful.screen.focus_relative( 1) end,
            {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, controlkey }, "k", function () awful.screen.focus_relative(-1) end,
            {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
            {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
            for s in screen do
                s.mywibox.visible = not s.mywibox.visible
                if s.mybottomwibox then
                    s.mybottomwibox.visible = not s.mybottomwibox.visible
                end
            end
        end,
        {description = "toggle wibox", group = "awesome"}),

    -- On the fly useless gaps change
    awful.key({ altkey, controlkey }, "=", function () beautiful.useless_gap =  math.min(beautiful.useless_gap + 1, 100) end,
            {description = "increment useless gaps", group = "tag"}),
    awful.key({ altkey, controlkey }, "-", function () beautiful.useless_gap =  math.max(beautiful.useless_gap - 1, 0) end,
            {description = "decrement useless gaps", group = "tag"}),

    -- Dynamic tagging
    awful.key({ modkey, shiftkey }, "n", function () lain.util.add_tag() end,
            {description = "add new tag", group = "tag"}),
    awful.key({ modkey, shiftkey }, "r", function () lain.util.rename_tag() end,
            {description = "rename tag", group = "tag"}),
    awful.key({ modkey, shiftkey }, "Left", function () lain.util.move_tag(-1) end,
            {description = "move tag to the left", group = "tag"}),
    awful.key({ modkey, shiftkey }, "Right", function () lain.util.move_tag(1) end,
            {description = "move tag to the right", group = "tag"}),
    awful.key({ modkey, shiftkey }, "d", function () lain.util.delete_tag() end,
            {description = "delete tag", group = "tag"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
            {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, controlkey }, "r", awesome.restart,
            {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, shiftkey   }, "q", logout,
            {description = "quit awesome", group = "awesome"}),

    awful.key({ altkey, shiftkey   }, "l",     function () awful.tag.incmwfact( 0.05)          end,
            {description = "increase master width factor", group = "layout"}),
    awful.key({ altkey, shiftkey   }, "h",     function () awful.tag.incmwfact(-0.05)          end,
            {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, shiftkey   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
            {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, shiftkey   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
            {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
            {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, controlkey }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
            {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
            {description = "select next", group = "layout"}),
    awful.key({ modkey, shiftkey   }, "space", function () awful.layout.inc(-1)                end,
            {description = "select previous", group = "layout"}),

    awful.key({ modkey, controlkey }, "n",
            function ()
                local c = awful.client.restore()
                -- Focus restored client
                if c then
                    client.focus = c
                    c:raise()
                end
            end,
            {description = "restore minimized", group = "client"}),

    -- Dropdown application
    awful.key({ modkey, }, "z", function () awful.screen.focused().quake:toggle() end,
            {description = "quake dropdown application", group = "launcher"}),

    -- Widgets popups
    awful.key({ altkey, }, "c", function () if beautiful.cal then beautiful.cal.show(7) end end,
            {description = "show calendar", group = "widgets"}),
    awful.key({ altkey, }, "h", function () if beautiful.fs then beautiful.fs.show(7) end end,
            {description = "show filesystem", group = "widgets"}),
    awful.key({ altkey, }, "w", function () if beautiful.weather then beautiful.weather.show(7) end end,
            {description = "show weather", group = "widgets"}),

    -- Brightness
    awful.key({ }, "XF86MonBrightnessUp", function () end,
            {description = "+5%", group = "hotkeys"}),
    awful.key({ }, "XF86MonBrightnessDown", function () end,
            {description = "-5%", group = "hotkeys"}),

    -- Volume control
    awful.key({  }, "XF86AudioRaiseVolume",
        function ()
            beautiful.volume.update()
        end,
        {description = "volume up", group = "hotkeys"}),
    awful.key({  }, "XF86AudioRaiseVolume",
        function ()
            beautiful.volume.update()
        end,
        {description = "volume down", group = "hotkeys"}),
    awful.key({  }, "XF86AudioRaiseVolume",
        function ()
            beautiful.volume.update()
        end,
        {description = "toggle mute", group = "hotkeys"}),

    -- MPD control
    awful.key({ altkey, controlkey }, "Up",
        function ()
            awful.spawn.easy_async("mpc toggle", function() beautiful.mpd.update() end)
        end,
        {description = "mpc toggle", group = "widgets"}),
    awful.key({ altkey, controlkey }, "Down",
        function ()
            awful.spawn.easy_async("mpc stop", function() beautiful.mpd.update() end)
        end,
        {description = "mpc stop", group = "widgets"}),
    awful.key({ altkey, controlkey }, "Left",
        function ()
            awful.spawn.easy_async("mpc prev", function() beautiful.mpd.update() end)
        end,
        {description = "mpc prev", group = "widgets"}),
    awful.key({ altkey, controlkey }, "Right",
        function ()
            awful.spawn.easy_async("mpc next", function() beautiful.mpd.update() end)
        end,
        {description = "mpc next", group = "widgets"}),
    awful.key({ altkey }, "0",
        function ()
            local common = { text = "MPD widget ", position = "top_middle", timeout = 2 }
            if beautiful.mpd.timer.started then
                beautiful.mpd.timer:stop()
                common.text = common.text .. lain.util.markup.bold("OFF")
            else
                beautiful.mpd.timer:start()
                common.text = common.text .. lain.util.markup.bold("ON")
            end
            naughty.notify(common)
        end,
        {description = "mpc on/off", group = "widgets"}),

    -- Copy primary to clipboard (terminals to gtk)
    awful.key({ modkey }, "c", function () awful.spawn.with_shell("xsel | xsel -i -b") end,
            {description = "copy terminal to gtk", group = "hotkeys"}),
    -- Copy clipboard to primary (gtk to terminals)
    awful.key({ modkey }, "v", function () awful.spawn.with_shell("xsel -b | xsel") end,
            {description = "copy gtk to terminal", group = "hotkeys"}),

    -- User programs
    awful.key({ modkey }, "q", function () awful.spawn(browser) end,
            {description = "run browser", group = "launcher"}),
    awful.key({ modkey }, "a", function () awful.spawn(guieditor) end,
            {description = "run gui editor", group = "launcher"}),

    -- Default
    --[[ Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
            {description = "show the menubar", group = "launcher"})
    --]]
    --[[ dmenu
    awful.key({ modkey }, "x", function ()
            os.execute(string.format("dmenu_run -i -fn 'Monospace' -nb '%s' -nf '%s' -sb '%s' -sf '%s'",
            beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus))
        end,
        {description = "show dmenu", group = "launcher"})
    --]]
    -- alternatively use rofi, a dmenu-like application with more features
    -- check https://github.com/DaveDavenport/rofi for more details
    --[[ rofi
    awful.key({ modkey }, "x", function ()
            os.execute(string.format("rofi -show %s -theme %s",
            'run', 'dmenu'))
        end,
        {description = "show rofi", group = "launcher"}),
    --]]
    -- Prompt
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
            {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
            function ()
                awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                }
            end,
            {description = "lua execute prompt", group = "awesome"})
    --]]
)

clientkeys = my_table.join(
    -- Close client
    awful.key({ altkey }, "F4", function (c) c:kill() end,
              {description = "close", group = "client"}),
    awful.key({ altkey, shiftkey   }, "m",      lain.util.magnify_client,
            {description = "magnify client", group = "client"}),
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, controlkey }, "space",  awful.client.floating.toggle                     ,
            {description = "toggle floating", group = "client"}),
    awful.key({ modkey, controlkey }, "Return", function (c) c:swap(awful.client.getmaster()) end,
            {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
            {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
            {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == 9 then
        descr_view = {description = "view tag #", group = "tag"}
        descr_toggle = {description = "toggle tag #", group = "tag"}
        descr_move = {description = "move focused client to tag #", group = "tag"}
        descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag"}
    end
    globalkeys = my_table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                        tag:view_only()
                        end
                end,
                descr_view),
        -- Toggle tag display.
        awful.key({ modkey, controlkey }, "#" .. i + 9,
                function ()
                    local screen = awful.screen.focused()
                    local tag = screen.tags[i]
                    if tag then
                        awful.tag.viewtoggle(tag)
                    end
                end,
                descr_toggle),
        -- Move client to tag.
        awful.key({ modkey, shiftkey }, "#" .. i + 9,
                function ()
                    if client.focus then
                        local tag = client.focus.screen.tags[i]
                        if tag then
                            client.focus:move_to_tag(tag)
                        end
                    end
                end,
                descr_move),
        -- Toggle tag on focused client.
        awful.key({ modkey, controlkey, shiftkey }, "#" .. i + 9,
                function ()
                    if client.focus then
                        local tag = client.focus.screen.tags[i]
                        if tag then
                            client.focus:toggle_tag(tag)
                        end
                    end
                end,
                descr_toggle_focus)
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
    properties = { border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                    focus = awful.client.focus.filter,
                    raise = true,
                    keys = clientkeys,
                    buttons = clientbuttons,
                    screen = awful.screen.preferred,
                    placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                    size_hints_honor = false
    }
    },

    -- Titlebars
    { rule_any = { type = { "dialog", "normal" } },
    properties = { titlebars_enabled = true } },

    -- Set Firefox to always map on the first tag on screen 1.
    -- { rule = { class = "Firefox" },
    -- properties = { screen = 1, tag = awful.util.tagnames[1] } },

    { rule = { class = "Gimp", role = "gimp-image-window" },
        properties = { maximized = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
    not c.size_hints.user_position
    and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- Custom
    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

    -- Default
    -- buttons for the titlebar
    local buttons = my_table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 2, function() c:kill() end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {size = dpi(16)}) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:emit_signal("request::activate", "mouse_enter", {raise = true})
-- end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- possible workaround for tag preservation when switching back to default screen:
-- https://github.com/lcpz/awesome-copycats/issues/251
-- }}}
