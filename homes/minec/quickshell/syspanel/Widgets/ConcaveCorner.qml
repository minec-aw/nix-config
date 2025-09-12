import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import ".."
import "../.."

Shape {
    property int orientation: 0
    property int size: 10
    width: size
    height: size
    property color color: Qt.hsva(0, 0, 20/255, 0.5)
    layer.enabled: true
    layer.smooth: true
    layer.samples: 4
    fillMode: Shape.Stretch
    ShapePath {
        id: cornershaper
        strokeColor: "transparent"
        fillColor: color
        startX: (orientation == 1) + (orientation == 3)
        startY: (orientation == 2) + (orientation == 3)
        PathLine {
            x: (orientation == 0) + (orientation == 1)
            y: cornershaper.startX //same as startX
        }
        PathArc {
            x: cornershaper.startY //same as startY
            y: (orientation == 0) + (orientation == 2)
            radiusX: 1; radiusY: 1
            useLargeArc: false
            direction: PathArc.Counterclockwise
        }
        PathLine {
            x: cornershaper.startX //same as startX
            y: cornershaper.startY //same as startY
        }
    } // All orientations combined into 1
    
    
    /*onPaint: {
        var ctx = getContext("2d");
        ctx.fillStyle = color;
        ctx.beginPath();

        if (orientation == 0) { //Top Left orientation
            ctx.moveTo(0,0);
            ctx.lineTo(width,0);
            ctx.arcTo(0,0,0,height,size);
            ctx.lineTo(0,0);
        } else if (orientation == 1) { //Top Right orientation
            ctx.moveTo(width,0);
            ctx.lineTo(0,0);
            ctx.arcTo(width,0,width,height,size);
            ctx.lineTo(width,0);
        } else if (orientation == 2) { //Bottom Left orientation
            ctx.moveTo(0,height);
            ctx.lineTo(width,height);
            ctx.arcTo(0,height,0,0,size);
            ctx.lineTo(0,height);
        } else if (orientation == 3) { // Bottom Right Orientation
            ctx.moveTo(width,height);
            ctx.lineTo(0,height);
            ctx.arcTo(width,height,width,0,size);
            ctx.lineTo(width,height);
        }
        
        ctx.closePath();
        ctx.fill();
    }*/
}