import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

Shape {
    property string orientation: "tr"
    property real size: 10
    width: size
    height: size
    asynchronous: true
    preferredRendererType: Shape.CurveRenderer
    property color color: Qt.hsva(0, 0, 0, 1)
    //layer.enabled: true
    //layer.smooth: true
    //layer.samples: 4
    fillMode: Shape.Stretch
    ShapePath {
        id: cornershaper
        strokeColor: "transparent"
        strokeWidth: -1
        fillColor: color
        startX: (orientation == "tr") + (orientation == "br")
        startY: (orientation == "bl") + (orientation == "br")
        PathLine {
            x: (orientation == "tl") + (orientation == "tr")
            y: cornershaper.startX //same as startX
        }
        PathArc {
            x: cornershaper.startY //same as startY
            y: (orientation == "tl") + (orientation == "bl")
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