import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import ".."
import "../.."

Rectangle {
    radius: 20
    color: Qt.rgba(0.41, 0.21, 0.27, 0.3)
	id: root
	height: 200
    // Use description to name PWNodes

    /*Text {
        text: Pipewire.defaultAudioSink.description
        color: Shared.colors.on_surface
        font.pixelSize: 20
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 10
        }
    }*/
}