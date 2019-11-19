-------------------------------------------------
-- Volume Widget for Awesome Window Manager
-- Shows the current volume level
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/volume-widget

-- @author Pavel Makhov
-- @copyright 2018 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local spawn = require("awful.spawn")

local secrets = require("awesome-wm-widgets.secrets")

local path_to_icons = "/home/kapo/.config/awesome/awesome-wm-widgets/mic-widget/"

local device_arg
if secrets.volume_audio_controller == 'pulse' then
	device_arg = '-D pulse'
else
	device_arg = ''
end

local GET_VOLUME_CMD = 'amixer ' .. device_arg .. ' sget Capture'
local INC_VOLUME_CMD = 'amixer ' .. device_arg .. ' sset Capture 5%+'
local DEC_VOLUME_CMD = 'amixer ' .. device_arg .. ' sset Capture 5%-'
local TOG_VOLUME_CMD = 'amixer ' .. device_arg .. ' sset Capture toggle'


local volume_widget = wibox.widget {
    {
        id = "icon",
        image = path_to_icons .. "microphone-sensitivity-muted-symbolic_red.png",
        resize = true,
        widget = wibox.widget.imagebox,
	forced_height = 14,
	forced_width = 14
    },
    layout = wibox.container.margin(_, _, _, 3),
    set_image = function(self, path)
        self.icon.image = path
    end
}

local update_graphic = function(widget, stdout, _, _, _)
    local mute = string.match(stdout, "%[(o%D%D?)%]")
    local volume = string.match(stdout, "(%d?%d?%d)%%")
    volume = tonumber(string.format("% 3d", volume))
    local volume_icon_name
    if mute == "off" then volume_icon_name="microphone-sensitivity-muted-symbolic_red.png"
    elseif (volume >= 0 and volume < 25) then volume_icon_name="microphone-sensitivity-muted-symbolic.svg"
    elseif (volume < 50) then volume_icon_name="microphone-sensitivity-low-symbolic.svg"
    elseif (volume < 75) then volume_icon_name="microphone-sensitivity-medium-symbolic.svg"
    elseif (volume <= 100) then volume_icon_name="microphone-sensitivity-high-symbolic.svg"
    end
    widget.image = path_to_icons .. volume_icon_name
end

--[[ allows control volume level by:
- clicking on the widget to mute/unmute
- scrolling when cursor is over the widget
]]
volume_widget:connect_signal("button::press", function(_,_,_,button)
    if (button == 4)     then awful.spawn(INC_VOLUME_CMD, false)
    elseif (button == 5) then awful.spawn(DEC_VOLUME_CMD, false)
    elseif (button == 1) then awful.spawn(TOG_VOLUME_CMD, false)
    end

    spawn.easy_async(GET_VOLUME_CMD, function(stdout, stderr, exitreason, exitcode)
        update_graphic(volume_widget, stdout, stderr, exitreason, exitcode)
    end)
end)

watch(GET_VOLUME_CMD, 1, update_graphic, volume_widget)

return volume_widget
