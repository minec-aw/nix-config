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
	property bool fullHide: Hyprland.monitorFor(screen).activeWorkspace.hasFullscreen
	property bool transparentBackground: true
	property real mouseY: 0
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
			visible: mainpanel.anchors.leftMargin < parent.width-55
			onVisibleChanged: () => Hyprland.refreshToplevels()
			height: screen.height
			width: screen.width
			anchors.right: mainpanel.left
			anchors.rightMargin: -50
			AlternateBackgroundObject {
				anchors.fill: parent
				animate: true
				slidingFactor: Hyprland.monitorFor(screen).activeWorkspace.id || 0
			}
			WorkspacePanel {
				anchors.fill: parent
				isLive: parent.visible
				workspace: Hyprland.monitorFor(screen).activeWorkspace
			}
		}
		width: 555
		Item {
			id: mainpanel
			property real hoverBarHeight: 300
			property real hoverBarWidth: 50
			property real hoverBarY: Math.min(Math.max(panelcarrier.mouseY - (hoverBarHeight/2), 16), parent.height - hoverBarHeight -16)
			anchors {
				top: parent.top
				bottom: parent.bottom
				left: parent.left
				leftMargin: panelcarrier.opened? 50: (panelcarrier.hovered? parent.width-55: parent.width-5)
			}
			Behavior on anchors.leftMargin { 
				NumberAnimation { 
					duration: 240
					easing {
						type: Easing.InOutCubic
					}
				}
			 }
			width: 500
			// Background

			Rectangle {
				color: "black"
				width: parent.width
				height: parent.height
				layer.enabled: true
				layer.smooth: true
				layer.samples: 8
				layer.effect: ShaderEffect {
					required property Item source
					readonly property Item maskSource: mask

					fragmentShader: `${Shared.assetsPath}shaders/sidepanelmask.frag.qsb`
				}
				/*Rectangle {
					x: 200
					y: 60
					radius: 100
					width: 70
					height: 70
					color: "blue"
					SequentialAnimation on y {
						loops: Animation.Infinite

						NumberAnimation {
							from: 20
							to: 600
							duration: 8000
							easing.type: Easing.InOutSine
						}
						NumberAnimation {
							from: 600
							to: 20
							duration: 8000
							easing.type: Easing.InOutSine
						}
					}
					SequentialAnimation on x {
						loops: Animation.Infinite

						NumberAnimation {
							from: 0
							to: 200
							duration: 700
							easing.type: Easing.InOutSine
						}
						NumberAnimation {
							from: 200
							to: 0
							duration: 700
							easing.type: Easing.InOutSine
						}
					}
				}*/
			}
			// stole amazing mask from caelestia, thanks
			Rectangle {
				property real cornerRadius: 20
				id: mask
				color: Qt.rgba(0,0,0,0)
				anchors.fill: parent
				layer.enabled: true
				visible: false
				layer.smooth: true
				layer.samples: 4
				Rectangle {
					id: toprect
					width: mainpanel.hoverBarWidth
					height: mainpanel.hoverBarY
					bottomRightRadius: mask.cornerRadius
				}
				Rectangle {
					id: bottomrect
					y: mainpanel.hoverBarY + mainpanel.hoverBarHeight
					width: mainpanel.hoverBarWidth
					height: parent.height - mainpanel.hoverBarY + mainpanel.hoverBarHeight
					topRightRadius: mask.cornerRadius
				}
				ConcaveCorner {
					anchors.top: toprect.bottom
					anchors.topMargin: -1
					size: mask.cornerRadius
					orientation: "tl"
				}
				ConcaveCorner {
					anchors.bottom: bottomrect.top
					anchors.bottomMargin: -1
					size: mask.cornerRadius
					orientation: "bl"
				}
				
			}

			// Hover bar (the thing visible when hovering over edge)
			
			Item {
				id: hoverpanel
				y: mainpanel.hoverBarY
				height: mainpanel.hoverBarHeight
				width: mainpanel.hoverBarWidth

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
						//right: parent.right
						//left: parent.left
						horizontalCenter: parent.horizontalCenter
						rightMargin: 8
						leftMargin: 8
					}
				}
				//Power {}

			}

			// inner widgets
			Item {
				anchors {
					fill: parent
					leftMargin: 50
					rightMargin: 5
				}
				Power {}
			}

		}
	}

	//Notif {}
}