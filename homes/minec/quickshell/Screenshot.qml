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
    property double existenceStart: 0
    //property point Shared.screenshotInitialPosition: Qt.point(-5000,-5000)
    //property point Shared.screenshotFinalPosition: Qt.point(-5000,-5000)
    property bool showDots: false
    //this is done rather than using the scale property since hyprland rounds the scaling factor when sending it out, funnily enough
    property var screenScale: Hyprland.monitorFor(screen).height / screen.height
    Item {
        id: keyboardgrabber
        anchors.fill: parent
        focus: true
        Keys.onReleased: (event) => {
            if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                Shared.saveScreenshot()
            } else if (event.key == Qt.Key_Escape) {
                Shared.screenshotTrigger()
            }
        }
    }

    /*ScreencopyView {
		id: screencap
		anchors.fill: parent
		captureSource: Quickshell.screens[0]
        property double existenceStarhjt: 0
        Component.onCompleted: () => {
            existenceStarhjt = Date.now()
        }
		onHasContentChanged: () => {
			if (screencap.hasContent) {
				console.log("captured screen")
				screencap.grabToImage(function(result) {
					console.log(`took ${Date.now() - screenshotpanel.existenceStart} ms to take screenshot with screencopyview`)
                    console.log(`from beginning of screencopyview, ${Date.now() - existenceStarhjt} ms have passed`)
                    console.log(result.url)
                    result.saveToFile("something.png")
				})
			}
		}
	}*/
    
    property bool screenshotBeingSaved: Shared.savingScreenshot
    onScreenshotBeingSavedChanged: () => {
        selection.color = Qt.rgba(1, 1, 1, 1)
        selection.flash.running = true
    }
    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
        }
        Shared.screenshotInitialPosition = Qt.point(-5000,-5000)
        existenceStart = Date.now()
    }

    Image {
        id: screenfreeze
        source: Shared.screenshotFilePath
        fillMode: Image.PreserveAspectFit
        width: sourceSize.width/screenScale
        height: sourceSize.height/screenScale
        x: -screen.x
        y: screen.y
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
    property point screenshotPosInitial: Shared.screenshotInitialPosition
    property point screenshotPosFinal: Shared.screenshotInitialPosition

    function fixPositions() {
        if (Shared.screenshotWidth < 0) {
            Shared.screenshotInitialPosition = Qt.point(Shared.screenshotInitialPosition.x + Shared.screenshotWidth, Shared.screenshotInitialPosition.y)
            Shared.screenshotWidth = -Shared.screenshotWidth
        }
        if (Shared.screenshotHeight < 0) {
            Shared.screenshotInitialPosition = Qt.point(Shared.screenshotInitialPosition.x, Shared.screenshotInitialPosition.y + Shared.screenshotHeight)
            Shared.screenshotHeight = -Shared.screenshotHeight
        }
    }
    function resizeRect(corner, mousePos) {
        const oldInitialPosition = Qt.point(Shared.screenshotInitialPosition.x, Shared.screenshotInitialPosition.y)
        if (corner == "topleft") {
            Shared.screenshotInitialPosition = Qt.point(mousePos.x + screen.x, mousePos.y + screen.y)
            Shared.screenshotWidth = Shared.screenshotWidth + (oldInitialPosition.x - Shared.screenshotInitialPosition.x)
            Shared.screenshotHeight = Shared.screenshotHeight + (oldInitialPosition.y - Shared.screenshotInitialPosition.y)
        } else if (corner == "topright") {
            Shared.screenshotInitialPosition = Qt.point(Shared.screenshotInitialPosition.x, mousePos.y + screen.y)
            Shared.screenshotWidth = (mousePos.x + screen.x) - Shared.screenshotInitialPosition.x
            Shared.screenshotHeight = oldInitialPosition.y + Shared.screenshotHeight -(mousePos.y + screen.y)
        } else if (corner == "bottomleft") {
            Shared.screenshotInitialPosition = Qt.point(mousePos.x + screen.x, Shared.screenshotInitialPosition.y)
            Shared.screenshotWidth = oldInitialPosition.x + Shared.screenshotWidth -(mousePos.x + screen.x)
            Shared.screenshotHeight = (mousePos.y + screen.y) - Shared.screenshotInitialPosition.y
        } else if (corner == "bottomright") {
            Shared.screenshotWidth = (mousePos.x + screen.x) - Shared.screenshotInitialPosition.x
            Shared.screenshotHeight = (mousePos.y + screen.y) - Shared.screenshotInitialPosition.y
        }
    }
    MouseArea {
        id: bigmouse
        anchors.fill: parent
        onPressed: (mouseEvent) => {
            Shared.screenshotShowCorners = false
            Shared.screenshotInitialPosition = Qt.point(mouseEvent.x + screen.x, mouseEvent.y + screen.y)
            Shared.screenshotWidth = 0
            Shared.screenshotHeight = 0
        }
        onPositionChanged: (mouseEvent) => {
            Shared.screenshotWidth = mouseEvent.x + screen.x - Shared.screenshotInitialPosition.x
            Shared.screenshotHeight = mouseEvent.y + screen.y - Shared.screenshotInitialPosition.y
        }
        onReleased: {Shared.screenshotShowCorners = true; fixPositions()}
    }

    Rectangle {
        id: selection
        color: Qt.rgba(1,1,1,0)

        property ColorAnimation flash: ColorAnimation { 
            id: flash
            target: selection
            easing.type: Easing.OutCirc
            property: "color"
            to: Qt.rgba(1, 1, 1, 0)
            duration: 400 
        }

        width: Math.abs(Shared.screenshotWidth)
        height: Math.abs(Shared.screenshotHeight)
        x: (Shared.screenshotWidth < 0? Shared.screenshotInitialPosition.x + Shared.screenshotWidth: Shared.screenshotInitialPosition.x) - screen.x
        y: (Shared.screenshotHeight < 0? Shared.screenshotInitialPosition.y + Shared.screenshotHeight: Shared.screenshotInitialPosition.y) - screen.y
        property point revolutionPosition: Qt.point(0,0)
        
        OuterBorder {
            color: Shared.colors.on_surface
            borderWidth: 1
        }
        MouseArea {
            anchors.fill: parent
            onPressed: (mouseEvent) => {
                selection.revolutionPosition = Qt.point(mouseEvent.x, mouseEvent.y)
                Shared.screenshotShowCorners = false
            }
            onPositionChanged: (mouseEvent) => {
                const mousePos = selection.mapToItem(bigmouse, mouseEvent.x - selection.revolutionPosition.x, mouseEvent.y - selection.revolutionPosition.y)
                Shared.screenshotInitialPosition = Qt.point(
                    Math.min(Math.max(mousePos.x + screen.x, 0), Shared.screensBoundingBox.width-Shared.screenshotWidth),
                    Math.min(Math.max(mousePos.y + screen.y, 0), Shared.screensBoundingBox.height-Shared.screenshotHeight)
                )
            }
            onReleased: {Shared.screenshotShowCorners = true; fixPositions()}
        }   
        ScreenshotGrabSpot {
            id: topleft
            corner: "topleft"
            showWhen: Shared.screenshotShowCorners
            fullHide: Math.abs(Shared.screenshotWidth) < width || Math.abs(Shared.screenshotHeight) < height
            anchors {
                horizontalCenter: parent.left
                verticalCenter: parent.top
            } 
            onPressed: (mouseEvent) => {
                Shared.screenshotShowCorners = false
            }
            onPositionChanged: (mouseEvent) => {
                const mousePos = topleft.mapToItem(bigmouse, mouseEvent.x, mouseEvent.y)
                resizeRect("topleft", mousePos)
            }
            onReleased: {Shared.screenshotShowCorners = true; fixPositions()}
        }
        ScreenshotGrabSpot {
            id: topright
            corner: "topright"
            showWhen: Shared.screenshotShowCorners
            fullHide: Math.abs(Shared.screenshotWidth) < width || Math.abs(Shared.screenshotHeight) < height
            anchors {
                horizontalCenter: parent.right
                verticalCenter: parent.top
            }
            onPressed: (mouseEvent) => {
                Shared.screenshotShowCorners = false
            }
            onPositionChanged: (mouseEvent) => {
                const mousePos = topright.mapToItem(bigmouse, mouseEvent.x, mouseEvent.y)
                resizeRect("topright", mousePos)

            }
            onReleased: {Shared.screenshotShowCorners = true; fixPositions()}
        }
        ScreenshotGrabSpot {
            id: bottomleft
            corner: "bottomleft"
            showWhen: Shared.screenshotShowCorners
            fullHide: Math.abs(Shared.screenshotWidth) < width || Math.abs(Shared.screenshotHeight) < height
            anchors {
                horizontalCenter: parent.left
                verticalCenter: parent.bottom
            }
            onPressed: (mouseEvent) => {
                Shared.screenshotShowCorners = false
            }
            onPositionChanged: (mouseEvent) => {
                const mousePos = bottomleft.mapToItem(bigmouse, mouseEvent.x, mouseEvent.y)
                resizeRect("bottomleft", mousePos)
            }
            onReleased: {Shared.screenshotShowCorners = true; fixPositions()}
        }
        ScreenshotGrabSpot {
            id: bottomright
            corner: "bottomright"
            showWhen: Shared.screenshotShowCorners
            fullHide: Math.abs(Shared.screenshotWidth) < width || Math.abs(Shared.screenshotHeight) < height
            anchors {
                horizontalCenter: parent.right
                verticalCenter: parent.bottom
            }
            onPressed: (mouseEvent) => {
                Shared.screenshotShowCorners = false
            }
            onPositionChanged: (mouseEvent) => {
                const mousePos = bottomright.mapToItem(bigmouse, mouseEvent.x, mouseEvent.y)
                resizeRect("bottomright", mousePos)
            }
            onReleased: {Shared.screenshotShowCorners = true; fixPositions()}
        }
    }
}