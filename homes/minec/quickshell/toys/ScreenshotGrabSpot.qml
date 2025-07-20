import QtQuick
import ".."

MouseArea {
    id: hitbox
    width: 20
    height: 20
    property string corner: "topleft"
    property bool fullHide: false
    property bool showWhen: true
    property color color: Shared.textColor
    property double unshownThickness: 1
    property double thickness: 3
    states: State {
        name: "showtime"; when: !hitbox.showWhen
        PropertyChanges { target: hitbox; thickness: unshownThickness}
    }
    transitions: [
        Transition {
            from: ""
            to: "showtime"
            reversible: true
            PropertyAnimation { 
                property: "thickness"; duration: 200
                easing {
                    type: Easing.OutCirc
                    //bezierCurve: [0.05, 0.7, 0.1, 1]
                }
            }
        },
        Transition {
            from: "showtime"
            to: ""
            reversible: true
            PropertyAnimation { 
                property: "thickness"; duration: 300
                easing {
                    type: Easing.OutCirc
                    //bezierCurve: [0.05, 0.7, 0.1, 1]
                }
            }
        } 
    ]
    //0.05, 0.7, 0.1, 1
    Item {
        id: visualhandlecontainer
        width: hitbox.width
        height: hitbox.height

        states: State {
            name: "showtime"
            when: !hitbox.showWhen
            PropertyChanges { 
                target: visualhandlecontainer;
                x: corner == "topleft" || corner == "bottomleft" ? hitbox.width/2 - unshownThickness*2 : -(hitbox.width/2 - unshownThickness*2)
                y: corner == "topleft" || corner == "topright"? hitbox.height/2 - unshownThickness*2 : -(hitbox.height/2 - unshownThickness*2)
            }
        }
        transitions: [
            Transition {
                from: ""
                to: "showtime"
                ParallelAnimation {
                    NumberAnimation { 
                        property: "x"; duration: 200
                        easing {
                            type: Easing.OutExpo
                            //bezierCurve: [0.05, 0.7, 0.1, 1]
                        }
                    }
                    NumberAnimation { 
                        property: "y"; duration: 200
                        easing {
                            type: Easing.OutExpo
                            //bezierCurve: [0.05, 0.7, 0.1, 1]
                        }
                    }
                }
            },
            Transition {
                to: ""
                from: "showtime"
                ParallelAnimation {
                    NumberAnimation { 
                        property: "x"; duration: 300
                        easing {
                            type: Easing.OutBack
                            overshoot: 3
                            //bezierCurve: [0.05, 0.7, 0.1, 1]
                        }
                    }
                    NumberAnimation { 
                        property: "y"; duration: 300
                        easing {
                            type: Easing.OutBack
                            overshoot: 3
                            //bezierCurve: [0.05, 0.7, 0.1, 1]
                        }
                    }
                }
            }
            
        ]

        Rectangle {
            id: leftrighthandle
            anchors {
                left: corner == "topleft" || corner == "bottomleft"? parent.left: undefined
                top: parent.top
                bottom: parent.bottom
                right: corner == "topright" || corner == "bottomright"? parent.right: undefined
            }
            width: thickness
            radius: thickness/2
            states: State {
                name: "fullhide"; when: hitbox.fullHide
                PropertyChanges { target: leftrighthandle; opacity: 0 }
            }
            transitions: Transition {
                from: "fullhide"; to: ""; reversible: false
                PropertyAnimation { 
                    property: "opacity"; duration: 200
                    easing {
                        type: Easing.InBack; overshoot: 0
                    }
                }
            }
        }
        Rectangle {
            id: topbottomhandle
            anchors {
                right: parent.right
                top: corner == "topleft" || corner == "topright"? parent.top: undefined
                bottom: corner == "bottomleft" || corner == "bottomright"? parent.bottom: undefined
                left: parent.left
            }
            height: thickness
            radius: thickness/2

            states: State {
                name: "fullhide"; when: hitbox.fullHide
                PropertyChanges { target: topbottomhandle; opacity: 0 }
            }
            transitions: Transition {
                from: "fullhide"; to: ""
                PropertyAnimation { 
                    property: "opacity"; duration: 200
                    easing {
                        type: Easing.OutCirc; overshoot: 0
                    }
                }
            }
        }
    }
    
    /*Rectangle {
        anchors.fill: parent
        id: circle
        color: hitbox.color
        opacity: 0
        radius: width //temporary
        /*anchors {
            horizontalCenter: parent.left
            verticalCenter: parent.top
        }
        states: State {
            name: "showtime"; when: hitbox.showWhen
            PropertyChanges { target: circle; opacity: 0 }
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
    }*/
}