import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import ".."
import "../.."

MouseArea {
    hoverEnabled: true
	onContainsMouseChanged: () => {
		bar.lesserHover = containsMouse
	}
}