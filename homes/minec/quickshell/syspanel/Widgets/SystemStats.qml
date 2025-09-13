import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import ".."
import "../.."

Item {
		id: stats
        width: childrenRect.width
        clip: true
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        Stat {
            id: memory
            x: 0
            icon: `${Shared.iconsPath}/memory-stick.svg`
            percentage: Shared.usedRam/Shared.ramCapacity
        }
        Stat {
            id: cpu
            anchors.left: memory.right
            anchors {
                //left: memory.right
                leftMargin: 2
            }
            percentage: Shared.cpuUsage/100
            icon: `${Shared.iconsPath}/cpu.svg`
        }
        Stat {
            id: mousestat
            anchors.top: memory.bottom
            anchors {
                //left: memory.right
                topMargin: 6
            }
            percentage: UPower.devices.values.find(device => device.type == UPowerDeviceType.Mouse).percentage || 0
            icon: `${Shared.iconsPath}/mouse.svg`
        }
        Stat {
            id: headphone
            anchors.top: cpu.bottom
            anchors.left: mousestat.right
            anchors {
                leftMargin: 2
                //left: memory.right
                topMargin: 6
            }
            percentage: UPower.devices.values.find(device => device.type == UPowerDeviceType.Headset).percentage || 0
            icon: `${Shared.iconsPath}/headphones.svg`
        }

        
        /*Stat {
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
        }*/
	}