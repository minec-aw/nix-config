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
    //property var slidingFactor: Hyprland.focusedWorkspace.id
    //property var biggest: screen.width > screen.height? screen.width: screen.height
    property HyprlandMonitor hyprlandMonitor: Hyprland.monitorFor(screen)
    //property var screenScale: Hyprland.monitorFor(screen).height / screen.height
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
        //anchors.verticalCenter: parent.verticalCenter
        radius: 16
        color: Qt.rgba(0,0,0,0.5)
        Grid {
            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter
            
            columns: 4
            spacing: 8
            padding: 8
            Repeater {
                id: workspaces
                model: ScriptModel { values: Hyprland.workspaces.values.filter((workspace) => workspace.monitor == hyprlandMonitor && workspace.id >= 0).sort((workspaceA, workspaceB) => workspaceA.id - workspaceB.id)}
                Rectangle {
                    required property var modelData
                    width: modelData.monitor.width/6
                    height: modelData.monitor.height/6
                    border {
                        width: 2
                        color: modelData.active? Shared.colors.outline: Qt.rgba(0,0,0,0)
                        Behavior on color {ColorAnimation { duration: 100}}
                        pixelAligned: false
                    }
                    color: "transparent"
                    radius: 8
                    ClippingRectangle {
                        radius: 8
                        color: Qt.rgba(0,0,0,0.5)
                        anchors {
                            fill: parent
                            margins: 2
                        }
                        WorkspacePanel {
                            anchors.fill: parent
                            workspace: modelData
                        }
                    }
                }
            }
        }
    }
}