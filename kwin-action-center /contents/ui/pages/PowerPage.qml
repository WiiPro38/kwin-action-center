
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../components"

ColumnLayout {
    readonly property int pagePreferredHeight: 560
    spacing: 10

    SubHeader { title: "Performance & Power" }

    Rectangle {
        visible: root.hasBattery
        Layout.fillWidth: true
        Layout.preferredHeight: 84
        radius: 8
        color: Kirigami.Theme.alternateBackgroundColor
        border.width: 1
        border.color: root.edge

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 14

            Kirigami.Icon {
                source: root.batteryIcon
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                PlasmaComponents.Label {
                    text: root.batteryLevel + "%"
                    font.bold: true
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize + 6
                }
                PlasmaComponents.Label {
                    text: root.statusLabel(root.batteryStatus)
                    opacity: 0.75
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: monCol.implicitHeight + 24
        radius: 8
        color: Kirigami.Theme.alternateBackgroundColor
        border.width: 1
        border.color: root.edge

        ColumnLayout {
            id: monCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                PlasmaComponents.Label { text: "CPU"; Layout.preferredWidth: 60 }
                PlasmaComponents.ProgressBar {
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: root.cpuPct
                }
                PlasmaComponents.Label {
                    text: root.cpuPct + "%"
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                PlasmaComponents.Label { text: "Memory"; Layout.preferredWidth: 60 }
                PlasmaComponents.ProgressBar {
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: root.memPct
                }
                PlasmaComponents.Label {
                    text: root.memPct + "%"
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }

    PlasmaComponents.Label {
        text: "Performance mode"
        font.bold: true
    }

    Repeater {
        model: root.profiles

        Rectangle {
            id: pRow
            required property var modelData
            readonly property bool sel: root.profile === modelData

            Layout.fillWidth: true
            Layout.preferredHeight: 60
            radius: 8
            color: sel ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
            border.width: 1
            border.color: sel ? "transparent" : root.edge
            readonly property color fg: sel ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.setProfile(pRow.modelData)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 12

                AppIcon {
                    name: root.profileIcon(pRow.modelData)
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    color: pRow.fg
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    PlasmaComponents.Label {
                        text: root.profileLabel(pRow.modelData)
                        font.bold: true
                        color: pRow.fg
                    }
                    PlasmaComponents.Label {
                        text: root.profileDesc(pRow.modelData)
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        color: pRow.fg
                        opacity: 0.8
                    }
                }
                AppIcon {
                    visible: pRow.sel
                    name: "check"
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                    color: pRow.fg
                }
            }
        }
    }

    PlasmaComponents.Label {
        visible: root.profileMsg !== ""
        text: root.profileMsg
        color: Kirigami.Theme.negativeTextColor
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }

    Item { Layout.fillHeight: true }

    PlasmaComponents.Button {
        text: "Power settings"
        icon.name: "configure"
        Layout.fillWidth: true
        onClicked: sh.run("kcmshell6 kcm_powerdevilprofilesconfig")
    }
}
