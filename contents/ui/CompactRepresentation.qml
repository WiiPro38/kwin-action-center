import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "./components"

Item {
    id: cmp
    Component.onCompleted: root.compactItem = cmp

    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property real isz: Kirigami.Units.iconSizes.small > 0 ? Kirigami.Units.iconSizes.small : 16

    implicitWidth: vertical ? isz + 10 : mainRow.implicitWidth + 8
    implicitHeight: vertical ? mainCol.implicitHeight + 8 : isz + 10

    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    // صف أفقي آمن للشريط الأفقي (بدون تضارب في الـ Anchors)
    RowLayout {
        id: mainRow
        anchors.centerIn: parent
        visible: !cmp.vertical
        spacing: 2

        TrayButton { name: "chevron-up"; targetPage: 0; tip: "Control Center"; isz: cmp.isz }

        Repeater {
            model: root.trayInlineKeys
            TrayAppButton {
                key: modelData
                isz: cmp.isz
                property var currentItem: root.trayData[key]
                item: currentItem
            }
        }

        TrayButton { visible: root.usbDevices.length > 0; name: "usb"; targetPage: 0; tip: "USB devices"; isz: cmp.isz }
        TrayButton { visible: root.btOn; name: "bluetooth"; targetPage: 2; tip: "Bluetooth is on"; isz: cmp.isz }
        TrayButton { visible: root.airplane; name: "plane"; targetPage: 0; tip: "Airplane mode"; isz: cmp.isz }
        TrayButton { visible: root.nightOn; name: "eye"; targetPage: 4; tip: "Eye protection " + root.nightTemp + "K"; isz: cmp.isz }
        TrayButton {
            visible: root.profile !== "" && root.profile !== "balanced"
            name: root.profileIcon(root.profile)
            targetPage: 3
            tip: root.profileLabel(root.profile)
            isz: cmp.isz
        }

        TrayButton { visible: root.kbLabel !== ""; text: root.kbLabel; kbSwitch: true; tip: root.kbTip; isz: cmp.isz }

        TrayButton {
            visible: root.wifiOn || root.ethernetOn
            name: root.networkIcon
            targetPage: 1
            tip: root.wifiName !== "" ? "Connected to " + root.wifiName : (root.ethernetOn ? "Wired connection" : "Wi-Fi not connected")
            isz: cmp.isz
        }

        TrayButton {
            name: root.volumeIcon
            targetPage: 7
            handleWheel: true
            tip: root.muted ? "Volume: muted" : "Volume: " + root.volume + "%"
            isz: cmp.isz
        }

        TrayButton {
            visible: root.hasBattery
            themeIcon: root.batteryIcon
            text: cmp.vertical ? "" : root.batteryLevel + "%"
            targetPage: 3
            tip: "Battery " + root.batteryLevel + "% — " + root.statusLabel(root.batteryStatus)
            isz: cmp.isz
        }
        TrayButton {
            visible: root.mediaActive
            themeIcon: "applications-multimedia" // أيقونة أوضح للوسائط
            targetPage: 12
            tip: root.mediaTitle !== "" ? root.mediaTitle + (root.mediaArtist ? " - " + root.mediaArtist : "") : "Media player"
            isz: cmp.isz
        }
        ClockButton {
            showDate: !cmp.vertical && cmp.height >= 34
            isz: cmp.isz
        }
    }

    // عمود رأسي آمن للشريط العمودي
    ColumnLayout {
        id: mainCol
        anchors.centerIn: parent
        visible: cmp.vertical
        spacing: 2

        TrayButton { name: "chevron-up"; targetPage: 0; tip: "Control Center"; isz: cmp.isz }

        Repeater {
            model: root.trayInlineKeys
            TrayAppButton {
                key: modelData
                isz: cmp.isz
                property var currentItem: root.trayData[key]
                item: currentItem
            }
        }

        TrayButton { visible: root.usbDevices.length > 0; name: "usb"; targetPage: 0; tip: "USB devices"; isz: cmp.isz }
        TrayButton { visible: root.btOn; name: "bluetooth"; targetPage: 2; tip: "Bluetooth is on"; isz: cmp.isz }
        TrayButton { visible: root.airplane; name: "plane"; targetPage: 0; tip: "Airplane mode"; isz: cmp.isz }
        TrayButton { visible: root.nightOn; name: "eye"; targetPage: 4; tip: "Eye protection " + root.nightTemp + "K"; isz: cmp.isz }
        TrayButton {
            visible: root.profile !== "" && root.profile !== "balanced"
            name: root.profileIcon(root.profile)
            targetPage: 3
            tip: root.profileLabel(root.profile)
            isz: cmp.isz
        }

        TrayButton { visible: root.kbLabel !== ""; text: root.kbLabel; kbSwitch: true; tip: root.kbTip; isz: cmp.isz }

        TrayButton {
            visible: root.wifiOn || root.ethernetOn
            name: root.networkIcon
            targetPage: 1
            tip: root.wifiName !== "" ? "Connected to " + root.wifiName : (root.ethernetOn ? "Wired connection" : "Wi-Fi not connected")
            isz: cmp.isz
        }

        TrayButton {
            name: root.volumeIcon
            targetPage: 7
            handleWheel: true
            tip: root.muted ? "Volume: muted" : "Volume: " + root.volume + "%"
            isz: cmp.isz
        }

        TrayButton {
            visible: root.hasBattery
            themeIcon: root.batteryIcon
            text: ""
            targetPage: 3
            tip: "Battery " + root.batteryLevel + "% — " + root.statusLabel(root.batteryStatus)
            isz: cmp.isz
        }
        TrayButton {
            visible: root.mediaActive
            themeIcon: "applications-multimedia" // أيقونة أوضح للوسائط
            targetPage: 12
            tip: root.mediaTitle !== "" ? root.mediaTitle + (root.mediaArtist ? " - " + root.mediaArtist : "") : "Media player"
            isz: cmp.isz
        }

        ClockButton {
            showDate: false
            isz: cmp.isz
        }
    }
}
