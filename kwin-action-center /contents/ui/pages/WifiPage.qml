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
        title: "Wireless networks"
        showSwitch: true
        switchChecked: root.wifiOn
            showRefresh: root.wifiOn
            busy: root.wifiBusy
            onSwitchToggled: root.toggleWifi()
            onRefreshClicked: root.rescanWifi()
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: hotspotCol.implicitHeight + 20
        radius: 8
        color: Kirigami.Theme.alternateBackgroundColor
        border.width: 1
        border.color: root.edge

        ColumnLayout {
            id: hotspotCol
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6
            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Label {
                    text: "Mobile hotspot"
                    font.bold: true
                    Layout.fillWidth: true
                }
                PlasmaComponents.BusyIndicator {
                    visible: root.hotspotBusy
                    running: visible
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                }
                PlasmaComponents.Switch {
                    checked: root.hotspotOn
                    enabled: !root.hotspotBusy
                    onToggled: root.toggleHotspot()
                }
            }
            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: root.hotspotOn ? ("Network: " + (root.hotspotName || "ZIRAM-Hotspot")) : "Share this computer's connection over Wi-Fi"
                opacity: 0.75
                wrapMode: Text.Wrap
            }
            PlasmaComponents.Label {
                visible: root.hotspotOn && root.hotspotPassword !== ""
                Layout.fillWidth: true
                text: "Password: " + root.hotspotPassword
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                wrapMode: Text.Wrap
            }
            PlasmaComponents.Label {
                visible: root.hotspotMessage !== ""
                Layout.fillWidth: true
                text: root.hotspotMessage
                color: Kirigami.Theme.negativeTextColor
                wrapMode: Text.Wrap
            }
        }
    }

    Rectangle {
        visible: root.ethernetDevices.length > 0
        Layout.fillWidth: true
        Layout.preferredHeight: ethernetCol.implicitHeight + 20
        radius: 8
        color: Kirigami.Theme.alternateBackgroundColor
        border.width: 1
        border.color: root.edge
        ColumnLayout {
            id: ethernetCol
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8
            RowLayout {
                Layout.fillWidth: true
                AppIcon { name: "ethernet"; Layout.preferredWidth: 20; Layout.preferredHeight: 20 }
                PlasmaComponents.Label { text: "Wired connections"; font.bold: true; Layout.fillWidth: true }
                PlasmaComponents.Label { text: "Connected"; opacity: 0.7 }
            }
            Repeater {
                model: root.ethernetDevices
                ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 2
                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        text: modelData.device + " · " + modelData.connection
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        text: "IP: " + (modelData.ip || "Not assigned") + (modelData.speed ? "   ·   " + modelData.speed : "")
                        opacity: 0.75
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        wrapMode: Text.Wrap
                    }
                    PlasmaComponents.Label {
                        visible: modelData.gateway !== "" || modelData.mac !== ""
                        Layout.fillWidth: true
                        text: (modelData.gateway ? "Gateway: " + modelData.gateway : "") + (modelData.mac ? "   ·   MAC: " + modelData.mac : "")
                        opacity: 0.65
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        wrapMode: Text.Wrap
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        PlasmaComponents.Label {
                            Layout.fillWidth: true
                            text: modelData.state || "Connected"
                            opacity: 0.65
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                        }
                        PlasmaComponents.Button {
                            text: root.ethernetBusyDevice === modelData.device ? "Disconnecting…" : "Disconnect"
                            enabled: root.ethernetBusyDevice === ""
                            onClicked: root.disconnectEthernet(modelData.device)
                        }
                    }
                }
            }
        }
    }

    PlasmaComponents.Label {
        visible: root.ethernetMessage !== ""
        text: root.ethernetMessage
        color: Kirigami.Theme.negativeTextColor
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }

    RowLayout {
        Layout.fillWidth: true
        PlasmaComponents.Label {
            Layout.fillWidth: true
            text: "Manage saved networks, IP, DNS and proxy settings"
            opacity: 0.7
            wrapMode: Text.Wrap
            font.pointSize: Kirigami.Theme.smallFont.pointSize
        }
        PlasmaComponents.Button {
            text: "More settings"
            onClicked: root.openNetworkSettings()
        }
    }

    PlasmaComponents.Label {
        visible: root.wifiMessage !== ""
        text: root.wifiMessage
        color: Kirigami.Theme.negativeTextColor
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }

    PlasmaComponents.Label {
        visible: !root.wifiOn
        text: "Wi-Fi is off. Turn it on to see networks."
        opacity: 0.7
        wrapMode: Text.Wrap
        Layout.fillWidth: true
        Layout.topMargin: 20
        horizontalAlignment: Text.AlignHCenter
    }

    // ScrollView آمن ومنعزل تماماً بدون حلقة ربط
    PlasmaComponents.ScrollView {
        id: wifiListScroll
        visible: root.wifiOn
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: availableWidth
        clip: true

        ListView {
            id: wifiList
            anchors.fill: parent
            spacing: 6
            model: root.wifiNetworks

            PlasmaComponents.Label {
                anchors.centerIn: parent
                visible: wifiList.count === 0
                text: "No networks found. Press refresh."
                opacity: 0.6
            }

            delegate: Rectangle {
                id: wRow
                required property var modelData
                readonly property bool inUse: modelData.inUse
                readonly property color fg: inUse ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor

                width: ListView.view.width
                height: wcol.implicitHeight + 20
                radius: 8
                color: inUse ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
                border.width: 1
                border.color: inUse ? "transparent" : root.edge

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (wRow.modelData.inUse) return
                            root.wifiMessage = ""
                            if (wRow.modelData.known || !wRow.modelData.secure) {
                                root.selectedSsid = ""
                                root.connectWifi(wRow.modelData, "")
                            } else {
                                root.selectedSsid = (root.selectedSsid === wRow.modelData.ssid) ? "" : wRow.modelData.ssid
                            }
                    }
                }

                ColumnLayout {
                    id: wcol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Item {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 16
                            Repeater {
                                model: 4
                                Rectangle {
                                    required property int index
                                    width: 3
                                    height: 4 + index * 4
                                    x: index * 5
                                    anchors.bottom: parent.bottom
                                    radius: 1
                                    color: wRow.fg
                                    opacity: wRow.modelData.signal >= (index + 1) * 25 - 12 ? 1 : 0.3
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            PlasmaComponents.Label {
                                text: wRow.modelData.ssid
                                font.bold: wRow.inUse
                                color: wRow.fg
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            PlasmaComponents.Label {
                                visible: text !== ""
                                text: wRow.inUse ? "Connected" : (wRow.modelData.known ? "Saved" : "")
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                                color: wRow.fg
                                opacity: 0.8
                            }
                        }

                        AppIcon {
                            visible: wRow.modelData.secure
                            name: "lock"
                            Layout.preferredWidth: 14
                            Layout.preferredHeight: 14
                            color: wRow.fg
                        }

                        PlasmaComponents.Button {
                            visible: wRow.inUse
                            text: "Disconnect"
                            onClicked: root.disconnectWifi(wRow.modelData.ssid)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        visible: root.selectedSsid === wRow.modelData.ssid
                        spacing: 6

                        PlasmaComponents.TextField {
                            id: pwField
                            Layout.fillWidth: true
                            placeholderText: "Password"
                            echoMode: TextInput.Password
                            onAccepted: if (text.length > 0) root.connectWifi(wRow.modelData, text)
                            onVisibleChanged: if (visible) { text = ""; forceActiveFocus() }
                        }
                        PlasmaComponents.Button {
                            text: "Connect"
                            enabled: pwField.text.length > 0 && !root.wifiBusy
                            onClicked: root.connectWifi(wRow.modelData, pwField.text)
                        }
                    }
                }
            }
        }
    }

    Item { Layout.fillHeight: true }
}
