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
	exclusionMode: ExclusionMode.Ignore

	anchors {
		top: true
		bottom: true 
		left: true
		right: true
	}
	
	AlternateBackgroundObject {
		animate: true
		anchors.fill: parent
		slidingFactor: Hyprland.focusedWorkspace.id || 0
	}
}