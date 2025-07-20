

//the first line is required for screencopyview to work
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "syspanel" as SystemPanel
import Quickshell.Hyprland

ShellRoot {
	id: root
	Variants {
		model: Quickshell.screens;
		Scope {
			property var modelData
			SystemPanel.SystemPanel {
				id: bar
				screen: modelData
			}
			LazyLoader {
				active: Shared.screenshotTaken
				Screenshot {screen: modelData}
			}
			BackgroundAlternate {
				screen: modelData
			}
			//Overview {screen: modelData; visible: Shared.overviewVisible && Hyprland.focusedMonitor == Hyprland.monitorFor(modelData)}
			LazyLoader {
				active: Shared.overviewVisible && Hyprland.focusedMonitor == Hyprland.monitorFor(modelData)
				Overview {screen: modelData}
			}
		}
	}
}