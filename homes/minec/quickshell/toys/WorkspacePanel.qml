import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import ".."

Item {
    id: workspacepanel
    required property HyprlandWorkspace workspace
    width: 320 
    height: 180
    clip: true
    property var scaleDownX: width/workspace.monitor.width
    property var scaleDownY: height/workspace.monitor.height
    property var borderSize: Shared.hyprlandBorderSize*borderScaleDown
    property var cornerRadius: Shared.hyprlandRadius*borderScaleDown
    property bool isLive: true
    property var borderScaleDown: (width*workspace.monitor.scale)/(workspace.monitor.width)

    property var maxReady: workspace.toplevels.values.length
    Component.onCompleted: () => {
        timeou = Date.now()
        Hyprland.refreshToplevels()
    }
    onWorkspaceChanged: () => {
        Hyprland.refreshToplevels()
    }
    Repeater {
        id: toplevels
        model: workspace.toplevels
        Rectangle {
            id: scviewborder
            required property var modelData
            property var canHaveRadius: workspace.toplevels.values.length != 1 || (modelData.lastIpcObject.floating && !modelData.wayland.fullscreen)
            color: modelData.activated? Shared.colors.outline: "transparent"
            width: scview.sourceSize.width*scaleDownX + borderSize*2
            height: scview.sourceSize.height*scaleDownY + borderSize*2
            x: ((modelData.lastIpcObject.at[0] || 0)*workspace.monitor.scale)*scaleDownX - borderSize
            y: ((modelData.lastIpcObject.at[1] || 0)*workspace.monitor.scale)*scaleDownY - borderSize

            radius: cornerRadius*canHaveRadius
            ClippingRectangle {
                id: scviewcontainer
                anchors {
                    fill: parent
                    topMargin: borderSize
                    bottomMargin: borderSize
                    leftMargin: borderSize
                    rightMargin: borderSize
                }
                
                clip: true
                radius: cornerRadius*canHaveRadius //just pick one a scale brodie
                color: "transparent"  
                ScreencopyView {
                    id: scview
                    captureSource: modelData.wayland
                    live: isLive
                    anchors.fill: parent
                } 
            }
        }
    }
}