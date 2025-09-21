import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Pipewire
import ".."
import "../.."

ColumnLayout {
	required property PwNode node;

	// bind the node so we can read its properties
	PwObjectTracker { objects: [ node ] }

	RowLayout {
		Image {
			visible: source != ""
			source: {
				const icon = node.properties["application.icon-name"] ?? "audio-volume-high-symbolic";
				return `image://icon/${icon}`;
			}

			sourceSize.width: 20
			sourceSize.height: 20
		}

        Text {
            id: title
            text: {
				// application.name -> description -> name
				const app = node.properties["application.name"] ?? (node.description != "" ? node.description : node.name);
				const media = node.properties["media.name"];
				return node.isStream == false? app: (media != undefined ? `${app} - ${media}` : app);
			}
            color: Shared.colors.on_surface
            font {
                pointSize: 10
                family: "Noto Sans"
            }
        }

		Button {
			text: node.audio.muted ? "unmute" : "mute"
			onClicked: node.audio.muted = !node.audio.muted
		}
	}

	RowLayout {
        Text {
            Layout.preferredWidth: 50
            id: percent
            text: `${Math.floor(node.audio.volume * 100)}%`
            color: Shared.colors.on_surface
            font {
                pointSize: 10
                family: "Noto Sans"
            }
        }
		Slider {
			Layout.fillWidth: true
			value: node.audio.volume
			onValueChanged: node.audio.volume = value
		}
	}
}