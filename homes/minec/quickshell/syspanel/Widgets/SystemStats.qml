import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import ".."
import "../.."

Item {
		id: stats
        width: 370
        clip: true
        height: 50
        Stat {
            id: memory
            anchors.verticalCenter: parent.verticalCenter
            x: 10
            icon: `${Shared.iconsPath}/memory-stick.svg`
            text: `${Math.round((Shared.usedRam/Shared.ramCapacity)*100)}%`
        }
        Stat {
            id: cpu
            anchors.verticalCenter: parent.verticalCenter
            anchors {
                left: memory.right
                leftMargin: 6
            }
            icon: `${Shared.iconsPath}/cpu.svg`
            text: `${Math.round(Shared.cpuUsage)}%`
        }
        Stat {
            id: download
            anchors.verticalCenter: parent.verticalCenter
            anchors {
                left: cpu.right
                leftMargin: 6
            }
            icon: `${Shared.iconsPath}/download.svg`
            text: Shared.downloadRate
        }
        Stat {
            id: upload
            anchors.verticalCenter: parent.verticalCenter
            anchors {
                left: download.right
                leftMargin: 6
            }
            icon: `${Shared.iconsPath}/upload.svg`
            text: Shared.uploadRate
        }
	}