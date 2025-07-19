import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import ".."

Item {
	property int animationOrder;
	property int pauseDurationMultiplier: 60
	WidgetBackground {}
	height: parent.height //- (Shared.margin)
	y: - (parent.height + (Shared.margin))
	width: 80
	id: widgetbox
	states: State {
		name: "hovered"; when: bar.show
		AnchorChanges { target: widgetbox; anchors.top: parent.top; anchors.bottom: parent.bottom; }
		PropertyChanges { target: widgetbox; y: 0 }
	}
	transitions: Transition {
		to: "hovered"
		reversible: true
		ParallelAnimation {
			SequentialAnimation {
				PauseAnimation { duration: pauseDurationMultiplier*widgetbox.animationOrder }
				PropertyAnimation { 
					property: "y"
					duration: 200
					easing {
						type: Easing.OutBack
						overshoot: 0
					}
				}
				PauseAnimation { duration: pauseDurationMultiplier*widgetbox.animationOrder }
			}
		}
	}
}