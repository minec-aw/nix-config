pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import QtQuick
import "toys"
import Quickshell.Widgets
import QtQuick.Effects

LazyLoader {
    id: overviewLoader
    required property var aspectRatio
    required property var containerParent
    required property ShellScreen screen
    property HyprlandMonitor hyprlandScreen: Hyprland.monitorFor(overviewLoader.screen)
    property HyprlandWorkspace activeWorkspace: hyprlandScreen.activeWorkspace ?? null
    required property bool isActive

    onIsActiveChanged: {
        if (isActive == true) {
            active = isActive;
        }
    }
    Item {
        id: overview
        parent: overviewLoader.containerParent
        z: -1
        visible: false
        anchors.fill: parent
        property bool isActive: overviewLoader.isActive
        onIsActiveChanged: {
            if (isActive == false) {
                Hyprland.dispatch(`workspace ${workspacesFlickable.targettedWorkspaceId}`);
            }
        }

        property double initialScalingFactor: 1
        Timer {
            interval: 10
            running: true
            onTriggered: {
                overview.visible = true;
            }
        }
        states: State {
            name: "visible"
            when: overview.visible == true && overviewLoader.isActive == true
            PropertyChanges {
                overview.initialScalingFactor: workspacesFlickable.height / overviewLoader.screen.height
            }
        }
        transitions: [
            Transition {
                to: "visible"
                reversible: false
                SequentialAnimation {
                    PropertyAnimation {
                        target: overviewZoomer
                        property: "visible"
                        from: false
                        to: true
                        duration: 0
                    }
                    PropertyAnimation {
                        property: "initialScalingFactor"
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                    PropertyAnimation {
                        target: overviewZoomer
                        property: "visible"
                        from: true
                        to: false
                        duration: 0
                    }
                }
            },
            Transition {
                from: "visible"
                reversible: false
                SequentialAnimation {
                    PropertyAnimation {
                        target: overviewZoomer
                        property: "visible"
                        to: true
                        duration: 0
                    }
                    PropertyAnimation {
                        property: "initialScalingFactor"
                        duration: 310
                        easing.type: Easing.OutCubic
                    }
                    PropertyAnimation {
                        target: overviewZoomer
                        property: "visible"
                        to: false
                        duration: 0
                    }
                    PropertyAnimation {
                        target: overviewLoader
                        property: "active"
                        to: false
                        duration: 0
                    }
                }
            }
        ]
        Rectangle {
            anchors.fill: parent
            color: "black"
        }
        AlternateBackgroundObject {
            id: background
            animate: false
            anchors.fill: parent
            slidingFactor: 0
            layer.enabled: true

            layer.effect: MultiEffect {
                saturation: 0.5
                blurEnabled: true
                autoPaddingEnabled: true
                blurMax: 64
                blur: 1
                blurMultiplier: 3
            }
        }
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.6)
        }
        ClippingRectangle {
            id: overviewZoomer
            visible: true
            parent: overview
            z: 1
            width: overviewLoader.screen.width
            height: overviewLoader.screen.height
            contentUnderBorder: true
            transform: [
                Scale {
                    xScale: overview.initialScalingFactor
                    yScale: overview.initialScalingFactor
                }
            ]
            x: (parent.width - (width * overview.initialScalingFactor)) / 2
            y: (parent.height - (height * overview.initialScalingFactor)) / 2
            color: Qt.rgba(1, 1, 0, 0.3)
            radius: 40
            AlternateBackgroundObject {
                animate: false
                anchors.fill: parent
                slidingFactor: workspacesFlickable.targettedWorkspaceId || 0
            }
            WorkspacePanel {
                workspace: Hyprland.workspaces.values.find(workspace => workspace.id == workspacesFlickable.targettedWorkspaceId)
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
            property int targettedWorkspaceId: 0
            Component.onCompleted: {
                targettedWorkspaceId = overviewLoader.activeWorkspace.id;
                contentX = (targettedWorkspaceId - 1) * height * overviewLoader.aspectRatio;
            }
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            NumberAnimation {
                id: flickAnimation
                target: workspacesFlickable
                property: "contentX"
                duration: 300
                easing.type: Easing.OutCubic
            }
            focus: true
            Keys.onPressed: event => {
                if (event.key == Qt.Key_Left) {
                    const id = targettedWorkspaceId;
                    if (id - 1 <= 0) {
                        flickAnimation.stop();
                        workspacesFlickable.flick(2000, 0);
                    } else {
                        targettedWorkspaceId = id - 1;
                        flickAnimation.stop();
                        flickAnimation.to = (id - 2) * height * overviewLoader.aspectRatio;
                        flickAnimation.start();
                    }
                    event.accepted = true;
                } else if (event.key == Qt.Key_Right) {
                    const id = targettedWorkspaceId;
                    if (id >= 10) {
                        flickAnimation.stop();
                        workspacesFlickable.flick(-2000, 0);
                    } else {
                        targettedWorkspaceId = id + 1;
                        flickAnimation.stop();
                        flickAnimation.to = (id) * height * overviewLoader.aspectRatio;
                        flickAnimation.start();
                    }
                    event.accepted = true;
                }
            }
            property var beingFlicked: false
            onHorizontalVelocityChanged: {
                if (beingFlicked == true && Math.abs(horizontalVelocity) < 2000) {
                    workspacesFlickable.cancelFlick();
                    const direction = horizontalVelocity > 0 ? 1 : -1;
                    const estimatedX = workspacesFlickable.contentX + direction * (workspacesFlickable.horizontalVelocity ^ 2) / (workspacesFlickable.flickDeceleration);
                    const nearestIndex = Math.round(estimatedX / (workspacesFlickable.height * overviewLoader.aspectRatio));
                    const nearestWorkspaceX = nearestIndex * height * overviewLoader.aspectRatio;
                    flickAnimation.stop();
                    flickAnimation.to = nearestIndex * height * overviewLoader.aspectRatio;
                    flickAnimation.start();
                    beingFlicked = false;
                    targettedWorkspaceId = nearestIndex + 1;
                }
            }
            onDragEnded: {
                beingFlicked = true;
            }

            onDragStarted: {
                flickAnimation.stop();
            }

            height: parent.height - 300
            clip: true
            Row {
                id: workspacesRow
                x: workspacesFlickable.width / 2 - (height * overviewLoader.aspectRatio / 2)
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                spacing: 0
                Repeater {
                    model: 10
                    MouseArea {
                        id: container
                        width: height * overviewLoader.aspectRatio
                        height: parent.height
                        required property int index
                        property int id: index + 1
                        property HyprlandWorkspace workspace: Hyprland.workspaces.values.find(workspace => workspace.id == id) ?? null
                        property double distanceFromCenter: Math.abs((workspacesRow.x + container.x + container.width / 2) - (workspacesFlickable.contentX + workspacesFlickable.width / 2))
                        property double marginFactor: 0.9 + 0.1 * Math.max(0, -(1 / 500) * Math.abs(distanceFromCenter) + 1)
                        property double scalingFactor: (height / overviewLoader.screen.height) * marginFactor
                        onClicked: {
                            if (marginFactor < 0.99) {
                                flickAnimation.to = container.x; // somehow this works?
                                flickAnimation.start();
                                workspacesFlickable.targettedWorkspaceId = index + 1;
                            } else {
                                overviewLoader.isActive = false;
                            }
                        }
                        ClippingRectangle {
                            width: overviewLoader.screen.width
                            height: overviewLoader.screen.height
                            contentUnderBorder: true
                            transform: [
                                Scale {
                                    xScale: container.scalingFactor
                                    yScale: container.scalingFactor
                                }
                            ]
                            AlternateBackgroundObject {
                                animate: false
                                anchors.fill: parent
                                slidingFactor: container.id
                            }
                            x: (parent.width - (width * container.scalingFactor)) / 2
                            y: (parent.height - (height * container.scalingFactor)) / 2
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
