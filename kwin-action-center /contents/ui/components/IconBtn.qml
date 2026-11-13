import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

MouseArea {
    id: ib
    property string name: ""
    property color color: Kirigami.Theme.textColor
    property string tip: ""
    implicitWidth: 28
    implicitHeight: 28
    Layout.preferredWidth: 28
    Layout.preferredHeight: 28
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: Kirigami.Theme.textColor
        opacity: ib.pressed ? 0.2 : (ib.containsMouse ? 0.1 : 0)
    }

    AppIcon {
        anchors.centerIn: parent
        width: 16
        height: 16
        name: ib.name
        color: ib.color
    }

    QQC2.ToolTip.delay: 500
    QQC2.ToolTip.text: ib.tip
    QQC2.ToolTip.visible: ib.containsMouse && ib.tip !== ""
}
