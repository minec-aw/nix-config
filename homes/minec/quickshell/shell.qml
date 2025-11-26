import Quickshell
import QtQuick

ShellRoot {
    id: root
    Timer {
        id: qsReload
        interval: 100
        onTriggered: {
            Quickshell.reload(false);
        }
    }
    PersistentProperties {
        id: persist
        reloadableId: "desktopIconsReload"

        property var inhibit: 0
    }
    Connections {
        target: persist

        function onLoaded() {
            if (persist.inhibit == 0) {
                persist.inhibit = 1;
                qsReload.start();
            }
        }
    }
    Connections {
        target: Quickshell

        function onReloadCompleted() {
            if (persist.inhibit == 1) {
                Quickshell.inhibitReloadPopup();
                persist.inhibit = 2;
            }
        }
    }

    Variants {
        model: Quickshell.screens
        Scope {
            property var modelData
            Dock {
                id: bar
                screen: modelData
            }
            BackgroundAlternate {
                screen: modelData
            }
            LazyLoader {
                active: Shared.screenshotTaken
                Screenshot {
                    screen: modelData
                }
            }
            // a
            //Overview {screen: modelData; visible: Shared.overviewVisible && Hyprland.focusedMonitor == Hyprland.monitorFor(modelData)}
        }
    }
}
