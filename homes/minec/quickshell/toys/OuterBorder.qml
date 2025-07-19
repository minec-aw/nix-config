import QtQuick

Item {
    id: borderholder
    anchors.fill: parent
    property int borderWidth: 2
    property color color
    Rectangle {
        anchors {right: parent.left; top: parent.top; bottom: parent.bottom; topMargin: -borderWidth; bottomMargin: -borderWidth}
        width: borderholder.borderWidth
        color: borderholder.color
    }
    Rectangle {
        anchors {left: parent.right; top: parent.top; bottom: parent.bottom; topMargin: -borderWidth; bottomMargin: -borderWidth}
        width: borderholder.borderWidth
        color: borderholder.color
    }
    Rectangle {
        anchors {bottom: parent.top; left: parent.left; right: parent.right}
        height: borderholder.borderWidth
        color: borderholder.color
    }
    Rectangle {
        anchors {top: parent.bottom; left: parent.left; right: parent.right}
        height: borderholder.borderWidth
        color: borderholder.color
    }
}