import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import "toys"

PanelWindow {
    id: background
    color: "black"
    property int focusedWorkspaceId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id - 1 : 0
    onFocusedWorkspaceIdChanged: {
        Shared.boatFactor = focusedWorkspaceId;
    }
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
        slidingFactor: background.focusedWorkspaceId
    }
}
