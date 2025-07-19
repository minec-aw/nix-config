import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import QtQuick
import QtQuick.Layouts
import "toys"

//additional dependencies: grim & imagemagick & wl-copy

PanelWindow {
	id: screenshotpanel
    color: "transparent"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.namespace: "shell:screenshot"
    exclusionMode: ExclusionMode.Ignore
    visible: Shared.takingScreenshot
    property point initialPosition: Qt.point(-5000,-5000)
    property point finalPosition: Qt.point(-5000,-5000)
    property bool showDots: false
    //this is done rather than using the scale property since hyprland rounds the scaling factor when sending it out, funnily enough
    property var screenScale: Hyprland.monitorFor(screen).height / screen.height
    property string screenshotPath: ""
    Item {
        id: keyboardgrabber
        anchors.fill: parent
        focus: true
        Keys.onReleased: (event)=> {
            if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                savescreenshot.running = true
                event.accepted = true;
            } else if (event.key == Qt.Key_Escape) {
                Shared.takingScreenshot = false
            }
        }
    }
    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
        }
    }
    onVisibleChanged: () => {
        if (visible == false) {
            screenshotPath = ""
            initialPosition = Qt.point(-5000,-5000)
            finalPosition = Qt.point(-5000,-5000)
            selection.x = -5000
            selection.y = -5000
            selection.width = 0
            selection.height = 0
        } else {
            screenfreeze.opacity = 0
            screenshot.running = true
        }
    }
    Process {
		id: screenshot
		command: ["sh", "-c", `ssfile=$(mktemp /tmp/ssXXXXXX.png); grim -o ${screen.name} "$ssfile"; echo $ssfile`]
		running: false
		stdout: SplitParser {
			onRead: (data) => {
				screenshotPath = data
                Shared.registerFileForExtinction(screenshotPath)
                screenfreeze.opacity = 1
			}
		}
	}

    Process {
		id: savescreenshot
        // magick /tmp/ssXZyNr3.png -crop 32x32+30+10 wa.png
        command: ["sh", "-c", `magick ${screenshotPath} -crop ${selection.width*screenScale}x${selection.height*screenScale}+${initialPosition.x*screenScale}+${initialPosition.y*screenScale} - | wl-copy`]
		running: false
        onRunningChanged: () => {
            Shared.takingScreenshot = false
        }
	}
    
    Image {
        id: screenfreeze
        anchors.fill: parent
        source: screenshotPath
    }
	anchors {
		top: true
		bottom: true 
		left: true
		right: true
	}

	Rectangle {
        anchors {
            left: parent.left
            right: selection.left
            top: parent.top
            bottom: parent.bottom
        }
        color: Qt.rgba(0, 0, 0, 0.5)
    }
    Rectangle {
        anchors {
            left: selection.left
            right: selection.right
            top: parent.top
            bottom: selection.top
        }
        color: Qt.rgba(0, 0, 0, 0.5)
    }
    Rectangle {
        anchors {
            left: selection.left
            right: selection.right
            top: selection.bottom
            bottom: parent.bottom
        }
        color: Qt.rgba(0, 0, 0, 0.5)
    }
    Rectangle {
        anchors {
            left: selection.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        color: Qt.rgba(0, 0, 0, 0.5)
    }
    function updateRect() {
        selection.x = Math.min(initialPosition.x, finalPosition.x)
        selection.y = Math.min(initialPosition.y, finalPosition.y)
        selection.width = Math.abs(initialPosition.x - finalPosition.x)
        selection.height = Math.abs(initialPosition.y - finalPosition.y)
        //hacky but we need to grab input
        if (keyboardgrabber.focus == false) { keyboardgrabber.focus = true}
    }
    function fixPositions() {
        let initx = initialPosition.x
        let finx = finalPosition.x
        let inity = initialPosition.y
        let finy = finalPosition.y
        if (initialPosition.x > finalPosition.x) {
            initialPosition.x = finx
            finalPosition.x = initx
        }
        if (initialPosition.y > finalPosition.y) {
            initialPosition.y = finy
            finalPosition.y = inity
        }
        updateRect()
    }
    MouseArea {
        id: bigmouse
        anchors.fill: parent
        onPressed: (mouseEvent) => {
            showDots = false
            initialPosition = Qt.point(mouseEvent.x, mouseEvent.y)
            finalPosition = Qt.point(mouseEvent.x, mouseEvent.y)
            updateRect()
        }
        onPositionChanged: (mouseEvent) => {
            finalPosition = Qt.point(mouseEvent.x, mouseEvent.y)
            updateRect()
        }
        onReleased: {fixPositions(); updateRect(); showDots = true}
    }

    Rectangle {
        id: selection
        color: "transparent"
        width: 0
        height: 0
        x: -5000
        y: -5000
        property point revolutionPosition: Qt.point(0,0)
        OuterBorder {
            color: Shared.textColor
            borderWidth: 1
        }
        MouseArea {
            anchors.fill: parent
            onPressed: (mouseEvent) => {
                selection.revolutionPosition = Qt.point(mouseEvent.x, mouseEvent.y)
            }
            onPositionChanged: (mouseEvent) => {
                initialPosition = selection.mapToItem(bigmouse, mouseEvent.x - selection.revolutionPosition.x, mouseEvent.y - selection.revolutionPosition.y)
                initialPosition = Qt.point(Math.min(Math.max(initialPosition.x, 0), bigmouse.width - selection.width), Math.min(Math.max(initialPosition.y, 0), bigmouse.height - selection.height))
                finalPosition = Qt.point(initialPosition.x + selection.width, initialPosition.y + selection.height)
                updateRect()
            }
        }   
        ScreenshotGrabSpot {
            id: topleft
            showWhen: showDots
            anchors {
                horizontalCenter: parent.left
                verticalCenter: parent.top
            }
            onPressed: (mouseEvent) => {
                initialPosition = topleft.mapToItem(bigmouse, mouseEvent.x, mouseEvent.y)
                showDots = false
                updateRect()
            }
            onPositionChanged: (mouseEvent) => {initialPosition = topleft.mapToItem(bigmouse, mouseEvent.x, mouseEvent.y); updateRect()}
            onReleased: {fixPositions(); showDots = true}
        }
        ScreenshotGrabSpot {
            id: topright
            showWhen: showDots
            anchors {
                horizontalCenter: parent.right
                verticalCenter: parent.top
            }
            onPressed: (mouseEvent) => {
                finalPosition = Qt.point(topright.mapToItem(bigmouse, mouseEvent.x, 0).x, finalPosition.y)
                initialPosition = Qt.point(initialPosition.x, topright.mapToItem(bigmouse, 0, mouseEvent.y).y)
                showDots = false
                updateRect()
            }
            onPositionChanged: (mouseEvent) => {
                finalPosition = Qt.point(topright.mapToItem(bigmouse, mouseEvent.x, 0).x, finalPosition.y)
                initialPosition = Qt.point(initialPosition.x, topright.mapToItem(bigmouse, 0, mouseEvent.y).y)
                updateRect()
            }
            onReleased: {fixPositions(); showDots = true}
        }
        ScreenshotGrabSpot {
            id: bottomleft
            showWhen: showDots
            anchors {
                horizontalCenter: parent.left
                verticalCenter: parent.bottom
            }
            onPressed: (mouseEvent) => {
                initialPosition = Qt.point(bottomleft.mapToItem(bigmouse, mouseEvent.x, 0).x, initialPosition.y)
                finalPosition = Qt.point(finalPosition.x, bottomleft.mapToItem(bigmouse, 0, mouseEvent.y).y)
                showDots = false
                updateRect()
            }
            onPositionChanged: (mouseEvent) => {
                initialPosition = Qt.point(bottomleft.mapToItem(bigmouse, mouseEvent.x, 0).x, initialPosition.y)
                finalPosition = Qt.point(finalPosition.x, bottomleft.mapToItem(bigmouse, 0, mouseEvent.y).y)
                updateRect()
            }
            onReleased: {fixPositions(); showDots = true}
        }
        ScreenshotGrabSpot {
            id: bottomright
            showWhen: showDots
            anchors {
                horizontalCenter: parent.right
                verticalCenter: parent.bottom
            }
            onPressed: (mouseEvent) => {
                finalPosition = bottomright.mapToItem(bigmouse, mouseEvent.x, mouseEvent.y)
                showDots = false
                updateRect()
            }
            onPositionChanged: (mouseEvent) => {finalPosition = bottomright.mapToItem(bigmouse, mouseEvent.x, mouseEvent.y); updateRect()}
            onReleased: {fixPositions(); showDots = true}
        }
    }
}