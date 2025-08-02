pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtMultimedia

Singleton {
	//properties of UI
	property var panels: []
	property int margin: 8
	property int rounding: 16
	property bool barsShown: false
	property int floatingCounter: 0

	property color backgroundColor: Qt.hsva(277.5/360, 34.5/100, 14.3/100,1)
	property color borderColor: Qt.rgba(1,1,1,0.08);
	property color textColor: Qt.rgba(1,1,1,1);
	property color subtextColor: Qt.rgba(0.9,0.9,0.9, 1);
	property var iconsPath: Qt.resolvedUrl("./assets/icons")
	// system stats
	property int ramCapacity: 1
	property int usedRam: 2
	property int cpuUsage: 0
	property string internetInterface: "enp42s0"
	property double totalDownload
	property double totalUpload
	property string uploadRate: "0 B/s"
	property string downloadRate: "0 B/s"
	property var dataPrefixes: ["", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei"]
	property bool overviewVisible: false

	property string screenshotFilePath: ""
	property bool screenshotTaken: false
	property int hyprlandRadius: 10
	property int hyprlandBorderSize: 2

	NotificationServer {
		onNotification: (notification) => {
			console.log("Notification recieved!", notification.appName, notification.body, notification.summary)
		}
	}
	property point screenshotInitialPosition: Qt.point(-5000, -5000)
	property bool screenshotShowCorners: true
	property var screenshotWidth: 0
	property var screenshotHeight: 0
	property var screensBoundingBox: (Quickshell.screens.reduce((acc, screen) => {
		if (screen.x >= acc.x) {
			acc.x = screen.x
			acc.width = screen.x + screen.width
		}
		if (screen.y >= acc.y) {
			acc.y = screen.y
			acc.height = screen.y + screen.height
		}
		return acc
	}, {x: 0, width: 0, y: 0, height: 0}))
	
	// other properties
	property var time: new Date();
	property var days: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	property var months: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	
	//colors
	FileView {
		// matugen image wallpaperRender.png --dry-run --json rgb
		id: colorFile
		path: Qt.resolvedUrl("./colorscheme.json")
		blockLoading: true
	}
	function colorParse(text) {
		let colorSchemes = {}
		let colorsInString = JSON.parse(text).colors
		for (const [schema, schemaColors] of Object.entries(colorsInString)) {
			let colors = {}
			for (const [color, rgb] of Object.entries(schemaColors)) {
				let match = rgb.match(/rgb\s*\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*\)/)
				if (match) {
					colors[color] = Qt.rgba(match[1]/255, match[2]/255, match[3]/255, 1)
				} else {
					colors[color] = Qt.rgba(0,0,0,1)
				}
			}
			colorSchemes[schema] = colors
		}
		return colorSchemes
	}
	readonly property var colorSchemes: colorParse(colorFile.text())

	property var colors: colorSchemes.dark
	
	property var inlineTopLevels: ToplevelManager.toplevels.values.length
	onInlineTopLevelsChanged: () => {
		Hyprland.refreshToplevels()
	}
	Connections {
		target: Hyprland
		onRawEvent: (event) => {
			if (event.name != "movewindowv2") {return}
			Hyprland.refreshToplevels()
		}
	}
	/*Process {
		id: colorgen
		command: ["sh","-c", `ssfile=$(mktemp /tmp/ssXXXXXX.png); grim "$ssfile"; matugen image "$ssfile" --dry-run --json rgb; rm "$ssfile"`]
		running: false //persist.loadColors
		stdout: SplitParser {
			onRead: data => {
				
			}
		}
	}*/
	
	//stats commands
	Process {
		id: getmaxram
		command: ["sh", "-c", "free | awk '/Mem/ {print $2}'"]
		running: true //initial run
		stdout: SplitParser {
			onRead: (data) => {
				ramCapacity = parseInt(data)
			}
		}
	}
	Process {
		id: getcurrentram
		command: ["sh", "-c", "free | awk '/Mem/ {print $3}'"]
		running: true //initial run
		stdout: SplitParser {
			onRead: (data) => {
				usedRam = parseInt(data)
			}
		}
	}
	Process {
		id: getcurrentcpu
		command: ["sh", "-c", "mpstat 1 1 -o JSON | grep 'cpu\":' | awk -F ' ' '{print 100 - $22}'"]
		running: true //initial run
		stdout: SplitParser {
			onRead: (data) => {
				cpuUsage = parseInt(data)
			}
		}
	}

	Process {
		id: getcurrentnetworks
		command: ["sh", "-c", `cat /proc/net/dev | awk '/${internetInterface}/ {print $2 "-" $10}'`]
		running: true //initial run
		stdout: SplitParser {
			onRead: (data) => {
				let [download, upload] = data.split("-")
				download = Number(download)
				upload = Number(upload)
				if (!totalDownload || !totalUpload) {
					totalDownload = Number(download)
					totalUpload = Number(upload)
					return
				}
				let drate = download - totalDownload
				let dprefixIndex = Math.max(Math.floor(Math.log(drate)/Math.log(1000)), 0)

				let urate = upload - totalUpload
				let uprefixIndex = Math.max(Math.floor(Math.log(urate)/Math.log(1000)), 0)


				downloadRate = `${(drate/(1024**dprefixIndex)).toPrecision(3)} ${dataPrefixes[dprefixIndex]}B/s`
				uploadRate = `${(urate/(1024**uprefixIndex)).toPrecision(3)} ${dataPrefixes[uprefixIndex]}B/s`
				totalDownload = download
				totalUpload = upload

			}
		}
	}
	
	// cat /proc/net/dev | awk '/enp42s0/ {print $2}'] //total downloaded
	// hyprctl dispatch workspace e+1

	function randomString(length) {
		let result = '';
		const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
		for (let i = 0; i < length; i++) {
			result += letters.charAt(Math.floor(Math.random() * letters.length));
		}
		return result;
	}
	property double screenyexistence: 0
	property Process screenshotProcess: Process {
		id: screenshot_process
		command: ["grim", `${screenshotFilePath}`]
		running: false
		onRunningChanged: () => {
			if (!running) {
				screenshotTaken = true
				console.log(`screenshot taken in ${Date.now() - screenyexistence} ms`)
			}
		}
	}
	property bool savingScreenshot: false
	SoundEffect {
        id: shutterSound
        source: "assets/shutter2.wav"
    }
	Process {
		id: removescreenshot
		command: ["rm", `${screenshotFilePath}`]
		running: false
	}

	Process {
		id: savescreenshot
        // magick /tmp/ssXZyNr3.png -crop 32x32+30+10 wa.png
		running: false
        onRunningChanged: () => {
			if (!running) {
				removescreenshot.command = ["rm", `${screenshotFilePath}`]
				screenshotFilePath = ""
				screenshotTaken = false
				savingScreenshot = false
				removescreenshot.running = true
			}
        }
	}
	function saveScreenshot() {
		if (savingScreenshot) return
		shutterSound.play()
		savingScreenshot = true
		const firstScreenScale = Hyprland.monitorFor(Quickshell.screens[0]).height / Quickshell.screens[0].height
		const width = Math.abs(screenshotWidth)*firstScreenScale
		const height = Math.abs(screenshotHeight)*firstScreenScale
		const x = screenshotInitialPosition.x*firstScreenScale
		const y = screenshotInitialPosition.y*firstScreenScale
		savescreenshot.command = ["sh", "-c", `magick ${screenshotFilePath} -crop ${width}x${height}+${x}+${y} - | wl-copy`]
		savescreenshot.running = true
	}
	function screenshotTrigger() {
		if (screenshotProcess.running) return
		if (screenshotTaken) {
			//destroy it
			screenshotFilePath = ""
			screenshotTaken = false
		} else {
			screenyexistence = Date.now()
			screenshotFilePath = `/tmp/${randomString(8)}.png`
			//screenshotProcess.command =  ["grim", `${screenshotFilePath}`]
			screenshotProcess.running = true
		}
	}
	IpcHandler {
    	target: "shell"
		function toggleBar() { 
			for (const panel of panels) {
				panel.keybindReveal()
			}
			//print("Bar toggled!")
		}
		function screenshot() {
			screenshotTrigger()
		}
		function overview() {
			if (Shared.overviewVisible == false) {
				Hyprland.refreshToplevels()
				Shared.overviewVisible = true
				Hyprland.dispatch("workspace e+1")
			} else {
				Hyprland.dispatch("workspace e+1")
			}
		}
		function overviewClose() {
			Shared.overviewVisible = false
		}
	}

	Timer {
		interval: 1000
		running: true
		repeat: true

		onTriggered: () => {
			time = new Date()
			getcurrentnetworks.running = true
		}
	}
	Timer {
		//slow timer for more demanding... things?
		interval: 3000
		running: true
		repeat: true

		onTriggered: () => {
			getcurrentram.running = true
			getcurrentcpu.running = true
		}
	}
}
