import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "toys"

PanelWindow {
	id: background
	color: "black"
	
	WlrLayershell.layer: WlrLayer.Background
	WlrLayershell.namespace: "shell:background"

	anchors {
		top: true
		bottom: true 
		left: true
		right: true
	}
	
	AlternateBackgroundObject {
		animate: false
		anchors.fill: parent
		slidingFactor: Hyprland.focusedWorkspace.id || 0
	}
}