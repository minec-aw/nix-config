import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import "toys"
import Quickshell.Services.Mpris
import QtQuick.Effects

PanelWindow {
	id: dock
	property bool pinned: false
	property bool opened: false
	property bool hovered: false
	property bool fullHide: Hyprland.monitorFor(screen).activeWorkspace? Hyprland.monitorFor(screen).activeWorkspace.hasFullscreen: false
	property bool transparentBackground: true
	property real mouseY: 0
    property var floatMargin: 10
    property var pinnedApps: ["zen-beta", "org.kde.dolphin", "vesktop", "com.mitchellh.ghostty"];
    property var dockWidth: 0
    property var dockHeight: 68
    property string hoveredClass
    property var hoveredToplevels: ToplevelManager.toplevels.values.filter(toplevel => toplevel.appId == hoveredClass)
    property var hoveredXCenter: 0
    property bool tlviewVisible: false
    Timer {
        id: triggerTLView
        interval: 1000
        onTriggered: {
            tlviewVisible = true
        }
    }
	color: Qt.rgba(0,0,0,0)
    onHoveredChanged: {
        if (hovered == false) {
            tlviewVisible = false
            triggerTLView.stop()
        } 
    }
	
	HyprlandFocusGrab {
      id: grab
      windows: [dock]
	  onActiveChanged: () => {
		if (active == false) {
			panel.hover = false
			panel.opened = false
		}
	  }
	}
	Component.onCompleted: () => {
		Shared.panels.push(dock)
	}
	WlrLayershell.layer: WlrLayer.Overlay
	function keybindReveal() {
		if (opened) {
			opened = false
			hover = false
		} else if (Hyprland.focusedMonitor == Hyprland.monitorFor(screen)) {
			opened = true
		}
	}
	anchors {
		right: true
		bottom: true
		left: true
	}
	exclusionMode: ExclusionMode.Ignore
	implicitHeight: 300
    mask: Region {
        item: region1
        Region {
            item: region2
        }
    }
    Item {
        id: region1
        states: State {
            name: "hover"; when: dock.hovered == true
            PropertyChanges { target: region1; height: dockHeight+floatMargin}
        }
        anchors {
            bottom: parent.bottom
            bottomMargin: -1
        }
        width: dockHitbox.childrenRect.width
        height: 5
    }
    Item {
        id: region2
        states: State {
            name: "hover"; when: tlviewVisible == true && hoveredToplevels.length > 0
            PropertyChanges { target: region2; height: 225}
        }
        anchors {
            bottom: region1.top
        }
        width: dockHitbox.childrenRect.width
        height: 0 //hoveredTopLevels.length > 0? 500: 0
    }

    MouseArea {
        id: dockHitbox
        hoverEnabled: true
        anchors {
            fill: parent
            bottomMargin: -1
        }
        onEntered: {
            dock.hovered = true
        }
        onExited: {
            dock.hovered = false
        }
        Item {
            id: dockAnchor
            anchors {
                bottom: parent.bottom
                bottomMargin: -dockPanel.height
            }
            states: State {
                name: "hover"; when: dock.hovered == true
                PropertyChanges { target: dockAnchor; anchors.bottomMargin: floatMargin+1}
            }
            transitions: Transition {
                to: "hover"; reversible: true
                PropertyAnimation {
                    property: "anchors.bottomMargin"
                    duration: 150
                    easing {
                        type: Easing.OutBack; overshoot: 1
                    }
                }
            }
        }
        Rectangle {
            id: toplevelViews
            clip: true
            width: childrenRect.width+20
            radius: 20
            height: hoveredToplevels.length > 0? 220: 0
            x: Math.max(hoveredXCenter - (width/2), floatMargin)
            color: Qt.rgba(0.05,0.05,0.05,1)
            opacity: 0
            states: State {
                name: "visible"; when: tlviewVisible == true && hoveredToplevels.length > 0
                PropertyChanges { target: toplevelViews; opacity: 1}
            }
            transitions: Transition {
                to: "visible"; reversible: true
                PropertyAnimation {
                    property: "opacity"
                    duration: 200
                }
            }

            Behavior on x {
                NumberAnimation { 
                    duration: 100
                    easing {
                        type: Easing.OutBack; overshoot: 0
                    }
                }
            }

            Row {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                x: 10
                height: parent.height
                spacing: 10
                Repeater {
                    model: ScriptModel {values: toplevelViews.opacity > 0? hoveredToplevels: []}
                    ClippingRectangle {
                        color: Qt.rgba(0.05,0.05,0.05,0)
                        radius: 10
                        required property Toplevel modelData
                        width: toplevelView.width
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                        height: 200
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                modelData.activate()
                                hovered = false
                            }
                        }
                        ScreencopyView {
                            id: toplevelView
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                verticalCenter: parent.verticalCenter
                            }
                            live: true
                            captureSource: modelData
                            constraintSize: Qt.size(200*(16/9),200)
                        }
                    }
                }
            }
        }
        
        Rectangle {
            id: dockPanel
            anchors {
                bottom: dockAnchor.bottom
            }
            width: Math.max(childrenRect.width, 50)
            height: dockHeight
            color: Qt.rgba(0,0,0,1)
            radius: 15
            x: floatMargin
            clip: false
            Row {
                spacing: 0
                // non pinned apps
                Repeater {
                    model: ScriptModel {
                        values: pinnedApps
                    }
                    DockIcon {
                        id: icon
                        floatMargin: dock.floatMargin + 1
                        required property string modelData
                        appId: modelData
                        onEnter: () => {
                            hoveredClass = appId
                            hoveredXCenter = icon.x + (icon.width/2)
                            triggerTLView.restart()
                        }
                    }
                }
                Repeater {
                    model: ScriptModel {
                        values: Array.from(
                            new Set(
                                ToplevelManager.toplevels.values.map(toplevel => toplevel.appId)
                            )
                        ).filter(appId => !pinnedApps.includes(appId))
                    }
                    DockIcon {
                        id: icon
                        floatMargin: dock.floatMargin + 1
                        required property string modelData
                        appId: modelData
                        onEnter: () => {
                            hoveredClass = appId
                            hoveredXCenter = icon.x + (icon.width/2)
                            triggerTLView.restart()
                        }
                    }
                }
            }
        }
    }

	//Notif {}
}