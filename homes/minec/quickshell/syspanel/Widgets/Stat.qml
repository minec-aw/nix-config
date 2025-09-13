import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import ".."
import "../.."

Item {
    id: statistic
    width: 18
    height: 70
    property var icon
    property var percentage
    property var text
    ClippingRectangle {
        width: 6
        color: Qt.rgba(1,1,1,0.2)
        anchors.horizontalCenter: iconimage.horizontalCenter
        height: 50
        radius: 100
        Rectangle {
            anchors {
                bottom: parent.bottom
                //left: parent.left
               // right: parent.right
            }
            width: 6
            color: Shared.colors.on_surface
            height: (percentage*50)
        }
    }

    Image {
        id: iconimage
        smooth: true
        source: icon
        height: 16
        width: height
        anchors {
            bottom: parent.bottom
        }
        layer.enabled: true
        layer.effect: MultiEffect {
            colorizationColor: Shared.colors.on_surface
            colorization: 1
        }
    }
}