

//the first line is required for screencopyview to work
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell
ShellRoot {
	id: root
	Variants {
		model: Quickshell.screens;
		Scope {
			property var modelData
			Dock {
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
			// a
			//Overview {screen: modelData; visible: Shared.overviewVisible && Hyprland.focusedMonitor == Hyprland.monitorFor(modelData)}
			/*LazyLoader {
				active: (Shared.overviewVisible == true || Shared.keepShowingOverview == true) && Hyprland.focusedMonitor == Hyprland.monitorFor(modelData)
				Overview {screen: modelData}
			}*/
		}
	}
}