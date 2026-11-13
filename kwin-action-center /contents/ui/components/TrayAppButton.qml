import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

MouseArea {
    id: tab
    property string key: ""
    property var item: null
    property real isz: 16

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    implicitWidth: isz + 10
    implicitHeight: isz + 8
    Layout.preferredWidth: implicitWidth
    Layout.fillHeight: true

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: 5
        color: Kirigami.Theme.textColor
        opacity: tab.pressed ? 0.20 : (tab.containsMouse ? 0.12 : 0)
        z: -1
    }

    TrayIcon {
        anchors.centerIn: parent
        width: tab.isz
        height: tab.isz
        item: tab.item
        z: -1
    }

    // تلميح كيدي الأصلي لتطبيقات النظام (يدعم العنوان والوصف)
    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText: tab.item ? (tab.item.tipTitle || tab.item.title) : ""
        subText: tab.item ? tab.item.tipText : ""
        active: mainText !== "" && !root.expanded
    }

    onClicked: mouse => {
        if (!tab.item) return
            var g = tab.mapToGlobal(0, tab.height)
            if (mouse.button === Qt.RightButton) {
                root.trayRightClick(tab.item, g.x, g.y)
            } else if (mouse.button === Qt.MiddleButton) {
                root.traySecondary(tab.item, g.x, g.y)
            } else {
                root.trayClick(tab.item, g.x, g.y)
            }
    }
}
