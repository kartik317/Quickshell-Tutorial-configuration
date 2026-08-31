import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import "../components"
PanelWindow {
    id: barWindow
    property int barWidth: 25
    property int cornerRadius: 16
    property int borderThickness: 12
    property color barColor: "#1e1e2d"
    property color borderColor: "#1e1e2d"
    color: "transparent"
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    implicitWidth: borderThickness + barWidth + cornerRadius
    exclusiveZone: borderThickness + barWidth
    Item {
	anchors.fill: parent
	// Left border strip — z: 0, sits underneath
	Rectangle {
	    id: borderStrip
	    anchors.top: parent.top
	    anchors.bottom: parent.bottom
	    anchors.left: parent.left
	    width: barWindow.borderThickness
	    color: barWindow.borderColor
	    z: 0
	}
	Rectangle {
	    anchors.top: parent.top
	    anchors.bottom: parent.bottom
	    anchors.left: parent.left
	    anchors.leftMargin: 0
	    width: barWindow.borderThickness + barWindow.barWidth
	    color: barWindow.barColor
	    z: 1
	}
	ConcaveCurves {
	    anchors.top: parent.top
	    anchors.left: parent.left
	    anchors.leftMargin: barWindow.borderThickness + barWindow.barWidth
	    radius: barWindow.cornerRadius
	    color: barWindow.barColor
	    isTop: true
	    z: 1
	}
	ConcaveCurves {
	    anchors.bottom: parent.bottom
	    anchors.left: parent.left
	    anchors.leftMargin: barWindow.borderThickness + barWindow.barWidth
	    radius: barWindow.cornerRadius
	    color: barWindow.barColor
	    isTop: false
	    z: 1
	}
    }
    Workspaces {
	id: workspaces
	anchors.top: parent.top
	x: (barWindow.barWidth - width) / 2
    }

    Separator {
	id: separator
	anchors.top: workspaces.bottom
	anchors.topMargin: 15
	x: (barWindow.barWidth - width) / 2
    }

    ColumnLayout {
	anchors.bottom: parent.bottom
	x: (barWindow.barWidth - implicitWidth) / 2
	spacing: 20
	Separator {}
	AppShortcuts {}
	Separator {}
	Battery       { Layout.alignment: Qt.AlignHCenter }
	Separator {}
	Clock         { Layout.alignment: Qt.AlignHCenter }
    }
}
