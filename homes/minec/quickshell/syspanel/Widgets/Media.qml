import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."
import "../.."

PanelTile {
	id: media
    width: 80
    x: 6
    y: -height
    showedY: 6
    expandedHeight: 250
    PanelMouseArea {
        id: togglingarea
		anchors.fill: parent
		onClicked: bar.expandPanel(parent)
    }
}