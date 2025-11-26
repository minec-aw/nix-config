pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import QtQuick
import "toys"
import Quickshell.Widgets

LazyLoader {
    id: overviewLoader
    required property var aspectRatio
    required property var containerParent
    required property ShellScreen screen
    property var hyprlandScreen: Hyprland.monitorFor(screen)
    property var activeWorkspace: hyprlandScreen.activeWorkspace
    required property bool isActive
    property var closeFunc
    onIsActiveChanged: {
        if (isActive == true) {
            active = isActive;
        } else {
            closeFunc();
        }
    }
    Item {
        id: overview
        parent: overviewLoader.containerParent
        z: -1
        visible: false
        anchors.fill: parent

        property var initialScalingFactor: 1
        /*Process {
            id: hyprAnimCancel
            command: ["hyprctl", "keyword", "animation", "workspaces,0"]
            onExited: {
                hyprSwitchWorkspaces.running = true
            }
        }
        Process {
            id: hyprSwitchWorkspaces
            command: ["hyprctl", "dispatch", "workspace", "1"]
            onExited: {
                hyprRestoreAnim.running = true
            }
        }
        Process {
            id: hyprRestoreAnim
            command: ["hyprctl", "reload"]
        }*/

        NumberAnimation {
            id: numanim
            target: overview
            property: "initialScalingFactor"
            duration: 200
            easing.type: Easing.OutCubic
            from: 1
            to: workspacesFlickable.height / screen.height
            onFinished: {
                overviewZoomer.visible = false;
            }
        }
        Timer {
            id: closeTimer
            interval: numanim.duration
            onTriggered: {
                overviewLoader.active = false;
            }
        }
        function animateZoom(from, to) {
            overview.visible = true;
            overviewZoomer.visible = true;
            numanim.from = from;
            numanim.to = to;
            numanim.start();
        }
        function open() {
            closeTimer.stop();
            openTimer.start();
            animateZoom(1, workspacesFlickable.height / screen.height);
        }
        function close() {
            const nearestIndex = Math.round(workspacesFlickable.contentX / (workspacesFlickable.height * aspectRatio));
            //hyprSwitchWorkspaces.command = ["hyprctl", "dispatch", "workspace", nearestIndex+1]
            //hyprAnimCancel.running = true
            //Hyprland.dispatch(`workspace ${nearestIndex+1}`)
            openTimer.stop();
            animateZoom(workspacesFlickable.height / screen.height, 1);
            closeTimer.start();
        }
        Component.onCompleted: {
            overviewLoader.closeFunc = close;
        }

        Timer {
            id: openTimer
            running: true
            interval: 10
            onTriggered: {
                animateZoom(1, workspacesFlickable.height / screen.height);
            }
        }
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0.1, 0, 0.1, 1)
        }
        ClippingRectangle {
            id: overviewZoomer
            visible: false
            parent: overview
            z: 1
            width: screen.width
            height: screen.height
            contentUnderBorder: true
            transform: [
                Scale {
                    xScale: initialScalingFactor
                    yScale: initialScalingFactor
                }
            ]
            x: (parent.width - (width * initialScalingFactor)) / 2
            y: (parent.height - (height * initialScalingFactor)) / 2
            color: Qt.rgba(1, 1, 0, 0.3)
            radius: 40
            AlternateBackgroundObject {
                animate: false
                anchors.fill: parent
                slidingFactor: activeWorkspace.id || 0
            }
            WorkspacePanel {
                workspace: activeWorkspace
                anchors.fill: parent
            }
        }
        Flickable {
            id: workspacesFlickable
            flickableDirection: Flickable.HorizontalFlick
            contentWidth: workspacesRow.width + workspacesRow.x * 2
            maximumFlickVelocity: 15000
            flickDeceleration: 10000
            contentHeight: height
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            property var contentXOnFlick: 0
            NumberAnimation {
                id: flickAnimation
                target: workspacesFlickable
                property: "contentX"
                duration: 300
                easing.type: Easing.OutCubic
            }
            property var beingFlicked: false
            onHorizontalVelocityChanged: {
                if (beingFlicked == true && Math.abs(horizontalVelocity) < 2000) {
                    const direction = horizontalVelocity > 0 ? 1 : -1;
                    const estimatedX = workspacesFlickable.contentX + direction * (workspacesFlickable.horizontalVelocity ^ 2) / (workspacesFlickable.flickDeceleration);
                    const nearestIndex = Math.round(estimatedX / (workspacesFlickable.height * aspectRatio));
                    const nearestWorkspaceX = nearestIndex * height * aspectRatio;
                    flickAnimation.to = nearestIndex * height * aspectRatio;
                    flickAnimation.start();
                    beingFlicked = false;
                    Hyprland.dispatch(`workspace ${nearestIndex + 1}`);
                }
            }
            onDragEnded: {
                beingFlicked = true;
                contentXOnFlick = contentX;
            }
            contentX: (activeWorkspace.id - 1) * height * aspectRatio
            height: parent.height - 300
            clip: true
            Row {
                id: workspacesRow
                x: workspacesFlickable.width / 2 - (height * aspectRatio / 2)
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                spacing: 0
                Repeater {
                    model: 10
                    MouseArea {
                        id: container
                        width: height * aspectRatio
                        height: parent.height
                        required property var index
                        property var workspace: Hyprland.workspaces.values.find(workspace => workspace.id == index + 1)
                        property var distanceFromCenter: Math.abs((workspacesRow.x + container.x + container.width / 2) - (workspacesFlickable.contentX + workspacesFlickable.width / 2))
                        property var marginFactor: 0.9 + 0.1 * Math.max(0, -(1 / 500) * Math.abs(distanceFromCenter) + 1)
                        property var scalingFactor: (height / screen.height) * marginFactor
                        onClicked: {
                            if (marginFactor < 0.99) {
                                flickAnimation.to = container.x; // somehow this works?
                                flickAnimation.start();
                                Hyprland.dispatch(`workspace ${index + 1}`);
                            } else {
                                close();
                            }
                        }
                        ClippingRectangle {
                            width: screen.width
                            height: screen.height
                            contentUnderBorder: true
                            transform: [
                                Scale {
                                    xScale: scalingFactor
                                    yScale: scalingFactor
                                }
                            ]
                            AlternateBackgroundObject {
                                animate: false
                                anchors.fill: parent
                                slidingFactor: workspace.id || 0
                            }
                            x: (parent.width - (width * scalingFactor)) / 2
                            y: (parent.height - (height * scalingFactor)) / 2
                            color: Qt.rgba(1, 1, 0, 0.3)
                            radius: 40
                            WorkspacePanel {
                                workspace: container.workspace
                                anchors.fill: parent
                            }
                        }
                    }
                }
            }
        }
    }
}
