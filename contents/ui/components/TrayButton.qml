import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

MouseArea {
    id: tb
    property string name: ""
    property string themeIcon: ""
    property string text: ""
    property string tip: ""
    property int targetPage: 0
    property real isz: 16
    property bool handleWheel: false
    property bool kbSwitch: false
    property int badge: 0

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    implicitWidth: row.implicitWidth + 10
    implicitHeight: isz + 8
    Layout.preferredWidth: implicitWidth
    Layout.fillHeight: true

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: 5
        color: Kirigami.Theme.textColor
        opacity: tb.pressed ? 0.20 : (tb.containsMouse ? 0.12 : 0)
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 3

        AppIcon {
            visible: tb.name !== ""
            name: tb.name
            Layout.preferredWidth: tb.isz
            Layout.preferredHeight: tb.isz
            Layout.alignment: Qt.AlignVCenter
        }
        Kirigami.Icon {
            visible: tb.themeIcon !== ""
            source: tb.themeIcon
            Layout.preferredWidth: tb.isz
            Layout.preferredHeight: tb.isz
            Layout.alignment: Qt.AlignVCenter
        }
        PlasmaComponents.Label {
            visible: tb.text !== ""
            text: tb.text
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Rectangle {
        visible: tb.badge > 0
        anchors.top: parent.top
        anchors.right: parent.right
        width: Math.max(12, badgeText.implicitWidth + 6)
        height: 12
        radius: 6
        color: Kirigami.Theme.highlightColor
        PlasmaComponents.Label {
            id: badgeText
            anchors.centerIn: parent
            text: tb.badge > 9 ? "9+" : tb.badge
            font.pixelSize: 9
            color: Kirigami.Theme.highlightedTextColor
        }
    }

    // تلميح كيدي بلازما الأصلي: يظهر خارج البانل تماماً ومتلاصقاً مع حافته
    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText: tb.tip
        active: tb.tip !== "" && !root.expanded
    }

    onClicked: mouse => {
        if (tb.kbSwitch) { root.nextKb(); return }
        if (mouse.button === Qt.MiddleButton) {
            if (tb.handleWheel) root.toggleMute()
                return
        }
        if (root.expanded && root.page === tb.targetPage) {
            root.expanded = false
        } else {
            root.openPage(tb.targetPage)
            root.expanded = true
        }
    }
    onWheel: wheel => {
        if (!tb.handleWheel) { wheel.accepted = false; return }
        var d = wheel.angleDelta.y > 0 ? 2 : -2
        root.setVolume(Math.max(0, Math.min(100, root.volume + d)))
    }
}
