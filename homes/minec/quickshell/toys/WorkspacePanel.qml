pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import Quickshell.Widgets
import ".."

Item {
    id: workspacepanel
    required property HyprlandWorkspace workspace
    width: 320
    height: 180
    clip: true
    property real titlebarHeight: 32
    property var scaleDownX: workspace ? width / workspace.monitor.width : width
    property var scaleDownY: workspace ? height / workspace.monitor.height : height
    property var borderSize: Shared.hyprlandBorderSize * borderScaleDown
    property var cornerRadius: Shared.hyprlandRadius * borderScaleDown
    property color titlebarColor: Qt.rgba(24 / 255, 24 / 255, 37 / 255, 1)
    property bool isLive: true
    property var borderScaleDown: workspace ? (width * workspace.monitor.scale) / (workspace.monitor.width) : width

    Component.onCompleted: () => {
        Hyprland.refreshToplevels();
    }
    onWorkspaceChanged: () => {
        Hyprland.refreshToplevels();
    }
    Repeater {
        id: toplevels
        model: workspacepanel.workspace ? workspacepanel.workspace.toplevels : []
        Rectangle {
            id: scviewborder
            required property var modelData
            property bool canHaveRadius: workspacepanel.workspace.toplevels.values.length != 1 || (modelData.lastIpcObject.floating && !modelData.wayland.fullscreen)
            property bool hasTitleBar: !modelData.lastIpcObject.tags.includes("notitle*")
            color: modelData.activated ? Shared.colors.outline : "transparent"
            width: scview.sourceSize.width * workspacepanel.scaleDownX + workspacepanel.borderSize * 2
            height: scview.sourceSize.height * workspacepanel.scaleDownY + workspacepanel.borderSize * 2
            x: ((modelData.lastIpcObject.at[0] || 0) * workspacepanel.workspace.monitor.scale) * workspacepanel.scaleDownX - workspacepanel.borderSize
            y: ((modelData.lastIpcObject.at[1] || 0) * workspacepanel.workspace.monitor.scale) * workspacepanel.scaleDownY - workspacepanel.borderSize

            radius: workspacepanel.cornerRadius * canHaveRadius
            Rectangle {
                id: titlebar
                clip: true
                topLeftRadius: workspacepanel.cornerRadius * scviewborder.canHaveRadius
                topRightRadius: topLeftRadius
                anchors {
                    bottom: parent.top
                    bottomMargin: -workspacepanel.cornerRadius * scviewborder.hasTitleBar
                    left: parent.left
                    right: parent.right
                }
                color: workspacepanel.titlebarColor
                height: (workspacepanel.titlebarHeight + workspacepanel.cornerRadius) * scviewborder.hasTitleBar
                Item {
                    // container for proper scaling of items
                    anchors {
                        fill: parent
                        bottomMargin: workspacepanel.cornerRadius
                    }
                    Text {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                        text: scviewborder.modelData.title
                        font.family: "Noto Sans"
                        font.pointSize: 11
                        color: Qt.rgba(218 / 255, 218 / 255, 218 / 255, 1)
                    }
                    Row {
                        layoutDirection: Qt.RightToLeft
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            right: parent.right
                            rightMargin: 11
                        }
                        spacing: 22
                        Repeater {
                            model: ["", "", "󰍴"]
                            Text {
                                required property string modelData
                                text: modelData
                                font.family: "Noto Sans"
                                font.pointSize: 13
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                }
                                color: Qt.rgba(1, 1, 1, 1)
                            }
                        }
                    }
                }
            }

            ClippingRectangle {
                id: scviewcontainer
                anchors {
                    fill: parent
                    topMargin: workspacepanel.borderSize
                    bottomMargin: workspacepanel.borderSize
                    leftMargin: workspacepanel.borderSize
                    rightMargin: workspacepanel.borderSize
                }

                clip: true
                radius: workspacepanel.cornerRadius * scviewborder.canHaveRadius //just pick one a scale brodie
                color: "transparent"
                ScreencopyView {
                    id: scview
                    captureSource: scviewborder.modelData.wayland
                    live: workspacepanel.isLive
                    anchors.fill: parent
                }
            }
        }
    }
}
