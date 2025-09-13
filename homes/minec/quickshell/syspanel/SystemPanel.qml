import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import "Widgets"
import ".."
import "../toys"
import Quickshell.Services.Mpris
import QtQuick.Effects

PanelWindow {
	id: panelcarrier
	property bool pinned: false
	property bool opened: false
	property bool hovered: false
	property var expandedPanel
	property bool fullHide: Hyprland.monitorFor(screen).activeWorkspace.hasFullscreen
	property var toplevels: Hyprland.monitorFor(screen).activeWorkspace.toplevels
	property bool transparentBackground: true
	property real mouseY: 0
	onToplevelsChanged: () => {
		transparentBackground = Hyprland.monitorFor(screen).activeWorkspace.toplevels.values.length == 0
	}
	color: Qt.rgba(0,0,0,0)
	
	HyprlandFocusGrab {
      id: grab
      windows: [panelcarrier]
	  onActiveChanged: () => {
		if (active == false) {
			panel.hover = false
			panel.opened = false
		}
	  }
	}
	Component.onCompleted: () => {
		Shared.panels.push(panelcarrier)
		console.log(Hyprland.monitorFor(screen).activeWorkspace.toplevels.values.length)
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
		top: true
	}
	exclusionMode: ExclusionMode.Ignore
	implicitHeight: 200

	Region {
		id: regin
		item: panelhitbox
	}
	mask: regin
	Item {
		id: panelhitbox
		anchors {
			right: parent.right
			bottom: parent.bottom
			top: parent.top
			rightMargin: -5
			bottomMargin: -5
		}
		width: panelcarrier.opened? 550: (panelcarrier.hovered? 50: (panelcarrier.fullHide? 0: 10))
		states: State {
			name: "hovered"; when: panelcarrier.hovered
			PropertyChanges {target: panelhitbox; height: Shared.panelHeight+5}
		}
	}
	MouseArea {
		id: hoverdetector
		hoverEnabled: true
		onClicked: () => {
			panelcarrier.opened = !panelcarrier.opened
		}
		onContainsMouseChanged: () => {
			panelcarrier.hovered = containsMouse
			if (containsMouse == true) {
				panelcarrier.mouseY = mouseY
			}
		}
		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			leftMargin: -5
			rightMargin: -5
			bottomMargin: -5
		}
		Item {
			visible: mainpanel.x != hoverdetector.width-5
			onVisibleChanged: () => Hyprland.refreshToplevels()
			height: screen.height
			width: screen.width
			anchors.right: mainpanel.left
			anchors.rightMargin: 0
			AlternateBackgroundObject {
				anchors.fill: parent
				animate: false
				slidingFactor: Hyprland.monitorFor(screen).activeWorkspace.id || 0
			}
			WorkspacePanel {
				anchors.fill: parent
				isLive: parent.visible
				workspace: Hyprland.monitorFor(screen).activeWorkspace
			}
		}
		width: 555
		Rectangle {
			id: mainpanel
			anchors {
				top: parent.top
				bottom: parent.bottom
				left: parent.left
				leftMargin: parent.width-5
			}
			color: Qt.rgba(0,0,0,1)
			width: 500
			states: State {
				name: "opened"; when: panelcarrier.opened
				PropertyChanges {target: mainpanel; anchors.leftMargin: 50}
			}
			transitions: Transition {
				to: "opened"
				reversible: true
				ParallelAnimation {
					NumberAnimation { 
						properties: "anchors.leftMargin"
						duration: 300
						easing {
							type: Easing.InOutCubic
						}
					}                    
				}
			}

			Power {}

		}
		Rectangle {
			id: hoverpanel
			anchors {
				right: mainpanel.left
				rightMargin: -width
			}
			ConcaveCorner {
				orientation: "br"
				size: 20
				y: -19
				x: 30
			}
			ConcaveCorner {
				orientation: "tr"
				size: 20
				y: parent.height-1
				x: 30
			}
			
			radius: 20
			color: Qt.rgba(0,0,0,1)
			y: Math.min(Math.max(panelcarrier.mouseY - (height/2), 16), parent.height - height -16)
			height: 300
			bottomRightRadius: 0
			topRightRadius: 0
			width: 52
			states: State {
				name: "revealed"; when: panelcarrier.hovered || panelcarrier.opened
				PropertyChanges {target: hoverpanel; anchors.rightMargin: -2}
			}
			transitions: Transition {
				to: "revealed"
				reversible: true
				ParallelAnimation {
					NumberAnimation { 
						properties: "anchors.rightMargin"
						duration: 200
						easing {
							type: Easing.InOutCubic
						}
					}                    
				}
			}

			Clock {
				id: clock
				anchors {
					top: parent.top
					topMargin: 10
					right: parent.right
					//horizontalCenter: parent.horizontalCenter
					left: parent.left
					rightMargin: 12
					leftMargin: 10
				}
			}

			SystemStats {
				id: stats
				anchors {
					top: clock.bottom
					topMargin: 10
					right: parent.right
					left: parent.left
					//horizontalCenter: parent.horizontalCenter
					rightMargin: 8
					leftMargin: 8
				}
			}
			//Power {}

		}
	}

	//Notif {}
}