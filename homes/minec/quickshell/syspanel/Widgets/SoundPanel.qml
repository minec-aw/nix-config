import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../.."

Rectangle {
    radius: 20
    color: Qt.rgba(0.35, 0.35, 0.45, 0.05)
	id: root
	height: 200
    // Use description to name PWNodes

    Text {
        id: devicetext
        text: Pipewire.defaultAudioSink.description
        color: Shared.colors.on_surface
        font.pixelSize: 16
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 10
        }
    }
    ScrollView {
        anchors {
            top: devicetext.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 12
        }
        clip: true
        height: 200

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 10

            // get a list of nodes that output to the default sink
            NodeEntry {
                node: Pipewire.defaultAudioSink
            }

            Repeater {
                model: ScriptModel {
                    values: Pipewire.nodes.values.filter(entry => entry.isStream == true)
                }

                NodeEntry {
                    required property PwNode modelData
                    // Each link group contains a source and a target.
                    // Since the target is the default sink, we want the source.
                    node: modelData
                }
            }
        }
    }
}