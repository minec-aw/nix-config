pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications

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
	property var iconsPath: Qt.resolvedUrl("./icons")
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


	NotificationServer {
		onNotification: (notification) => {
			console.log("Notification recieved!", notification.appName, notification.body, notification.summary)
		}
	}

	
	// other properties
	property bool takingScreenshot: false
	property var extinctList: []
	property var time: new Date();
	property var days: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	property var months: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	
	property PersistentProperties persist: PersistentProperties { // save between reloads
		id: persist
		reloadableId: "persistedStates"

		property var toplevels: []
		property var workspaceTopLevels: []
		property var tlAddresses: []
	}
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
	
	property var toplevels: []
	property var workspaceTopLevels: []
	property var tlAddresses: []
	
	property var inlineTopLevels: ToplevelManager.toplevels.values.length
	onInlineTopLevelsChanged: () => {
		flower.running = true
	}
	Connections {
		target: Hyprland
		onRawEvent: (event) => {
			if (event.name != "movewindowv2") {return}
			flower.running = true
		}
	}
	Process {
		id: colorgen
		command: ["sh","-c", `ssfile=$(mktemp /tmp/ssXXXXXX.png); grim "$ssfile"; matugen image "$ssfile" --dry-run --json rgb; rm "$ssfile"`]
		running: false //persist.loadColors
		stdout: SplitParser {
			onRead: data => {
				
			}
		}
	}

	Process {
        id: flower
        command: ["sh", "-c", "hyprctl clients -j | jq -c"]
        running: true
        stdout: SplitParser {
            onRead: data => {
				let levels = [] // sloplevels
				let workspaces = [] //toplevels organized by workspace
				let topLevelsHypr = JSON.parse(data)
				for (let toplevel of topLevelsHypr) {
					if (!tlAddresses.find((value) => value == toplevel.address)) {
						tlAddresses.push(toplevel.address)
					}
				}
				let addressIndexMap = {}
				tlAddresses.forEach((address, index) => {
					addressIndexMap[address] = index;
				})

				topLevelsHypr = topLevelsHypr.sort((a, b) => {
					return addressIndexMap[a.address] - addressIndexMap[b.address]
				})

				const validTopLevels = new Set(topLevelsHypr.map(obj => obj.address))
				tlAddresses = tlAddresses.filter(address => validTopLevels.has(address))

				for (let index in ToplevelManager.toplevels.values) {
					let topLevel = ToplevelManager.toplevels.values[index]
					levels.push({toplevel: topLevel, position: topLevelsHypr[index].at, workspace: topLevelsHypr[index].workspace, pid: topLevelsHypr[index].pid})
				}
				for (let workspace of Hyprland.workspaces.values) {
					let q = {workspace: workspace, id: workspace.id, toplevels: levels.filter((toplevel) => toplevel.workspace.id == workspace.id)}
					workspaces.push(q)
				}
				toplevels = levels
				workspaceTopLevels = workspaces

            }
        }
    }

	function registerFileForExtinction(filePath) {
		extinctList.push(filePath)
	}
	onTakingScreenshotChanged: () => {
		if (takingScreenshot == false) {
			let cmd = ["sh", "-c", `sleep 1 && rm "${extinctList.join('" "')}"`]
			extinctList = []
			clearfiles.command = cmd
			clearfiles.startDetached()
		}
	}
	
	Process {
		id: clearfiles
		command: ["rm"]
		clearEnvironment: true
		running: false
	}
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

	IpcHandler {
    	target: "shell"
		function toggleBar() { 
			Shared.barsShown = !Shared.barsShown
			//print("Bar toggled!")
		}
		function screenshot() { 
			Shared.takingScreenshot = !Shared.takingScreenshot
		}
		function overview() {
			if (Shared.overviewVisible == false) {
				flower.running = true
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
