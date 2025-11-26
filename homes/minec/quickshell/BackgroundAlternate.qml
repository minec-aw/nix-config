import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import "toys"

PanelWindow {
    id: background
    color: "black"

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "shell:background"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    AlternateBackgroundObject {
        animate: true
        anchors.fill: parent
        slidingFactor: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0
    }
}
