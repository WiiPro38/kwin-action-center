
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../components"

ColumnLayout {
    readonly property int pagePreferredHeight: 300
    spacing: 10

    SubHeader { title: "More icons" }

    Flow {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        Layout.maximumWidth: 352
        spacing: 8

        Repeater {
            model: root.trayOverflowKeys

            Rectangle {
                id: oCell
                readonly property var item: root.trayData[modelData]
                visible: !!oCell.item
                width: 80
                height: 78
                radius: 8
                color: Kirigami.Theme.alternateBackgroundColor
                border.width: 1
                border.color: root.edge

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 6
                    color: Kirigami.Theme.textColor
                    opacity: oArea.containsMouse ? 0.10 : 0
                }

                MouseArea {
                    id: oArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (!oCell.item) return
                            var g = oCell.mapToGlobal(0, oCell.height)
                            if (mouse.button === Qt.RightButton) {
                                root.trayRightClick(oCell.item, g.x, g.y)
                            } else if (mouse.button === Qt.MiddleButton) {
                                root.traySecondary(oCell.item, g.x, g.y)
                            } else {
                                root.trayClick(oCell.item, g.x, g.y)
                                if (!oCell.item.isMenu) root.expanded = false
                            }
                    }
                    QQC2.ToolTip.delay: 500
                    QQC2.ToolTip.text: oCell.item ? (oCell.item.tipTitle || oCell.item.title) + (oCell.item.tipText ? "\n" + oCell.item.tipText : "") : ""
                    QQC2.ToolTip.visible: containsMouse && QQC2.ToolTip.text !== ""
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    width: parent.width - 10
                    spacing: 6
                    TrayIcon {
                        item: oCell.item
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignHCenter
                    }
                    PlasmaComponents.Label {
                        text: oCell.item ? oCell.item.title : ""
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    PlasmaComponents.Label {
        visible: root.trayOverflowKeys.length === 0
        text: "No more icons."
        opacity: 0.6
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 16
    }

    Item { Layout.fillHeight: true }
}
