import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../components"

ColumnLayout {
    readonly property int pagePreferredHeight: 540
    spacing: 10

    SubHeader { title: "About" }

    PlasmaComponents.ScrollView {
        id: sv
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: availableWidth

        ColumnLayout {
            width: sv.availableWidth
            spacing: 12

            // ---------- About ----------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: aboutCol.implicitHeight + 24
                radius: 8
                color: Kirigami.Theme.alternateBackgroundColor
                border.width: 1
                border.color: root.edge

                ColumnLayout {
                    id: aboutCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    PlasmaComponents.Label {
                        text: "Quick settings panel for KDE Plasma 6"
                        font.bold: true
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        text: "Version 1.0\nAuthor: NOVAFroge (WiiPro38)\nContact: ziramlabcore@gmail.com"
                        opacity: 0.85
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }

            // ---------- License ----------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: licCol.implicitHeight + 24
                radius: 8
                color: Kirigami.Theme.alternateBackgroundColor
                border.width: 1
                border.color: root.edge

                ColumnLayout {
                    id: licCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    PlasmaComponents.Label {
                        text: "License"
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        text: "Copyright (c) 2026 NOVAFroge (WiiPro38). All Rights Reserved.\nNon-Commercial License."
                        opacity: 0.85
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        text: "1. Permitted use: you may download, install and use this software and its source code strictly for personal, non-commercial and educational purposes."
                        opacity: 0.85
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        text: "2. Restrictions: commercial use, redistribution, modification for commercial purposes, reselling, or incorporating this software (in whole or in part) into any paid or commercial product or service is strictly prohibited without prior written permission from the author (NOVAFroge)."
                        opacity: 0.85
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        text: "3. Ownership: the source code and all related assets remain the exclusive intellectual property of NOVAFroge (WiiPro38). Unauthorized copying, claiming authorship, or distributing modified versions under a different name is prohibited."
                        opacity: 0.85
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }

            // ---------- Privacy ----------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: prvCol.implicitHeight + 24
                radius: 8
                color: Kirigami.Theme.alternateBackgroundColor
                border.width: 1
                border.color: root.edge

                ColumnLayout {
                    id: prvCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    PlasmaComponents.Label {
                        text: "Privacy Policy"
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        text: "This widget works entirely on your computer. It does not collect, store or send personal data to the author or to any third party, and it contains no analytics, telemetry or advertising."
                        opacity: 0.85
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        text: "What it reads: to show its controls it reads the state of your system, such as battery and power profile, screen brightness, volume and audio devices, Wi-Fi and Bluetooth status and device names, connected USB drives, KDE Connect devices, system tray items, Night Light and Do Not Disturb status, and keyboard layout. This information is obtained from local system services and is only shown on your screen."
                        opacity: 0.85
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        text: "What it changes: it changes a system setting only when you use the matching control (for example Do Not Disturb, Night Light, brightness, volume, Wi-Fi, Bluetooth, power profile, or mounting a USB drive)."
                        opacity: 0.85
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        text: "What it stores: only its own preferences in Plasma's configuration (which tray items are hidden, how many tray icons are shown inline, and the 12/24-hour clock choice), plus temporary files such as tray icon copies in your session's runtime folder."
                        opacity: 0.85
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        text: "Network: the widget itself makes no network connections. Features such as Wi-Fi, Bluetooth and KDE Connect are carried out by the corresponding system services, which follow their own policies."
                        opacity: 0.85
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Label {
                        text: "Questions or requests: ziramlabcore@gmail.com. Last updated: November 13, 2026."
                        opacity: 0.85
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }

            Item { Layout.preferredHeight: 4 }
        }
    }
}
