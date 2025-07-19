import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts
import "toys"

PanelWindow {
	id: background
	color: "black"
	property var slidingFactor: Hyprland.focusedWorkspace.id

	WlrLayershell.layer: WlrLayer.Background
	WlrLayershell.namespace: "shell:background"

	anchors {
		top: true
		bottom: true 
		left: true
		right: true
	}
	// in dead cells the "resolution" is 640x360
	property var scalingFactor: height/360
	//math should be done in terms of the original resolution
	Image {
		smooth: false
		fillMode: Image.Stretch
		anchors.fill: parent
		source: Qt.resolvedUrl("background_props/sky.png")
	}
	Image {
		smooth: false
		//fillMode: Image.PreserveAspectFit
		width: sourceSize.width*scalingFactor
		height: sourceSize.height*scalingFactor
		source: Qt.resolvedUrl("background_props/moon.png")
	}
	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.02
		y: 16*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)
				source: Qt.resolvedUrl("background_props/backCastle.png")
			}
		}
	}
	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.06
		y: 96*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)
				source: Qt.resolvedUrl("background_props/backGrass.png")
			}
		}
	}

	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.4
		y: -295*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)
				source: Qt.resolvedUrl("background_props/midTower.png")
				Image {
					smooth: false
					width: sourceSize.width*scalingFactor
					height: sourceSize.height*scalingFactor
					anchors.top: parent.bottom
					source: Qt.resolvedUrl("background_props/midTower.png")
				}
			}
		}
	}
	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.7
		y: 112*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)
				source: Qt.resolvedUrl("background_props/frontTower.png")
			}
		}
	}
}