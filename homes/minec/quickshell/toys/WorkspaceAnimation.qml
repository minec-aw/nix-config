import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts

PropertyAnimation {
    easing {
        type: Easing.InOutCubic
        //bezierCurve: [0,0, 0.15,0,0.1,1,1,1]
    }
    duration: 400
}