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
    property var hyprlandToplevels: Hyprland.toplevels.values.filter(toplevel => toplevel.wayland? toplevel.wayland.appId == appId: false)
    property var toplevels: ToplevelManager.toplevels.values.filter(toplevel => toplevel.appId == appId)
    property var onEnter
    property var icon: Quickshell.iconPath(desktopEntry.icon)
    Timer {
        id: iconFallbackTimer
        interval: 5
        onTriggered: {
            
            console.log("Fallback icon time for", appId)
            const pid = hyprlandToplevels[0].lastIpcObject.pid
            if (pid) {
                iconFallback.command = [
                    "sh", "-c",
                    `
                    WINE_PATH=$(cat /proc/${pid}/cmdline | tr '\\0' '\\n' | grep -m 1 '\\.exe$')
                    if [[ -z "$WINE_PATH" ]]; then
                        exit 1
                    fi
                    LINUX_PATH_1=\${WINE_PATH//\\\\//}
                    LINUX_EXE_PATH=\${LINUX_PATH_1:2}
                    BASE64_DATA=$(wrestool -x -t14 "$LINUX_EXE_PATH" | magick ICO:-[0] PNG:- | base64 -w 0)
                    echo "data:image/png;base64,$BASE64_DATA"
                    `
                ]
                iconFallback.running = true
            }
        }
    }
    Process {
        id: iconFallback
        command: [ "sh", "-c" ]
        stdout: StdioCollector {
            
            onStreamFinished: {
                icon = this.text

            }
        }
    }
    Component.onCompleted: {
        if (hyprlandToplevels.length > 0 && !icon) {
            Hyprland.refreshToplevels()
            iconFallbackTimer.start()  
        }
    }
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
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: icon
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        anchors.bottomMargin: -floatMargin
        onClicked: () => {
            if (toplevels.length > 0) {
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