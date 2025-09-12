import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."
import "../.."

Item {
	id: clock
    height: 50
    width: 60
    Rectangle {
        width: parent.width + 8*2
        height: 50-(6*2)
        radius: 200 //just make it circly
        color: Shared.colors.surface_container
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Text {
        id: smalltime
        text: `${(Shared.time.getHours()%12).toString().padStart(2, "0")}:${(Shared.time.getMinutes()).toString().padStart(2, "0")}`
        color: Shared.colors.on_surface
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.fill: parent
        font {
            pointSize: 18
            family: "Noto Sans"
            bold: true
        }
    }
    /*PanelMouseArea {
        id: togglingarea
		anchors.fill: parent
		onClicked: bar.expandPanel(parent)
        
        Item {
            id: expanded
            anchors.fill: parent
            clip: true
            opacity: 0
            states: State {
                name: "showme"; when: clock.opened
                PropertyChanges { target: expanded; opacity: 1 }
            }
            transitions: Transition {
                to: "showme"; reversible: true
                PropertyAnimation { 
                    property: "opacity"; duration: 300
                    easing {
                        type: Easing.InOutQuart
                    }
                }  
            }
            Text {
                x: 10
                y: 5
                color: Qt.hsva(7/9,0.1,0.9)
                font {
                    pointSize: 18
                    //family: "SFPro"
                    bold: true
                }
                text: `${Shared.days[Shared.time.getDay()]} ${Shared.time.getDate()} ${Shared.months[Shared.time.getMonth()]}, ${Shared.time.getFullYear()}`
            }
            Text {
                x: 10
                y: 35
                color: Qt.hsva(7/9,0.1,0.6)
                font {
                    pointSize: 10
                    //family: "SFPro"
                }
                text: Shared.time.toLocaleTimeString();
            }
            AnimatedImage {
                id: invisible
                y: 60
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                height: 170
                width: sourceSize.width*(height/sourceSize.height)
                source: "wa.gif"
            }
        }
    }*/
}