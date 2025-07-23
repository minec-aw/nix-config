import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import "Widgets"
import ".."
import Quickshell.Services.Mpris
import QtQuick.Effects

PanelWindow {
	id: panel
	property bool pinned: false
	property bool opened: false
	property bool hover: false
	property var expandedPanel
	property bool fullHide: Hyprland.monitorFor(screen).activeWorkspace.hasFullscreen
	color: "transparent"
	
	HyprlandFocusGrab {
      id: grab
      windows: [panel]
	  onActiveChanged: () => {
		if (active == false) {
			panel.hover = false
			panel.opened = false
		}
	  }
	}
	Component.onCompleted: () => {
		Shared.panels.push(panel)
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

	onOpenedChanged: () => {
		if (opened == true) {
			grab.active = true
			panelhitbox.state = "nothovered" //required otherwise doesnt shrink when clicking off
		} else {
			grab.active = false
		}
	}
	
	anchors {
		right: true
		bottom: true
	}
	Region {
		id: regin
		item: panelhitbox
	}
	mask: regin
	MouseArea {
		id: panelhitbox
		hoverEnabled: true
		onClicked: () => {
			opened = true
		}
		onContainsMouseChanged: () => {
			panel.hover = containsMouse
		}
		anchors {
			right: parent.right
			bottom: parent.bottom
			left: parent.left
		}
		height: 1
		states: [
		State {
			name: "opened"; when: panel.opened
			AnchorChanges { target: panelhitbox; anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.left: parent.left; }
		},
		State {
			name: "hovered"; when: panel.hover
			PropertyChanges {target: panelhitbox; height: 62}
		},
		State { //this is required otherwise it goes crazy ahhgfhghggh and stupid hahahhahahahhhh
			name: "nothovered"; when: !panel.hover
			PropertyChanges {target: panelhitbox; height: fullHide? 0: 1}
		}
		]
	}

	//Notif {}

	property int maxHeight: 600 //the height it expands to
	Rectangle {
		id: bigpanel
		property int margin: 6
		anchors.bottomMargin: -50
		x: margin
		width: panel.width-(margin*2)
		radius: 25
		height: 50
		color: Qt.rgba(Shared.colors.background.r, Shared.colors.background.g, Shared.colors.background.b,0.7)
		anchors.bottom: panelhitbox.bottom
		border {
			width: 1
			color: Shared.colors.outline
			pixelAligned: false
		}
		states: [
			State {
				name: "opened"; when: panel.opened
				PropertyChanges {target: bigpanel; height: maxHeight; anchors.bottomMargin: margin}
			},
			State {
				name: "hovered"; when: panel.hover
				PropertyChanges {target: bigpanel; anchors.bottomMargin: margin}
			}
		]
		transitions: [
			Transition {
				from: ""; to: "hovered"; reversible: true
				ParallelAnimation {
					PropertyAnimation { 
						property: "anchors.bottomMargin"; duration: 200
						easing {
							type: Easing.OutBack; overshoot: 2
						}
					}
				}
			},
			Transition {
				from: ""; to: "opened"
				SequentialAnimation {
					PropertyAnimation { 
						property: "anchors.bottomMargin"; duration: 200
						easing {
							type: Easing.OutBack; overshoot: 2
						}
					}
					SequentialAnimation {
						PropertyAnimation { 
							property: "height"; duration: 150
							easing {
								type: Easing.InQuart
							}
						}
						PropertyAnimation { 
							property: "anchors.bottomMargin"
							duration: 100
							to: bigpanel.margin + 20
							easing {
								type: Easing.OutCirc
							}
						}
						PropertyAnimation { 
							property: "anchors.bottomMargin"
							duration: 100
							to: bigpanel.margin
							easing {
								type: Easing.OutCirc
							}
						}
					}
				}
			},
			Transition {
				from: "opened"; to: ""
				SequentialAnimation {
					PropertyAnimation { 
						property: "height"; duration: 150
						easing {
							type: Easing.InQuart
						}
					}
					PropertyAnimation { 
						property: "anchors.bottomMargin"; duration: 200
						easing {
							type: Easing.InBack; overshoot: 2
						}
					}
				}
			},
			Transition {
				from: "hovered"; to: "opened"; reversible: true
				ParallelAnimation {
					PropertyAnimation { 
						property: "anchors.bottomMargin"; duration: 200
						easing {
							type: Easing.OutBack; overshoot: 2
						}
					}
					SequentialAnimation {
						PropertyAnimation { 
							property: "height"; duration: 150
							easing {
								type: Easing.InQuart
							}
						}
						PropertyAnimation { 
							property: "anchors.bottomMargin"
							duration: 100
							to: bigpanel.margin + 20
							easing {
								type: Easing.OutCirc
							}
						}
						PropertyAnimation { 
							property: "anchors.bottomMargin"
							duration: 100
							to: bigpanel.margin
							easing {
								type: Easing.OutCirc
							}
						}
					}
				}
			}
		]
		ClippingRectangle {
			//things go in here
			anchors.fill: parent
			color: "transparent"
			radius: parent.radius
			Item { //the item that contains all the expanded objects
				anchors {
					bottom: parent.bottom
					left: parent.left
					right: parent.right
				}
				height: maxHeight
				/*Image {
					anchors.fill: parent
					source: Mpris.players.values[0].trackArtUrl
					layer.enabled: true
					layer.effect: MultiEffect {
						blur: 1
						blurMax: 100
						blurMultiplier: 2
						colorizationColor: Qt.rgba(0,0,0,0.7)
						colorization: 1
						contrast: 1
						blurEnabled: true
						autoPaddingEnabled: true
						//maskSource: bigpanel
					}
				}*/
				
				Clock {
					id: clock
					x: 8+6
					anchors.bottom: parent.bottom
				}
				Item {
					x: clock.width
					id: sysstats
					anchors.left: clock.right
					anchors.bottom: parent.bottom
					anchors.leftMargin: 6+8
					width: 370
					height: stats.height
					SystemStats {
						id: stats
						anchors.horizontalCenter: parent.horizontalCenter
					}
				}
				Image {
					id: notificon
					smooth: true
					source: `${Shared.iconsPath}/bell.svg`
					height: 24
					width: height
					layer.enabled: true
					layer.effect: MultiEffect {
						colorizationColor: Shared.colors.on_surface
						colorization: 1
					}
					anchors {
						right: parent.right
						bottom: parent.bottom
						bottomMargin: (50-24)/2
						rightMargin: (50-24)/2
					}
				}
				Power {
					x: 6
					y: 6
				}
				/*ScrollView {
					width: 200
					height: 200
				}*/

			}
		}
	}
	exclusionMode: ExclusionMode.Ignore
	implicitHeight: screen.height
	implicitWidth: 520
}