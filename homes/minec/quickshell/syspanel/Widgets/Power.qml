import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import QtQuick.Effects
import ".."
import "../.."

Rectangle {
	id: power
	width: 30
	anchors {
        top: parent.top
        bottom: parent.bottom
    }
	bottomLeftRadius: 0
	topLeftRadius: 0
	radius: height
	property bool shown: false
	clip: true
	color: Qt.rgba(0,0,0,0)
	property Process sleep: Process {
		command: ["systemctl", "suspend"]
		running: false
	}
	property Process poweroff: Process {
		command: ["systemctl", "poweroff"]
		running: false
	}
	property Process reboot: Process {
		command: ["systemctl", "reboot"]
		running: false
	}

	states: [
		State {
			name: "opened"; when: power.shown
			PropertyChanges { target: power; width: 30*5; color: Qt.rgba(0,0,0,1) }
		}
	]
	transitions: Transition {
		to: "opened"; reversible: true
		ParallelAnimation {
			PropertyAnimation { 
				property: "width"; duration: 200
				easing {
					type: Easing.OutBack; overshoot: 1
				}
			}
			ColorAnimation {
				duration: 100
				easing {
					type: Easing.InOutCubic
				}
			}
		}
	}

	MouseArea {
		id: menuopener
		width: 30
		height: 30
		hoverEnabled: true
		onClicked: () => {
			power.shown = !power.shown
		}
		anchors.right: parent.right
		
		Item {
			id: iconholder
			height: 18
			width: height
			states: State {
				name: "hover"; when: menuopener.containsMouse
				PropertyChanges { target: iconholder; height: 22 }
			}
			anchors {
				verticalCenter: parent.verticalCenter
				horizontalCenter: parent.horizontalCenter
			}
			transitions: Transition {
				to: "hover"; reversible: true
				PropertyAnimation { 
					property: "height"; duration: 100
					easing {
						type: Easing.OutBack; overshoot: 0
					}
				}
			}
			Image {
				id: initialicon
				smooth: true
				source: `${Shared.iconsPath}/power.svg`
				anchors.fill: parent
				states: State {
					name: "opened"; when: power.shown
					PropertyChanges { target: initialicon; opacity: 0 }
				}
				layer.enabled: true
				layer.effect: MultiEffect {
					colorizationColor: Shared.colors.on_surface
					colorization: 1
				}
				transitions: Transition {
					to: "opened"; reversible: true
					PropertyAnimation { 
						property: "opacity"; duration: 200
						easing {
							type: Easing.OutBack; overshoot: 0
						}
					}
				}
			}
			Image {
				id: closeicon
				smooth: true
				source: `${Shared.iconsPath}/chevron-left.svg`
				anchors.fill: parent
				opacity: 0
				states: State {
					name: "opened"; when: power.shown
					PropertyChanges { target: closeicon; opacity: 1 }
				}
				layer.enabled: true
				layer.effect: MultiEffect {
					colorizationColor: Shared.colors.on_surface
					colorization: 1
				}
				transitions: Transition {
					to: "opened"; reversible: true
					PropertyAnimation { 
						property: "opacity"; duration: 100
						easing {
							type: Easing.OutBack; overshoot: 0
						}
					}
				}
			}
		}
	}
	PowerButton {
		id: hibernate
		anchors.right: menuopener.left
		iconPath: `${Shared.iconsPath}/snowflake.svg`
		onClicked: () => {
			Shared.barsShown = false
			power.hibernate.running = true
		}
	}
	PowerButton {
		id: shutdown
		anchors.right: hibernate.left
		iconPath: `${Shared.iconsPath}/power.svg`
		onClicked: () => {
			Shared.barsShown = false
			power.poweroff.running = true
		}
	}
	PowerButton {
		id: restart
		anchors.right: shutdown.left
		iconPath: `${Shared.iconsPath}/rotate-ccw.svg`
		onClicked: () => {
			Shared.barsShown = false
			power.reboot.running = true
		}
	}
	PowerButton {
		id: sleep
		anchors.right: restart.left
		iconPath: `${Shared.iconsPath}/moon.svg`
		onClicked: () => {
			Shared.barsShown = false
			power.sleep.running = true
		}
	}
}