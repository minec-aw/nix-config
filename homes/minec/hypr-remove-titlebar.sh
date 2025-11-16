CLASS=$(hyprctl -j activewindow | jq -r '.class')
ESCAPED=$(printf '%s' "$CLASS" | sed 's/\./\\./g')

# 1. Apply immediately
hyprctl keyword windowrulev2 "plugin:hyprbars:nobar, class:^($CLASS)$"

# 2. Persist in wrule.conf (Hyprland syntax)
echo "windowrulev2 = plugin:hyprbars:nobar, class:^($ESCAPED)$" \
    >> ~/.config/hypr/wrule.conf
