import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    id: root
    property int thickness: 12
    property color borderColor: "#1e1e2d"

    Variants {
        model: Quickshell.screens

        Item {
            id: screenRoot
            required property var modelData

            PanelWindow {
                screen: screenRoot.modelData
                anchors { top: true; left: true; right: true }
                implicitHeight: root.thickness
                exclusiveZone: root.thickness
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "quickshell-border-top"
                color: root.borderColor
            }

            PanelWindow {
                screen: screenRoot.modelData
                anchors { bottom: true; left: true; right: true }
                implicitHeight: root.thickness
                exclusiveZone: root.thickness
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "quickshell-border-bottom"
                color: root.borderColor
            }

            PanelWindow {
                screen: screenRoot.modelData
                anchors { top: true; bottom: true; left: true }
                implicitWidth: root.thickness
                exclusiveZone: root.thickness
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "quickshell-border-left"
                color: root.borderColor
            }

            PanelWindow {
                screen: screenRoot.modelData
                anchors { top: true; bottom: true; right: true }
                implicitWidth: root.thickness
                exclusiveZone: root.thickness
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "quickshell-border-right"
                color: root.borderColor
            }
        }
    }
}
