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
		source: Qt.resolvedUrl("alternate_background_props/sky.png")
	}
	Image {
		smooth: false
		//fillMode: Image.PreserveAspectFit
		x: 640*scalingFactor - width - scalingFactor*94
		y: scalingFactor*20
		width: sourceSize.width*scalingFactor
		height: sourceSize.height*scalingFactor
		source: Qt.resolvedUrl("alternate_background_props/moon.png")
		Image {
			smooth: false
			//fillMode: Image.PreserveAspectFit
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.verticalCenter: parent.verticalCenter
			width: sourceSize.width*scalingFactor
			height: sourceSize.height*scalingFactor
			source: Qt.resolvedUrl("alternate_background_props/moonBloom.png")
		}
	}
	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.03
		y: 64*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)
				source: Qt.resolvedUrl("alternate_background_props/clouds_5.png")
			}
		}
	}
	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.07
		y: 64*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)
				source: Qt.resolvedUrl("alternate_background_props/clouds_4.png")
			}
		}
	}

	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.1
		//y: -300*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)*scalingFactor*2
				y: 48*scalingFactor
				source: Qt.resolvedUrl("alternate_background_props/tower_3.png")
			}
		}
	}
	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.1
		//y: -300*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)*scalingFactor
				y: 48*scalingFactor
				source: Qt.resolvedUrl("alternate_background_props/tower_3_beefy.png")
			}
		}
	}

	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.2
		y: 96*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)
				source: Qt.resolvedUrl("alternate_background_props/clouds_3.png")
			}
		}
	}

	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.3
		//y: -300*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)*scalingFactor*2
				y: 32*scalingFactor
				source: Qt.resolvedUrl("alternate_background_props/tower_2.png")
			}
		}
	}
	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.3
		//y: -300*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)*scalingFactor
				y: 16*scalingFactor
				source: Qt.resolvedUrl("alternate_background_props/tower_2_beefy.png")
			}
		}
	}
	
	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.4
		y: 96*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)
				source: Qt.resolvedUrl("alternate_background_props/clouds_2.png")
			}
		}
	}

	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.6
		y: -300*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)
				source: Qt.resolvedUrl("alternate_background_props/tower_1.png")
			}
		}
	}
	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.8
		y: 160*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 10
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)
				source: Qt.resolvedUrl("alternate_background_props/clouds_1.png")
			}
		}
	}
	Item {
		width: childrenRect.width
		height: parent.height
		x: -slidingFactor*parent.width*0.95
		//y: 160*scalingFactor
		Behavior on x { WorkspaceAnimation {} }
		Repeater {
			model: 20
			delegate: Image {
				smooth: false
				width: sourceSize.width*scalingFactor
				height: sourceSize.height*scalingFactor
				x: width*(index-1)
				source: Qt.resolvedUrl("alternate_background_props/cloudsFog.png")
			}
		}
	}
	
	
}