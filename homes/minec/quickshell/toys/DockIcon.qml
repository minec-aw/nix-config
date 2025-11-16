import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick.Effects

Item {
    id: dockItem
    width: 68
    height: 68
    property var floatMargin: 10
    required property string appId
    property DesktopEntry desktopEntry: DesktopEntries.byId(appId)
    property var toplevels: ToplevelManager.toplevels.values.filter(toplevel => toplevel.appId == appId)
    property var onEnter
    Rectangle {
        id: activeHighlight
        anchors {
            fill: parent
            margins: 4
        }
        states: State {
            name: "active"; when: ToplevelManager.activeToplevel.appId == appId && toplevels.length > 0
            PropertyChanges { target: activeHighlight; color: Qt.rgba(1,1,1,0.05)}
        }
        transitions: Transition {
            to: "active"; reversible: true
            ColorAnimation { 
                duration: 100
                easing {
                    type: Easing.OutBack; overshoot: 0
                }
            }
        }
        color: Qt.rgba(1,1,1,0)
        radius: 15 - anchors.margins
    }
    Image {
        anchors {
            fill: parent
            margins: 12
        }
        Component.onCompleted: () => {
            console.log("App!!", appId)
        }
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: Quickshell.iconPath(desktopEntry.icon)
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        anchors.bottomMargin: -floatMargin
        onClicked: () => {
            if (toplevels.length > 0) {
                console.log(toplevels)
                if (toplevels.includes(ToplevelManager.activeToplevel)) {
                    const toplevelIndex = toplevels.indexOf(ToplevelManager.activeToplevel)+1
                    if (toplevelIndex+1 > toplevels.length-1) {
                        toplevels[0].activate()
                    } else {
                        toplevels[toplevelIndex+1].activate()
                    }
                } else {
                    toplevels[0].activate()
                }
                toplevels[0].activate()
            } else if (desktopEntry) {
                desktopEntry.execute()
            }
        }
        onEntered: {
            dockItem.onEnter()
        }
    }
    // process dots
    Row {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        height: 10
        width: childrenRect.width
        spacing: 1
        Repeater {
            model: Math.min(toplevels.length, 6)
            Rectangle {
                id: appDot
                width: 6
                height: 6
                radius: 3
                color: Qt.rgba(1,1,1,0.3)
                states: State {
                    name: "active"; when: ToplevelManager.activeToplevel.appId == appId
                    PropertyChanges { target: appDot; color: Qt.rgba(0.94, 0.18, 0.33)}
                }
                transitions: Transition {
                    to: "active"; reversible: true
                    ColorAnimation { 
                        duration: 100
                        easing {
                            type: Easing.OutBack; overshoot: 0
                        }
                    }
                }
            }
        }

    }
}