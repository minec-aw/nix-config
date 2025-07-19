import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts
import "toys"
import Quickshell.Widgets

PanelWindow {
	id: overview
	color: "transparent"
    property var slidingFactor: Hyprland.focusedWorkspace.id
    property var biggest: screen.width > screen.height? screen.width: screen.height
    property HyprlandMonitor hyprlandMonitor: Hyprland.monitorFor(screen)
    property var screenScale: Hyprland.monitorFor(screen).height / screen.height
    property var monitorWorkspaces: Shared.workspaceTopLevels.filter((workspace) => workspace.id >= 0 && Hyprland.workspaces.values.find((wrkspce) => wrkspce.id == workspace.id && wrkspce.monitor == hyprlandMonitor))
	anchors {
		top: true
		bottom: true 
		left: true
		right: true
	}
    WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.namespace: "shell:overview"
    property var workspaceSize: 400
    Item {
        id: keyboardgrabber
        anchors.fill: parent
        focus: true
        Keys.onReleased: (event) => {
            if (event.key == Qt.Key_Alt) {
                Shared.overviewVisible = false
            }
        }
        Keys.onPressed: (event) => {
            if (event.key == Qt.Key_Shift) {
                Hyprland.dispatch("workspace e-1")
            }
        }
    }
    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
        }
    }
	Rectangle {
        width: childrenRect.width
        height: childrenRect.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        radius: 16
        color: Qt.rgba(0,0,0,0.3)
        Grid {
            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter
            
            columns: 4
            spacing: 8
            padding: 8
            Repeater {
                id: workspaces
                model: ScriptModel { values: monitorWorkspaces}
                Rectangle {
                    id: workspace
                    width: (overview.screen.width/overview.biggest) * workspaceSize + 4
                    height: (overview.screen.height/overview.biggest) * workspaceSize + 4
                    required property var modelData
                    color: Qt.rgba(0,0,0,0.6)
                    radius: 10
                    border {
                        color: Hyprland.monitorFor(overview.screen).activeWorkspace.id == modelData.id? Qt.rgba(1,0.788,0.996,1) : Qt.rgba(0.3,0.3,0.3,0.6)
                        width: 2
                        Behavior on color {ColorAnimation { duration: 100}}
                        pixelAligned: false
                    }
                    ClippingRectangle {
                        id: workspace2
                        width: (overview.screen.width/overview.biggest) * workspaceSize
                        height: (overview.screen.height/overview.biggest) * workspaceSize
                        clip: true
                        radius: 8
                        color: "transparent"
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                        Repeater {
                            id: toplevels
                            model: ScriptModel {values: modelData.toplevels}
                            ScreencopyView {
                                id: scview
                                required property var modelData
                                captureSource: modelData.toplevel
                                x: (modelData.position[0]/overview.biggest) * workspaceSize
                                y: (modelData.position[1]/overview.biggest) * workspaceSize
                                live: true
                                width: ((sourceSize.width/screenScale)/overview.biggest)*workspaceSize
                                height: ((sourceSize.height/screenScale)/overview.biggest)*workspaceSize
                            }
                        }
                    }
                }
            }
        }
    }
}