import QtQuick
import ".."

MouseArea {
    id: hitbox
    width: 16
    height: 16
    property bool showWhen: true
    property color color: Shared.textColor
    Rectangle {
        anchors.fill: parent
        id: circle
        color: hitbox.color
        opacity: 0
        radius: width //temporary
        /*anchors {
            horizontalCenter: parent.left
            verticalCenter: parent.top
        }*/
        states: State {
            name: "showtime"; when: hitbox.showWhen
            PropertyChanges { target: circle; opacity: 1 }
        }
        transitions: Transition {
            to: "showtime"; reversible: false
            PropertyAnimation { 
                property: "opacity"; duration: 100
                easing {
                    type: Easing.InBack; overshoot: 0
                }
            }
        }
    }
}