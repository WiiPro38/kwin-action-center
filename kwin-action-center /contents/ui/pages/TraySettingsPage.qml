
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../components"

ColumnLayout {
    readonly property int pagePreferredHeight: 570
    spacing: 10

    SubHeader {
        title: "Tray apps"
        showRefresh: true
        onRefreshClicked: root.refreshTray()
    }

    PlasmaComponents.Label {
        text: "App icons appear in the tray and update live. Turn the switch off to hide an app icon. Extra icons go to the \"…\" menu."
        font.pointSize: Kirigami.Theme.smallFont.pointSize
        opacity: 0.75
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        PlasmaComponents.Label {
            text: "Icons in the tray"
            Layout.fillWidth: true
        }
        PlasmaComponents.SpinBox {
            from: 1
            to: 12
            value: root.maxInline
            onValueModified: root.setMaxInline(value)
        }
    }

    PlasmaComponents.Label {
        visible: root.trayMsg !== ""
        text: root.trayMsg
        color: Kirigami.Theme.negativeTextColor
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }

    ListView {
        id: trayList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 6
        model: root.trayKeys

        PlasmaComponents.Label {
            anchors.centerIn: parent
            visible: trayList.count === 0
            text: "No apps with tray icons."
            opacity: 0.6
        }

        delegate: Rectangle {
            id: tRow
            readonly property var item: root.trayData[modelData]
            readonly property bool hidden: tRow.item ? root.trayIsHidden(tRow.item.id) : false

            visible: !!tRow.item
            width: ListView.view.width
            height: tRow.item ? tCol.implicitHeight + 20 : 0
            radius: 8
            color: Kirigami.Theme.alternateBackgroundColor
            border.width: 1
            border.color: root.edge

            ColumnLayout {
                id: tCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    TrayIcon {
                        item: tRow.item
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        PlasmaComponents.Label {
                            text: tRow.item ? tRow.item.title : ""
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        PlasmaComponents.Label {
                            text: tRow.hidden ? "Hidden from tray"
                            : (tRow.item && tRow.item.status === "Passive" ? "Idle (auto-hidden)" : "Shown in tray")
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            opacity: 0.7
                        }
                    }
                    PlasmaComponents.Switch {
                        checked: !tRow.hidden
                        onToggled: root.setTrayHidden(tRow.item.id, !checked)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    PlasmaComponents.Button {
                        text: "Open"
                        Layout.fillWidth: true
                        onClicked: {
                            var g = tRow.mapToGlobal(0, 0)
                            root.trayClick(tRow.item, g.x, g.y)
                        }
                    }
                    PlasmaComponents.Button {
                        text: "Menu"
                        Layout.fillWidth: true
                        onClicked: {
                            var g = tRow.mapToGlobal(0, 0)
                            root.trayRightClick(tRow.item, g.x, g.y)
                        }
                    }
                }
            }
        }
    }
}
