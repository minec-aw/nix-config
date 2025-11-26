import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland

Item {
    id: dockItem
    width: 68
    height: 68
    property double floatMargin: 10
    required property string appId
    property DesktopEntry desktopEntry: DesktopEntries.byId(appId)
    property list<HyprlandToplevel> hyprlandToplevels: Hyprland.toplevels.values.filter(toplevel => toplevel.wayland ? toplevel.wayland.appId == appId : false)
    property list<Toplevel> toplevels: ToplevelManager.toplevels.values.filter(toplevel => toplevel.appId == appId)
    property var onEnter
    property var onExit
    property Toplevel activeToplevel: ToplevelManager.activeToplevel
    property var icon: Quickshell.iconPath(guessIcon(appId)) ?? ""
    Timer {
        id: iconFallbackTimer
        interval: 5
        onTriggered: {
            console.log("Fallback icon for", dockItem.appId);
            const pid = dockItem.hyprlandToplevels[0].lastIpcObject.pid;
            if (pid) {
                iconFallback.command = ["sh", "-c", `
                    WINE_PATH=$(cat /proc/${pid}/cmdline | tr '\\0' '\\n' | grep -m 1 '\\.exe$')
                    if [[ -z "$WINE_PATH" ]]; then
                        exit 1
                    fi
                    LINUX_PATH_1=\${WINE_PATH//\\\\//}
                    LINUX_EXE_PATH=\${LINUX_PATH_1:2}
                    BASE64_DATA=$(wrestool -x -t14 "$LINUX_EXE_PATH" | magick ICO:-[0] PNG:- | base64 -w 0)
                    echo "data:image/png;base64,$BASE64_DATA"
                    `];
                iconFallback.running = true;
            }
        }
    }
    Process {
        id: iconFallback
        command: ["sh", "-c"]
        stdout: StdioCollector {

            onStreamFinished: {
                if (this.text.startsWith("data:image/png;base64,")) {
                    icon = this.text;
                } else {
                    icon = Quickshell.iconPath("application-x-executable");
                }
            }
        }
    }

    function iconExists(iconName) {
        if (!iconName || iconName.length == 0)
            return false;
        return (Quickshell.iconPath(iconName, true).length > 0) && !iconName.includes("image-missing");
    }
    function getReverseDomainNameAppName(str) {
        return str.split('.').slice(-1)[0];
    }

    function getKebabNormalizedAppName(str) {
        return str.toLowerCase().replace(/\s+/g, "-");
    }

    function getUndescoreToKebabAppName(str) {
        return str.toLowerCase().replace(/_/g, "-");
    }

    function guessIcon(str) {
        if (!str || str.length == 0)
            return "image-missing";

        // Quickshell's desktop entry lookup
        const entry = DesktopEntries.byId(str);
        if (entry)
            return entry.icon;

        // Icon exists -> return as is
        if (iconExists(str))
            return str;

        // Simple guesses
        const lowercased = str.toLowerCase();
        if (iconExists(lowercased))
            return lowercased;

        const reverseDomainNameAppName = getReverseDomainNameAppName(str);
        if (iconExists(reverseDomainNameAppName))
            return reverseDomainNameAppName;

        const lowercasedDomainNameAppName = reverseDomainNameAppName.toLowerCase();
        if (iconExists(lowercasedDomainNameAppName))
            return lowercasedDomainNameAppName;

        const kebabNormalizedGuess = getKebabNormalizedAppName(str);
        if (iconExists(kebabNormalizedGuess))
            return kebabNormalizedGuess;

        const undescoreToKebabGuess = getUndescoreToKebabAppName(str);
        if (iconExists(undescoreToKebabGuess))
            return undescoreToKebabGuess;

        // Search in desktop entries
        /*const iconSearchResults = Fuzzy.go(str, preppedIcons, {
            all: true,
            key: "name"
        }).map(r => {
            return r.obj.entry
        });
        if (iconSearchResults.length > 0) {
            const guess = iconSearchResults[0].icon
            if (iconExists(guess)) return guess;
        }*/
        const heuristicEntry = DesktopEntries.heuristicLookup(str);
        if (heuristicEntry)
            return heuristicEntry.icon;
        if (hyprlandToplevels.length > 0 && !icon) {
            Hyprland.refreshToplevels();
            iconFallbackTimer.start();
        }
        return "";
    }
    Rectangle {
        id: activeHighlight
        anchors {
            fill: parent
            margins: 4
        }
        states: State {
            name: "active"
            when: activeToplevel && activeToplevel.appId == appId && toplevels.length > 0
            PropertyChanges {
                target: activeHighlight
                color: Qt.rgba(1, 1, 1, 0.05)
            }
        }
        transitions: Transition {
            to: "active"
            reversible: true
            ColorAnimation {
                duration: 100
                easing {
                    type: Easing.OutBack
                    overshoot: 0
                }
            }
        }
        color: Qt.rgba(1, 1, 1, 0)
        radius: 15 - anchors.margins
    }
    Image {
        id: iconImage
        anchors {
            fill: parent
            margins: 12
        }
        states: [
            State {
                name: "click"
                when: mouseArea.containsPress == true
                PropertyChanges {
                    target: iconImage
                    anchors.margins: 16
                }
            },
            State {
                name: "hover"
                when: mouseArea.containsMouse == true
                PropertyChanges {
                    target: iconImage
                    anchors.margins: 8
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
                        overshoot: 5
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
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: icon
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        anchors.bottomMargin: -floatMargin
        onClicked: () => {
            if (toplevels.length > 0) {
                if (activeToplevel && toplevels.includes(activeToplevel)) {
                    const toplevelIndex = toplevels.indexOf(activeToplevel) + 1;
                    if (toplevelIndex + 1 > toplevels.length - 1) {
                        toplevels[0].activate();
                    } else {
                        toplevels[toplevelIndex + 1].activate();
                    }
                } else {
                    toplevels[0].activate();
                }
                toplevels[0].activate();
            } else if (desktopEntry) {
                desktopEntry.execute();
            }
        }
        onEntered: {
            if (onEnter) {
                dockItem.onEnter();
            }
        }
        onExited: {
            if (onExit) {
                dockItem.onExit();
            }
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
                color: Qt.rgba(1, 1, 1, 0.3)
                states: State {
                    name: "active"
                    when: activeToplevel && activeToplevel.appId == appId
                    PropertyChanges {
                        target: appDot
                        color: Qt.rgba(0.94, 0.18, 0.33)
                    }
                }
                transitions: Transition {
                    to: "active"
                    reversible: true
                    ColorAnimation {
                        duration: 100
                        easing {
                            type: Easing.OutBack
                            overshoot: 0
                        }
                    }
                }
            }
        }
    }
}
