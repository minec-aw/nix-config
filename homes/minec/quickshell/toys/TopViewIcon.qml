import QtQuick

MouseArea {
    id: button
    property color hoverColor: Qt.rgba(1, 0, 0, 1)
    property color activeColor: Qt.rgba(1, 0, 0, 1)
    property bool active: false
    property string iconSource: ""
    width: 28
    height: 28
    hoverEnabled: true
    Rectangle {
        id: backing
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0)
        radius: 4
        states: [
            State {
                name: "active"
                when: button.active == true
                PropertyChanges {
                    backing.color: button.activeColor
                }
            },
            State {
                name: "hover"
                when: button.containsMouse == true
                PropertyChanges {
                    backing.color: button.hoverColor
                }
            }
        ]
        transitions: [
            Transition {
                to: "active"
                reversible: true
                ColorAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            },
            Transition {
                to: "hover"
                reversible: true
                ColorAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }
        ]
    }
    Image {
        id: icon
        source: button.iconSource
        anchors {
            fill: parent
            margins: 4
        }
        states: [
            State {
                name: "click"
                when: button.containsPress == true
                PropertyChanges {
                    target: icon
                    anchors.margins: 6
                }
            },
            State {
                name: "hover"
                when: button.containsMouse == true
                PropertyChanges {
                    target: icon
                    anchors.margins: 0
                }
            }
        ]
        transitions: [
            Transition {
                to: "click"
                reversible: false
                PropertyAnimation {
                    property: "anchors.margins"
                    duration: 100
                    easing {
                        type: Easing.OutBack
                        overshoot: 0
                    }
                }
            },
            Transition {
                from: "click"
                reversible: false
                PropertyAnimation {
                    property: "anchors.margins"
                    duration: 150
                    easing {
                        type: Easing.OutBack
                        overshoot: 7
                    }
                }
            },
            Transition {
                to: "hover"
                reversible: true
                PropertyAnimation {
                    property: "anchors.margins"
                    duration: 100
                }
            }
        ]
    }
}
