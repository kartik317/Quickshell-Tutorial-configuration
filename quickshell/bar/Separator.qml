import QtQuick
import "../theme"

Rectangle {
    id: root
    property int lineWidth: 24
    property int lineHeight: 1
    property color lineColor: Colors.colFg
    property real lineOpacity: 0.3

    width: lineWidth
    height: lineHeight
    color: lineColor
    opacity: lineOpacity
}
