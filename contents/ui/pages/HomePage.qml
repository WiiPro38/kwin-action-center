import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../components"

Item {
    id: homeRoot
    // Keep the home page compact until the user expands the full action list.
    property bool actionsExpanded: false
    readonly property int pagePreferredHeight: Math.max(420, Math.min(Screen.desktopAvailableHeight - 20, mainCol.implicitHeight + 28))

    ColumnLayout {
        id: mainCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 12

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 8
            columnSpacing: 8

            SplitTile {
                iconName: root.wifiOn ? "wifi" : "wifi-off"
                title: "Wi-Fi"
                subtitle: root.wifiOn ? (root.wifiName || "Not connected") : "Off"
                active: root.wifiOn
                onToggled: root.toggleWifi()
                onDetailsClicked: root.openPage(1)
            }
            SplitTile {
                iconName: root.hotspotOn ? "hotspot-on" : "hotspot-off"
                title: "Mobile hotspot"
                subtitle: root.hotspotBusy ? "Changing state…" : (root.hotspotOn ? "On · " + (root.hotspotName || "ZIRAM-Hotspot") : "Off")
                active: root.hotspotOn
                onToggled: root.toggleHotspot()
                onDetailsClicked: root.openPage(1)
            }
            SplitTile {
                iconName: root.btOn ? "bluetooth" : "bluetooth-off"
                title: "Bluetooth"
                subtitle: root.btOn ? "On" : "Off"
                active: root.btOn
                onToggled: root.toggleBt()
                onDetailsClicked: root.openPage(2)
            }
            SplitTile {
                iconName: "plane"
                title: "Airplane mode"
                subtitle: root.airplane ? "On" : "Off"
                active: root.airplane
                hasDetails: false
                onToggled: root.toggleAirplane()
            }
            SplitTile {
                iconName: root.dnd ? "bell-off" : "bell"
                title: "Do Not Disturb"
                subtitle: root.dnd ? "On" : "Off"
                active: root.dnd
                hasDetails: false
                onToggled: root.toggleDnd()
            }
            SplitTile {
                iconName: root.profileIcon(root.profile)
                title: "Performance mode"
                subtitle: root.profileMsg !== "" ? "Change failed" : (root.profiles.length > 0 ? root.profileLabel(root.profile) : "Unavailable")
                active: root.profile !== "balanced" && root.profile !== ""
                onToggled: root.cycleProfile()
                onDetailsClicked: root.openPage(3)
            }
            SplitTile {
                visible: homeRoot.actionsExpanded
                iconName: "eye"
                title: "Eye protection"
                subtitle: root.nightOn ? ("On · " + root.nightTemp + "K") : "Off"
                active: root.nightOn
                onToggled: root.toggleNight()
                onDetailsClicked: root.openPage(4)
            }
            SplitTile {
                visible: homeRoot.actionsExpanded
                iconName: "share"
                title: "Share"
                subtitle: root.kdeDevices.length > 0 ? (root.kdeDevices.length + " device(s) available") : "KDE Connect"
                hasDetails: false
                onToggled: root.openPage(5)
            }
            SplitTile {
                visible: homeRoot.actionsExpanded
                iconName: "project"
                title: "Cast"
                subtitle: "Show on a display"
                hasDetails: false
                onToggled: root.openProjector()
            }
            SplitTile {
                visible: homeRoot.actionsExpanded
                iconName: "apps"
                title: "Tray apps"
                subtitle: "Show, hide and control"
                hasDetails: false
                onToggled: root.openPage(6)
            }
            SplitTile {
                visible: homeRoot.actionsExpanded
                iconName: "sliders"
                title: "Settings"
                subtitle: "System settings"
                hasDetails: false
                onToggled: { root.expanded = false; sh.run("systemsettings") }
            }
            SplitTile {
                visible: homeRoot.actionsExpanded
                iconName: "star"
                title: "About"
                subtitle: "License & privacy"
                hasDetails: false
                onToggled: root.openPage(11)
            }
        }

        // Dedicated circular expand/collapse button using the plasmoid's own icon assets.
        Rectangle {
            id: actionsExpandButton
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 42
            Layout.preferredHeight: 42
            radius: width / 2
            color: expandMouse.containsMouse
            ? Kirigami.Theme.highlightColor
            : Kirigami.Theme.alternateBackgroundColor
            border.width: 2
            border.color: Kirigami.Theme.highlightColor
            Accessible.name: homeRoot.actionsExpanded ? "Show fewer actions" : "Show more actions"
            Accessible.description: "Expand or collapse the action list"

            AppIcon {
                anchors.centerIn: parent
                width: 24
                height: 24
                name: homeRoot.actionsExpanded ? "collapse" : "expand"
            }

            MouseArea {
                id: expandMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: homeRoot.actionsExpanded = !homeRoot.actionsExpanded
            }
        }

        // بطاقة السطوع والصوت
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: sCol.implicitHeight + 24
            radius: 8
            color: Kirigami.Theme.alternateBackgroundColor
            border.width: 1
            border.color: root.edge

            ColumnLayout {
                id: sCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 12
                spacing: 6

                SliderRow {
                    visible: root.brightnessMax > 0
                    iconName: "sun"
                    from: 1
                    to: 100
                    stepSize: 1
                    value: root.brightnessPct
                    onMoved: v => root.setBrightnessPct(Math.round(v))
                }
                SliderRow {
                    visible: root.kbdMax > 0
                    iconName: "keyboard"
                    from: 0
                    to: Math.max(1, root.kbdMax)
                    stepSize: 1
                    showMax: true
                    value: root.kbdBrightness
                    onMoved: v => root.setKbd(Math.round(v))
                }
                SliderRow {
                    iconName: root.volumeIcon
                    from: 0
                    to: 100
                    stepSize: 1
                    value: root.muted ? 0 : root.volume
                    onIconClicked: root.toggleMute()
                    onMoved: v => root.setVolume(Math.round(v))
                }
            }
        }

        // بطاقة أجهزة USB المتصلة
        Rectangle {
            visible: root.usbDevices.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: usbCol.implicitHeight + 24
            radius: 8
            color: Kirigami.Theme.alternateBackgroundColor
            border.width: 1
            border.color: root.edge

            ColumnLayout {
                id: usbCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    AppIcon { name: "usb"; Layout.preferredWidth: 20; Layout.preferredHeight: 20 }
                    PlasmaComponents.Label { text: "USB devices"; font.bold: true; Layout.fillWidth: true }
                }

                PlasmaComponents.Label {
                    visible: root.usbMsg !== ""
                    text: root.usbMsg
                    color: Kirigami.Theme.negativeTextColor
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                Repeater {
                    model: root.usbDevices
                    RowLayout {
                        id: uRow
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 8

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            PlasmaComponents.Label { text: uRow.modelData.name; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                            PlasmaComponents.Label {
                                text: uRow.modelData.size + (uRow.modelData.mount ? "  ·  Mounted" : "  ·  Not mounted")
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                                opacity: 0.7
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                        PlasmaComponents.Button { text: "Open"; onClicked: root.usbOpen(uRow.modelData) }
                        PlasmaComponents.Button { text: "Eject"; onClicked: root.usbEject(uRow.modelData) }
                    }
                }
            }
        }

        // شريط البطارية السفلي
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: 8
            color: Kirigami.Theme.alternateBackgroundColor
            border.width: 1
            border.color: root.edge

            MouseArea {
                anchors.fill: parent
                anchors.rightMargin: 48
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openPage(3)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 4
                spacing: 10

                Kirigami.Icon {
                    visible: root.hasBattery
                    source: root.batteryIcon
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                }
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: root.hasBattery ? root.batteryLevel + "% — " + root.statusLabel(root.batteryStatus) : "No battery"
                }
                PlasmaComponents.ToolButton {
                    icon.name: "configure"
                    onClicked: sh.run("kcmshell6 kcm_powerdevilprofilesconfig")
                }
            }
        }
    }
}
