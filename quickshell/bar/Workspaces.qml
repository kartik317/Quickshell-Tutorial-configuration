import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../theme"
Item {
    property string fontFamily
    property int fontSize
    implicitWidth: 30
    implicitHeight: 9 * 20
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Repeater {
            model: 9
            Rectangle {
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 20
                color: "transparent"
                property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                property bool hasWindows: (workspace?.toplevels?.values?.length ?? 0) > 0
                Text {
                    text: index + 1
                    color: (parent.isActive || parent.hasWindows) ? Colors.colFg : Colors.colBrightBlack
                    font.pixelSize: fontSize
                    font.family: fontFamily
                    font.bold: true
                    anchors.centerIn: parent
                }
                Rectangle {
                    width: 3
                    height: 20
                    color: parent.isActive ? Colors.colPurple : Colors.colBg
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (index + 1) + " })")
                }
            }
        }
    }
}
