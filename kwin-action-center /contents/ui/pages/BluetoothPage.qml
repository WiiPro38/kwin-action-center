import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../components"

ColumnLayout {
    readonly property int pagePreferredHeight: 480
    spacing: 10
    Layout.fillWidth: true
    Layout.fillHeight: true

    SubHeader {
        title: "Bluetooth"
        showSwitch: true
        switchChecked: root.btOn
            showRefresh: root.btOn
            busy: root.btScanning
            onSwitchToggled: root.toggleBt()
            onRefreshClicked: root.scanBt()
    }

    PlasmaComponents.Label {
        visible: !root.btOn
        text: "Bluetooth is off. Turn it on to see devices."
        opacity: 0.7
        wrapMode: Text.Wrap
        Layout.fillWidth: true
        Layout.topMargin: 20
        horizontalAlignment: Text.AlignHCenter
    }

    // ScrollView آمن ومنعزل تماماً بدون حلقة ربط
    PlasmaComponents.ScrollView {
        id: btListScroll
        visible: root.btOn
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: availableWidth
        clip: true

        ListView {
            id: btList
            anchors.fill: parent
            spacing: 6
            model: root.btDevices

            PlasmaComponents.Label {
                anchors.centerIn: parent
                visible: btList.count === 0
                text: "No devices found. Press refresh to scan."
                opacity: 0.6
            }

            delegate: Rectangle {
                id: bRow
                required property var modelData
                readonly property bool conn: modelData.connected
                readonly property color fg: conn ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor

                width: ListView.view.width
                height: 56
                radius: 8
                color: conn ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
                border.width: 1
                border.color: conn ? "transparent" : root.edge

                MouseArea {
                    anchors.fill: parent
                    enabled: root.btBusy === ""
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.btAction(bRow.modelData)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    AppIcon {
                        name: "bluetooth"
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        color: bRow.fg
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        PlasmaComponents.Label {
                            text: bRow.modelData.name
                            font.bold: bRow.conn
                            color: bRow.fg
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        PlasmaComponents.Label {
                            text: bRow.conn ? "Connected" : (bRow.modelData.paired ? "Paired" : "Click to pair")
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            color: bRow.fg
                            opacity: 0.8
                        }
                    }
                    PlasmaComponents.BusyIndicator {
                        visible: root.btBusy === bRow.modelData.mac
                        running: visible
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                    }
                }
            }
        }
    }

    Item { Layout.fillHeight: true }
}
