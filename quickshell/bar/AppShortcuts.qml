import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"

ColumnLayout {
    id: root
    spacing: 10

    // State properties
    property bool isSelecting: false
    property int selectedIndex: 0
    property int totalApps: 6

    Process { id: youtubeProcess; command: ["brave", "--app-id=agimnkijcaahngcdmfeangaknmldooml"] }
    Process { id: discordProcess; command: ["discord"] }
    Process { id: minecraftProcess; command: ["mcpelauncher-ui-qt"] }
    Process { id: steamProcess; command: ["steam"] }
    Process { id: braveProcess; command: ["brave"] }
    Process { id: ytMusicProcess; command: ["brave", "--app-id=cinhimbnkkaeohfgghhklpknlkffjgod"] }

    function launchIndex(idx) {
	switch (idx) {
	    case 0: youtubeProcess.running = true; break;
	    case 1: discordProcess.running = true; break;
	    case 2: minecraftProcess.running = true; break;
	    case 3: steamProcess.running = true; break;
	    case 4: braveProcess.running = true; break;
	    case 5: ytMusicProcess.running = true; break;
	}
    }

    IpcHandler {
	target: "appshortcuts"

	function off(): void {
	    root.isSelecting = false;
	}

	function next(): void {
	    if (!root.isSelecting) {
		root.isSelecting = true;
	    } else {
		root.selectedIndex = (root.selectedIndex + 1) % root.totalApps;
	    }
	}

	function prev(): void {
	    if (!root.isSelecting) {
		root.isSelecting = true;
	    } else {
		root.selectedIndex = (root.selectedIndex - 1 + root.totalApps) % root.totalApps;
	    }
	}

	function launch(): void {
	    if (root.isSelecting) {
		root.launchIndex(root.selectedIndex);
		root.isSelecting = false;
	    }
	}
    }

    // YouTube (0)
    Rectangle {
	Layout.preferredWidth: 20
	Layout.preferredHeight: 20
	Layout.alignment: Qt.AlignHCenter
	color: (root.isSelecting && root.selectedIndex === 0) ? Colors.colFg : "transparent"
	radius: 4

	Text {
	    anchors.centerIn: parent
	    text: "\uf16a"
	    font.family: "JetBrainsMono Nerd Font"
	    font.pixelSize: 18
	    color: (root.isSelecting && root.selectedIndex === 0) ? Colors.colBg : Colors.colFg
	}

	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    onClicked: { root.selectedIndex = 0; youtubeProcess.running = true; root.isSelecting = false; }
	}
    }
    // Discord (1)
    Rectangle {
	Layout.preferredWidth: 20
	Layout.preferredHeight: 20
	Layout.alignment: Qt.AlignHCenter
	color: (root.isSelecting && root.selectedIndex === 1) ? Colors.colFg : "transparent"
	radius: 4

	Text {
	    anchors.centerIn: parent
	    text: "\uf1ff"
	    font.family: "JetBrainsMono Nerd Font"
	    font.pixelSize: 18
	    color: (root.isSelecting && root.selectedIndex === 1) ? Colors.colBg : Colors.colFg
	}

	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    onClicked: { root.selectedIndex = 1; discordProcess.running = true; root.isSelecting = false; }
	}
    }

    // Minecraft (2)
    Rectangle {
	Layout.preferredWidth: 20
	Layout.preferredHeight: 20
	Layout.alignment: Qt.AlignHCenter
	color: (root.isSelecting && root.selectedIndex === 2) ? Colors.colFg : "transparent"
	radius: 4

	Text {
	    anchors.centerIn: parent
	    text: "\udb80\udf73"
	    font.family: "JetBrainsMono Nerd Font"
	    font.pixelSize: 18
	    color: (root.isSelecting && root.selectedIndex === 2) ? Colors.colBg : Colors.colFg
	}

	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    onClicked: { root.selectedIndex = 2; minecraftProcess.running = true; root.isSelecting = false; }
	}
    }

    // Steam (3)
    Rectangle {
	Layout.preferredWidth: 20
	Layout.preferredHeight: 20
	Layout.alignment: Qt.AlignHCenter
	color: (root.isSelecting && root.selectedIndex === 3) ? Colors.colFg : "transparent"
	radius: 4

	Text {
	    anchors.centerIn: parent
	    text: "\uf1b7"
	    font.family: "JetBrainsMono Nerd Font"
	    font.pixelSize: 18
	    color: (root.isSelecting && root.selectedIndex === 3) ? Colors.colBg : Colors.colFg
	}

	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    onClicked: { root.selectedIndex = 3; steamProcess.running = true; root.isSelecting = false; }
	}
    }

    // Brave (4)
    Rectangle {
	Layout.preferredWidth: 20
	Layout.preferredHeight: 20
	Layout.alignment: Qt.AlignHCenter
	color: (root.isSelecting && root.selectedIndex === 4) ? Colors.colFg : "transparent"
	radius: 4

	Text {
	    anchors.centerIn: parent
	    text: "\udb80\ude39"
	    font.family: "JetBrainsMono Nerd Font"
	    font.pixelSize: 20
	    color: (root.isSelecting && root.selectedIndex === 4) ? Colors.colBg : Colors.colFg
	}

	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    onClicked: { root.selectedIndex = 4; braveProcess.running = true; root.isSelecting = false; }
	}
    }

    // YouTube Music (5)
    Rectangle {
	Layout.preferredWidth: 20
	Layout.preferredHeight: 20
	Layout.alignment: Qt.AlignHCenter
	color: (root.isSelecting && root.selectedIndex === 5) ? Colors.colFg : "transparent"
	radius: 4

	Text {
	    anchors.centerIn: parent
	    font.family: "JetBrainsMono Nerd Font"
	    text: "\udb80\udf86"
	    font.pixelSize: 20
	    color: (root.isSelecting && root.selectedIndex === 5) ? Colors.colBg : Colors.colFg
	}

	MouseArea {
	    anchors.fill: parent
	    cursorShape: Qt.PointingHandCursor
	    onClicked: { root.selectedIndex = 5; ytMusicProcess.running = true; root.isSelecting = false; }
	}
    }
}
