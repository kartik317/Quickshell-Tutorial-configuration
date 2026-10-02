// anim-lab.qml  --  run with:  qs -p anim-lab.qml
import QtQuick
import QtQuick.Layouts
import Quickshell

ShellRoot {
    FloatingWindow {
        implicitWidth: 1200
        implicitHeight: 620
        color: "#0d1117"

        // Reusable card: title + a "stage" area where demos live
        component Card: Rectangle {
            id: card
            property string title: ""
            property string hint: ""
            default property alias content: stage.data

            color: "#161b22"
            radius: 8
            border.color: "#30363d"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100

            Text {
                id: head
                text: card.title
                color: "#58a6ff"
                font.family: "monospace"
                font.pixelSize: 13
                anchors { top: parent.top; left: parent.left; margins: 10 }
            }
            Text {
                text: card.hint
                color: "#6e7681"
                font.family: "monospace"
                font.pixelSize: 11
                anchors { top: parent.top; right: parent.right; margins: 10 }
            }
            Item {
                id: stage
                anchors { top: head.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; margins: 12 }
                clip: true
            }
        }

        GridLayout {
            anchors.fill: parent
            anchors.margins: 12
            columns: 4
            rowSpacing: 12
            columnSpacing: 12

            // 1. BEHAVIOR -------------------------------------------------
            // "When x or y changes, animate it." Click anywhere to move the box.
            Card {
                title: "1 Behavior"; hint: "click"
                Rectangle {
                    id: b1
                    width: 40; height: 40; radius: 6
                    color: "#f78166"
                    x: 20; y: 20
                    Behavior on x { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse => {
                        b1.x = mouse.x - b1.width / 2
                        b1.y = mouse.y - b1.height / 2
                    }
                }
            }

            // 2. HOVER: scale + color + radius ---------------------------
            // Three Behaviors driven by one boolean (hov.containsMouse).
            Card {
                title: "2 Hover"; hint: "mouse over"
                Rectangle {
                    anchors.centerIn: parent
                    width: 90; height: 90
                    radius: hov.containsMouse ? 45 : 10
                    color: hov.containsMouse ? "#3fb950" : "#30363d"
                    scale: hov.containsMouse ? 1.25 : 1.0

                    Behavior on scale  { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                    Behavior on radius { NumberAnimation { duration: 250 } }
                    Behavior on color  { ColorAnimation  { duration: 250 } }

                    MouseArea { id: hov; anchors.fill: parent; hoverEnabled: true }
                }
            }

            // 3. EASING RACE ----------------------------------------------
            // Same duration, different curves. Click to race.
            Card {
                id: c3
                title: "3 Easing"; hint: "click"
                property bool go: false

                Column {
                    anchors.fill: parent
                    spacing: 10
                    Repeater {
                        model: [
                            { n: "Linear",     t: Easing.Linear },
                            { n: "InOutQuad",  t: Easing.InOutQuad },
                            { n: "OutBounce",  t: Easing.OutBounce },
                            { n: "OutElastic", t: Easing.OutElastic },
                            { n: "OutBack",    t: Easing.OutBack }
                        ]
                        Item {
                            width: parent.width
                            height: 22
                            Text {
                                text: modelData.n
                                color: "#6e7681"
                                font.pixelSize: 10
                                anchors.centerIn: parent
                            }
                            Rectangle {
                                width: 18; height: 18; radius: 9
                                color: "#d2a8ff"
                                x: c3.go ? parent.width - width : 0
                                Behavior on x {
                                    NumberAnimation { duration: 1000; easing.type: modelData.t }
                                }
                            }
                        }
                    }
                }
                MouseArea { anchors.fill: parent; onClicked: c3.go = !c3.go }
            }

            // 4. SEQUENTIAL + PARALLEL ------------------------------------
            // Grow+fade together (Parallel), shrink+unfade together, pause, repeat.
            Card {
                title: "4 Sequential + Parallel"
                Rectangle {
                    id: b4
                    anchors.centerIn: parent
                    width: 70; height: 70; radius: 35
                    color: "#58a6ff"

                    SequentialAnimation {
                        running: true
                        loops: Animation.Infinite
                        ParallelAnimation {
                            NumberAnimation { target: b4; property: "scale";   to: 1.5; duration: 600; easing.type: Easing.InOutSine }
                            NumberAnimation { target: b4; property: "opacity"; to: 0.3; duration: 600 }
                        }
                        ParallelAnimation {
                            NumberAnimation { target: b4; property: "scale";   to: 1.0; duration: 600; easing.type: Easing.InOutSine }
                            NumberAnimation { target: b4; property: "opacity"; to: 1.0; duration: 600 }
                        }
                        PauseAnimation { duration: 300 }
                    }
                }
            }

            // 5. STATES + TRANSITIONS -------------------------------------
            // Declare what "big" looks like; the Transition says how to get there.
            Card {
                title: "5 States + Transitions"; hint: "click box"
                Rectangle {
                    id: b5
                    x: 0; y: 10
                    width: 60; height: 60; radius: 8
                    color: "#d29922"

                    states: State {
                        name: "big"
                        PropertyChanges { target: b5; width: 220; height: 130; color: "#f85149" }
                    }
                    transitions: Transition {
                        NumberAnimation { properties: "width,height"; duration: 400; easing.type: Easing.OutBack }
                        ColorAnimation { duration: 400 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: b5.state = (b5.state === "big") ? "" : "big"
                    }
                }
            }

            // 6. SPRING ---------------------------------------------------
            // No duration: physics. Raise spring = snappier, raise damping = less bounce.
            Card {
                title: "6 SpringAnimation"; hint: "move mouse"
                Rectangle {
                    id: b6
                    width: 36; height: 36; radius: 18
                    color: "#3fb950"
                    x: ma6.mouseX - width / 2
                    y: ma6.mouseY - height / 2
                    Behavior on x { SpringAnimation { spring: 3; damping: 0.15 } }
                    Behavior on y { SpringAnimation { spring: 3; damping: 0.15 } }
                }
                MouseArea { id: ma6; anchors.fill: parent; hoverEnabled: true }
            }

            // 7. ANIMATOR + "on" syntax ------------------------------------
            // RotationAnimator runs on the render thread (stays smooth under load).
            // "X on property" starts automatically, no id/target needed.
            Card {
                title: "7 Animator + 'on'"
                Rectangle {
                    anchors.centerIn: parent
                    width: 80; height: 80; radius: 14
                    color: "#bc8cff"

                    Rectangle {
                        width: 12; height: 12; radius: 6
                        color: "white"
                        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; margins: 6 }
                    }

                    RotationAnimator on rotation {
                        from: 0; to: 360
                        duration: 1800
                        loops: Animation.Infinite
                    }
                    SequentialAnimation on color {
                        loops: Animation.Infinite
                        ColorAnimation { to: "#58a6ff"; duration: 1500 }
                        ColorAnimation { to: "#bc8cff"; duration: 1500 }
                    }
                }
            }

            // 8. STAGGER --------------------------------------------------
            // Each bar waits index*100ms once, then loops forever -> wave effect.
            Card {
                title: "8 Staggered wave"
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Repeater {
                        model: 8
                        Item {
                            width: 14; height: 110
                            Rectangle {
                                id: bar
                                width: 14; height: 20; radius: 3
                                color: "#79c0ff"
                                anchors.bottom: parent.bottom
                            }
                            SequentialAnimation {
                                running: true
                                PauseAnimation { duration: index * 100 }
                                SequentialAnimation {
                                    loops: Animation.Infinite
                                    NumberAnimation { target: bar; property: "height"; to: 100; duration: 450; easing.type: Easing.InOutSine }
                                    NumberAnimation { target: bar; property: "height"; to: 20;  duration: 450; easing.type: Easing.InOutSine }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

