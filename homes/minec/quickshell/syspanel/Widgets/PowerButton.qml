import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import QtQuick.Effects
import ".."
import "../.."

MouseArea {
    id: mousearea
    width: 30
    hoverEnabled: true
    height: 30
    property string iconPath: ""
    Image {
        id: icon
        smooth: true
        source: iconPath //`${Shared.iconsPath}/snowflake.svg`
        height: 18
        width: height
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        layer.enabled: true
        layer.effect: MultiEffect {
            colorizationColor: Shared.colors.on_surface
            colorization: 1
        }
        states: State {
            name: "hover"; when: mousearea.containsMouse
            PropertyChanges { target: icon; height: 22 }
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
    }
}