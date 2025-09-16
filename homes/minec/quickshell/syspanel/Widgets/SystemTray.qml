import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import ".."
import "../.."

Item {
	id: root
	width: systrayholder.implicitWidth
	height: 40
	//width: childrenRect.width// + 40
	Behavior on width {
		PropertyAnimation { 
			duration: 250 
			easing {
				type: Easing.OutBack
				overshoot: 1
			}
		}
	}
	
	RowLayout {
		id: systrayholder
		//implicitWidth: childrenRect.implicitWidth || 0
		spacing: 0
		anchors {
			top: parent.top
			bottom: parent.bottom
		}
		Repeater {
			model: SystemTray.items;
			Item {
				id: systraybutton
				required property var modelData;
				Layout.minimumWidth: parent.height
				Layout.minimumHeight: parent.height
				Layout.preferredWidth: parent.height
				width: parent.height
				Layout.fillWidth: true
				//readonly property alias menu: modelData.menu;

				MouseArea {
					id: systrayhitbox
					anchors.fill: systraybutton
					propagateComposedEvents: true
					acceptedButtons: Qt.AllButtons
					hoverEnabled: true
					onClicked: event => {
							event.accepted = true
							if (event.button == Qt.LeftButton) {
								modelData.activate()
							} else if (event.button == Qt.MiddleButton) {
								modelData.secondaryActivate()
							} else if (event.button == Qt.RightButton && modelData.hasMenu) {
								
								modelData.display(bar, systrayhitbox.mapToItem(bar.hitbox, systrayhitbox.x + systrayhitbox.width/2, 0).x, 1080)
								targetMenuOpen = !targetMenuOpen
							}
					}
					//parent: hitbox
				}
				Image {
					id: icon
					states: [
						State {
							name: "hovered"
							when: (systrayhitbox.containsMouse && !systrayhitbox.pressed)
							PropertyChanges { 
								target: icon
								anchors.margins: 4 
							}
						},
						State {
							name: "pressed"
							when: systrayhitbox.pressed
							PropertyChanges { 
								target: icon
								anchors.margins: 10
							}
						}
					]
					transitions: [
						Transition {
							from: "hovered"
							to: "pressed"
							reversible: false
							PropertyAnimation { 
								property: "anchors.margins"
								duration: 100
								easing {
									type: Easing.OutBack
									overshoot: 3
								}
							}
						},
						Transition {
							from: "pressed"
							reversible: false
							PropertyAnimation { 
								property: "anchors.margins"
								duration: 50
								easing {
									type: Easing.OutBack
									overshoot: 9
								}
							}
						},
						Transition {
							from: "hovered"
							reversible: false
							PropertyAnimation { 
								property: "anchors.margins"
								duration: 200
								easing {
									type: Easing.OutBack
									overshoot: 3
								}
							}
						},
						Transition {
							to: "hovered"
							reversible: false
							PropertyAnimation { 
								property: "anchors.margins"
								duration: 200
								easing {
									type: Easing.OutBack
									overshoot: 0
								}
							}
						}
					]
					anchors {
						fill: parent
						margins: 8
					}
					source: modelData.icon
				}
			}
		}
	}
}