import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

MouseArea {
    id: ck
    property bool showDate: true
    property real isz: 16
    hoverEnabled: true

    implicitWidth: Math.max(timeLbl.implicitWidth, dateLbl.visible ? dateLbl.implicitWidth : 0) + 14
    implicitHeight: isz + 8
    Layout.preferredWidth: implicitWidth
    Layout.fillHeight: true

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: 5
        color: Kirigami.Theme.textColor
        opacity: ck.pressed ? 0.20 : (ck.containsMouse ? 0.12 : 0)
    }

    Column {
        anchors.centerIn: parent
        spacing: 0
        PlasmaComponents.Label {
            id: timeLbl
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.clockText
            font.pointSize: Kirigami.Theme.smallFont.pointSize + (ck.showDate ? 0 : 1)
        }
        PlasmaComponents.Label {
            id: dateLbl
            visible: ck.showDate
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.dateText
            font.pointSize: Kirigami.Theme.smallFont.pointSize - 1
            opacity: 0.8
        }
    }

    // تلميح كيدي الأصلي للتاريخ خارج الشريط
    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText: root.clockNow.toLocaleDateString(root.enLoc, "dddd, MMMM d, yyyy")
        active: !root.expanded
    }

    onClicked: {
        if (root.expanded && root.page === 10) root.expanded = false
            else { root.openPage(10); root.expanded = true }
    }
}
