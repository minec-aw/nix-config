import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import "toys"

PanelWindow {
    id: dock
    property bool pinned: false
    property bool opened: false
    property bool hovered: false
    property bool fullHide: ToplevelManager.activeToplevel ? ToplevelManager.activeToplevel.fullscreen : false
    property bool transparentBackground: true
    property real mouseY: 0
    property double floatMargin: 10
    property list<string> pinnedApps: ["zen-beta", "org.kde.dolphin", "vesktop", "com.mitchellh.ghostty"]
    property double dockHeight: 68
    property string hoveredClass
    property var hoveredToplevels: Hyprland.toplevels.values.filter(toplevel => toplevel.wayland ? toplevel.wayland.appId == hoveredClass : false)
    property double hoveredXCenter: 0
    property double aspectRatio: screen.width / screen.height
    property bool tlviewVisible: false

    Timer {
        id: triggerTLView
        interval: 600
        onTriggered: {
            tlviewVisible = true;
        }
    }
    color: Qt.rgba(0, 0, 0, 0)
    onHoveredChanged: {
        if (hovered == false) {
            tlviewVisible = false;
            triggerTLView.stop();
        }
    }

    Component.onCompleted: () => {
        Shared.panels.push(dock);
    }
    WlrLayershell.layer: WlrLayer.Overlay
    anchors {
        right: true
        bottom: true
        left: true
        top: true
    }
    exclusionMode: ExclusionMode.Ignore
    implicitHeight: 300
    mask: Region {
        item: region1
        Region {
            item: region2
        }
        Region {
            item: overviewRegion
        }
    }

    Overview {
        id: overview
        isActive: false
        containerParent: dock.contentItem
        aspectRatio: dock.aspectRatio
        screen: dock.screen
        onIsActiveChanged: {
            if (isActive == true) {
                dock.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand;
            } else {
                dock.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
            }
        }
    }
    function keybindReveal() {
        if (Hyprland.focusedMonitor == Hyprland.monitorFor(screen)) {
            overview.isActive = !overview.isActive;
        }
    }
    Item {
        id: overviewRegion
        states: State {
            name: "overview"
            when: overview.active == true
            PropertyChanges {
                overviewRegion.height: overviewRegion.parent.height
            }
        }
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }
    Item {
        id: region1
        states: State {
            name: "hover"
            when: dock.hovered == true
            PropertyChanges {
                region1.height: dockHeight + floatMargin
            }
        }
        anchors {
            bottom: parent.bottom
            bottomMargin: -1
        }
        width: dockHitbox.childrenRect.width
        height: 5
    }
    Item {
        id: region2
        states: State {
            name: "hover"
            when: tlviewVisible == true && hoveredToplevels.length > 0
            PropertyChanges {
                region2.height: 225
            }
        }
        anchors {
            bottom: region1.top
        }
        width: dockHitbox.childrenRect.width
        height: 0 //hoveredTopLevels.length > 0? 500: 0
    }

    MouseArea {
        id: dockHitbox
        hoverEnabled: true
        anchors {
            bottom: parent.bottom
            bottomMargin: -1
        }
        width: childrenRect.width
        height: dock.hovered == true || overview.active == true ? toplevelViews.height + 10 + floatMargin + dockHeight : (fullHide ? 0 : 5)
        onEntered: {
            dock.hovered = true;
        }
        onExited: {
            dock.hovered = false;
        }
        Item {
            id: dockAnchor
            anchors {
                bottom: parent.bottom
                bottomMargin: -dockPanel.height
            }
            states: State {
                name: "hover"
                when: dock.hovered == true || overview.active == true
                PropertyChanges {
                    target: dockAnchor
                    anchors.bottomMargin: floatMargin + 1
                }
            }
            transitions: Transition {
                to: "hover"
                reversible: true
                PropertyAnimation {
                    property: "anchors.bottomMargin"
                    duration: 150
                    easing {
                        type: Easing.OutBack
                        overshoot: 1
                    }
                }
            }
        }
        Rectangle {
            id: toplevelViews
            clip: true
            width: toplevelRow.width + 20
            radius: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: dockHeight + floatMargin + 10
            height: hoveredToplevels.length > 0 ? 220 : 0
            x: Math.max(hoveredXCenter - (width / 2), floatMargin)
            color: Qt.rgba(0.05, 0.05, 0.05, 1)
            opacity: 0
            states: State {
                name: "visible"
                when: tlviewVisible == true && hoveredToplevels.length > 0
                PropertyChanges {
                    toplevelViews.opacity: 1
                }
            }
            transitions: Transition {
                to: "visible"
                reversible: true
                PropertyAnimation {
                    property: "opacity"
                    duration: 200
                }
            }

            Behavior on x {
                NumberAnimation {
                    duration: 100
                    easing {
                        type: Easing.OutBack
                        overshoot: 0
                    }
                }
            }

            Row {
                id: toplevelRow
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                x: 10
                height: parent.height
                spacing: 10
                Repeater {
                    model: ScriptModel {
                        values: toplevelViews.opacity > 0 ? hoveredToplevels : []
                    }
                    ClippingRectangle {
                        color: Qt.rgba(0.05, 0.05, 0.05, 0)
                        radius: 10
                        required property HyprlandToplevel modelData
                        width: toplevelView.width
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                        height: 200
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                modelData.wayland.activate();
                                hovered = false;
                            }
                        }
                        ScreencopyView {
                            id: toplevelView
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                verticalCenter: parent.verticalCenter
                            }
                            live: true
                            captureSource: modelData.wayland
                            constraintSize: Qt.size(200 * dock.aspectRatio, 200)
                        }
                        TopViewIcon {
                            id: closeButton
                            onClicked: {
                                modelData.wayland.close();
                            }
                            hoverColor: Qt.rgba(1, 0.2, 0.2, 1)
                            iconSource: `${Shared.iconsPath}/x.svg`
                            anchors.right: parent.right
                        }
                        Process {
                            id: hyprfreeze
                        }
                        TopViewIcon {
                            id: hibernateButton
                            onClicked: {
                                if (modelData.lastIpcObject && modelData.lastIpcObject.pid) {
                                    hyprfreeze.exec(["hyprfreeze", "-p", modelData.lastIpcObject.pid]);
                                }
                            }
                            hoverColor: Qt.rgba(0.4, 0.69, 1, 1)
                            iconSource: `${Shared.iconsPath}/snowflake.svg`
                            anchors.right: closeButton.left
                        }
                    }
                }
            }
        }

        Rectangle {
            id: dockPanel
            anchors {
                bottom: dockAnchor.bottom
            }
            width: Math.max(childrenRect.width, 50)
            height: dockHeight
            color: Qt.rgba(0, 0, 0, 1)
            radius: 15
            x: floatMargin
            clip: false
            MouseArea {
                width: 68 + floatMargin
                height: 68 + floatMargin
                x: -floatMargin
                onPressed: () => {
                    overview.isActive = !overview.isActive;
                }
                Rectangle {
                    anchors {
                        fill: parent
                        leftMargin: floatMargin + 6
                        bottomMargin: floatMargin + 6
                        topMargin: 6
                        rightMargin: 6
                    }
                    radius: 9
                    color: Qt.rgba(1, 1, 1, 0.1)
                }
                Image {
                    anchors {
                        fill: parent
                        leftMargin: floatMargin + 8
                        bottomMargin: floatMargin + 8
                        topMargin: 8
                        rightMargin: 8
                    }
                    // css.gg icon
                    source: `${Shared.iconsPath}/menu-grid-o.svg`
                }
            }
            Row {
                x: 68
                spacing: 0
                // non pinned apps
                Repeater {
                    model: ScriptModel {
                        values: pinnedApps
                    }
                    DockIcon {
                        id: icon
                        required property string modelData
                        floatMargin: dock.floatMargin + 1
                        appId: modelData
                        onEnter: () => {
                            hoveredClass = appId;
                            hoveredXCenter = icon.x + (icon.width / 2);
                            triggerTLView.restart();
                        }
                    }
                }
                Repeater {
                    model: ScriptModel {
                        values: Array.from(new Set(ToplevelManager.toplevels.values.map(toplevel => toplevel.appId))).filter(appId => !pinnedApps.includes(appId))
                    }
                    DockIcon {
                        id: icon
                        required property string modelData
                        floatMargin: dock.floatMargin + 1
                        appId: modelData
                        onEnter: () => {
                            hoveredClass = appId;
                            hoveredXCenter = icon.x + (icon.width / 2);
                            triggerTLView.restart();
                        }
                    }
                }
            }
        }
    }

    //Notif {}
}
