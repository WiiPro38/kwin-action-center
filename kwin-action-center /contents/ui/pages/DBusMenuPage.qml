
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../components"

ColumnLayout {
    readonly property int pagePreferredHeight: Math.max(170, Math.min(560, 90 + root.menuNodes.length * 38))
    spacing: 6

    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        PlasmaComponents.ToolButton {
            icon.name: "go-previous-symbolic"
            onClicked: root.menuBack()
        }
        TrayIcon {
            item: root.menuItem
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
        }
        PlasmaComponents.Label {
            text: root.menuTitle
            font.bold: true
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
        PlasmaComponents.BusyIndicator {
            visible: root.menuLoading
            running: visible
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
        }
    }

    PlasmaComponents.Label {
        visible: root.menuError !== ""
        text: root.menuError
        color: Kirigami.Theme.negativeTextColor
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }

    ListView {
        id: menuList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 2
        model: root.menuNodes

        delegate: Item {
            id: mRow
            readonly property bool sep: modelData.type === "separator"
            width: ListView.view.width
            height: sep ? 9 : 38

            Rectangle {
                visible: mRow.sep
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                height: 1
                color: root.edge
            }

            Rectangle {
                visible: !mRow.sep
                anchors.fill: parent
                radius: 6
                color: Kirigami.Theme.textColor
                opacity: (mArea.containsMouse && modelData.enabled) ? 0.12 : 0
            }

            MouseArea {
                id: mArea
                visible: !mRow.sep
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.menuClick(modelData)
            }

            RowLayout {
                visible: !mRow.sep
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8
                opacity: modelData.enabled ? 1 : 0.45

                Item {
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                    AppIcon {
                        anchors.fill: parent
                        visible: modelData.toggle !== "" && modelData.checked
                        name: "check"
                    }
                    Kirigami.Icon {
                        anchors.fill: parent
                        visible: modelData.toggle === "" && modelData.icon !== ""
                        source: modelData.icon
                    }
                }
                PlasmaComponents.Label {
                    text: modelData.label
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                AppIcon {
                    visible: modelData.hasSub
                    name: "chevron-right"
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                }
            }
        }
    }
}
