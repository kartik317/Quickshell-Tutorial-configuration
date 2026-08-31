import QtQuick
import Quickshell
import "../theme"

Column {
    spacing: 0

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(clock.date, "HH")
        color: Colors.colFg
        font {
            family: "SF Mono"
            letterSpacing: -1
            pixelSize: 15
            weight: 600
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(clock.date, "mm")
        color: Colors.colFg
        font {
            family: "SF Mono"
            letterSpacing: -1
            pixelSize: 15
            weight: 600
        }
    }
}
