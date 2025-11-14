import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import "Widgets"
import ".."
import "../toys"
import Quickshell.Services.Mpris
import QtQuick.Effects

PanelWindow {
	id: panelcarrier
	property bool pinned: false
	property bool opened: false
	property bool hovered: false
	property bool fullHide: Hyprland.monitorFor(screen).activeWorkspace? Hyprland.monitorFor(screen).activeWorkspace.hasFullscreen: false
	property bool transparentBackground: true
	property real mouseY: 0
	color: Qt.rgba(0,0,0,0)
	
	HyprlandFocusGrab {
      id: grab
      windows: [panelcarrier]
	  onActiveChanged: () => {
		if (active == false) {
			panel.hover = false
			panel.opened = false
		}
	  }
	}
	Component.onCompleted: () => {
		Shared.panels.push(panelcarrier)
	}
	WlrLayershell.layer: WlrLayer.Overlay
	function keybindReveal() {
		if (opened) {
			opened = false
			hover = false
		} else if (Hyprland.focusedMonitor == Hyprland.monitorFor(screen)) {
			opened = true
		}
	}
	anchors {
		right: true
		bottom: true
		left: true
	}
	exclusionMode: ExclusionMode.Ignore
	implicitHeight: 200
	Rectangle {
		width: 600
		height: 60
		color: Qt.rgba(0,0,0,1)
		radius: 15
		Row {
			spacing: 5
			Repeater {
				model: ToplevelManager.toplevels
				Item {
					width: 60
					height: 60
					required property int index
					required property Toplevel modelData
					property DesktopEntry desktopEntry: DesktopEntries.byId(modelData.appId)
					Image {
						width: 50
						height: 50
						Component.onCompleted: () => {
							console.log("App!!", modelData.title, modelData.appId, desktopEntry != null? desktopEntry.name: "no name")
						}
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.verticalCenter: parent.verticalCenter
						source: Quickshell.iconPath(desktopEntry.icon)
					}
				}
			}
		}
	}

	//Notif {}
}