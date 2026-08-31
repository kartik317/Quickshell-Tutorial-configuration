import QtQuick
import Quickshell
import "./app_launcher"
import "./bar"

ShellRoot {
    Bar {}
    Border {}
    Variants {
	model: Quickshell.screens
	AppLauncher {
	    property var modelData
	    screen: modelData
	}
    }

    RightBar {}

}
