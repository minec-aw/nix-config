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
    property HyprlandMonitor hyprlandMonitor: Hyprland.monitorFor(screen)
    property var workspaces: Shared.workspacesFocusOrder
    property var selectedWorkspace: workspaces[Shared.nextWorkspaceIndex]
    property bool finalAnimation: false
    property var finalDimensions: []

    anchors {
		top: true
		bottom: true 
		left: true
		right: true
	}
    WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.namespace: "shell:overview"
    Item {
        id: keyboardgrabber
        anchors.fill: parent
        focus: true
        Keys.onReleased: (event) => {
            if (event.key == Qt.Key_Alt) {
                workspaces = [...workspaces]
                finalAnimation = true
                Hyprland.dispatch("workspace "+workspaces[Shared.nextWorkspaceIndex].id)
                Shared.keepShowingOverview = true
                Shared.timeOverviewClose.start()
                Shared.overviewVisible = false
			    //Shared.overviewVisible = false
            }
        }
        Keys.onPressed: (event) => {
            if (event.key == Qt.Key_Shift) {
                Shared.nextWorkspaceIndex = Shared.nextWorkspaceIndex == 0? Shared.workspacesFocusOrder.length - 1: Shared.nextWorkspaceIndex-1
            }
        }
    }
    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
        }
    }
	Rectangle {
        id: overviewpanel
        width: childrenRect.width
        height: childrenRect.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        radius: 16
        color: Qt.rgba(0,0,0,0.5)
        Grid {
            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter
            
            columns: 4
            spacing: 8
            padding: 8
            Repeater {
                id: workspacescontainer
                model: ScriptModel { values: workspaces }
                Rectangle {
                    id: rectingle
                    required property var modelData
                    property var selected: selectedWorkspace == modelData
                    onSelectedChanged: () => {
                        if (selected == false) return
                        const newPos = overview.mapFromItem(rectingle, 2,2)
                        finalDimensions = [newPos.x, newPos.y, hyprlandMonitor.width/5.5,hyprlandMonitor.height/5.5]
                    }
                    width: selected? hyprlandMonitor.width/5.5: hyprlandMonitor.width/7
                    height: selected? hyprlandMonitor.height/5.5: hyprlandMonitor.height/7
                    Behavior on width {
                        NumberAnimation {
                            easing {
                                type: Easing.OutCirc
                            }
                            duration: 200
                        }
                    }
                    Behavior on height {
                        NumberAnimation {
                            easing {
                                type: Easing.OutCirc
                            }
                            duration: 200
                        }
                    }
                    
                    border {
                        width: 2
                        color: selected? Shared.colors.outline: Qt.rgba(0,0,0,0)
                        Behavior on color {ColorAnimation { duration: 100}}
                        pixelAligned: false
                    }
                    color: "transparent"
                    radius: 10
                    ClippingRectangle {
                        radius: 10
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
    Item {
        id: expandanimcontainer
        anchors.fill: parent
        visible: finalAnimation == true && finalDimensions.length == 4
        ClippingRectangle {
            id: cliprect
            states: State {
                name: "expansion"
                when: expandanimcontainer.visible == true
                PropertyChanges {
                    target: cliprect
                    x: 0
                    radius: 0
                    y: 0
                    width: parent.width
                    height: parent.height
                }
            }
            transitions: Transition {
                to: "expansion"
                reversible: false
                ParallelAnimation {
                    NumberAnimation { 
                        properties: "x,y,width,height,radius"
                        duration: 300
                        easing {
                            type: Easing.OutExpo
                        }
                    }                    
                }
            }
            radius: 10
            color: Qt.rgba(0,0,0,0)
            x: finalDimensions[0]
            y: finalDimensions[1]
            width: finalDimensions[2] - 4
            height: finalDimensions[3] - 4

            WorkspacePanel {
                id: wpanel
                anchors.fill: parent
                workspace: selectedWorkspace
            }
        }
    }
}