import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."
import "../.."

Item {
	id: notif
    height: 150+24
    width: 400+24
    Rectangle {
        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 12
            topMargin: 12
            bottomMargin: 12
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        radius: 25 //just make it circly
        color: Shared.colors.surface_container

        Image {
            id: icon
            smooth: true
            source: `${Shared.iconsPath}/snowflake.svg`
            height: 20
            width: height
            x: 12
            y: 12
        }

        Text {
            id: title
            text: `App Name * 7m`
            anchors.left: icon.right
            anchors.top: icon.top
            anchors.bottom: icon.bottom
            anchors.leftMargin: 6
            color: Shared.colors.on_surface
            verticalAlignment: Text.AlignVCenter
            font {
                pointSize: 10
                family: "Noto Sans"
            }
        }

        Text {
            id: body
            text: `This is some body text, it is kinda wacky ngl, I really hope it wraps around text because if it doesnt then this will go off the screen`
            x: 38
            anchors.right: parent.right
            anchors.top: title.bottom
            anchors.left: parent.left //should be image of sorts
            
            color: Shared.colors.on_surface
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            font {
                pointSize: 10
                family: "Noto Sans"
            }
        }
    }
}