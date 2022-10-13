#!/bin/bash

dconfKey="/org/gnome/shell/extensions/panel-date-format/format"
baseFormat="%A, %F %H:%M:%S %:z"
shiftWhitespace="                                                                                                                                                                         "

actualFormat=
if xrandr | grep --quiet --extended-regexp '(eDP|LVDS)-?(\d+)? connected primary'
then
	actualFormat="$baseFormat"
else
	actualFormat="$baseFormat$shiftWhitespace"
fi

dconf write "$dconfKey" "'$actualFormat'"

