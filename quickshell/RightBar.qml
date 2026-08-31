import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import "./components"

PanelWindow {
    id: barWindow
    property int barWidth: 0  
    property int cornerRadius: 16
    property int borderThickness: 0
    property color barColor: "#1e1e2d"
    color: "transparent"
    anchors.top: true
    anchors.bottom: true
    anchors.right: true
    implicitWidth: borderThickness + barWidth + cornerRadius
    exclusiveZone: borderThickness + barWidth
    WlrLayershell.layer: WlrLayer.Top  

    // --- BAR LAYOUT ---
    Item {
	anchors.fill: parent

	// Main Bar Body (now on the right)
	Rectangle {
	    anchors.top: parent.top
	    anchors.bottom: parent.bottom
	    anchors.right: parent.right
	    width: barWindow.barWidth
	    color: barWindow.barColor
	}

	// Top Inverted Curve (sits to the LEFT of the bar now)
	ConcaveCurves {
	    anchors.top: parent.top
	    anchors.right: parent.right
	    anchors.rightMargin: barWindow.barWidth
	    radius: barWindow.cornerRadius
	    color: barWindow.barColor
	    isTop: true
	    mirrored: true
	}

	// Bottom Inverted Curve
	ConcaveCurves {
	    anchors.bottom: parent.bottom
	    anchors.right: parent.right
	    anchors.rightMargin: barWindow.barWidth
	    radius: barWindow.cornerRadius
	    color: barWindow.barColor
	    isTop: false
	    mirrored: true
	}
    }
}

