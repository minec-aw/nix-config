import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import ".."
import "../.."

Item {
    id: statistic
    width: childrenRect.width
    height: 38
    property var icon
    property var text
    Image {
        id: iconimage
        smooth: true
        source: icon
        height: 20
        width: height
        anchors {
            verticalCenter: parent.verticalCenter
        }
        layer.enabled: true
        layer.effect: MultiEffect {
            colorizationColor: textual.color
            colorization: 1
        }
    }
    Text {
        id: textual
        text: statistic.text
        color: Shared.colors.on_surface
        //horizontalAlignment: Text.AlignHCenter
        width: contentWidth
        verticalAlignment: Text.AlignVCenter
        anchors.left: iconimage.right
        anchors.leftMargin: 6
        anchors {
            verticalCenter: parent.verticalCenter
        }
        font {
            pointSize: 12
            family: "Jetbrains"
        }
        /*font {
            pointSize: 12
            //family: "SFPro"
            //bold: true
        }*/
    }
}