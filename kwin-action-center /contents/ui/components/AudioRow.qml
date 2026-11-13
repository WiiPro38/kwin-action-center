import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Rectangle {
    id: ar
    property var dev
    signal picked()

    Layout.fillWidth: true
    Layout.preferredHeight: 58
    radius: 8
    color: dev.def ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
    border.width: 1
    border.color: dev.def ? "transparent" : root.edge
    readonly property color fg: dev.def ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: ar.picked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            PlasmaComponents.Label {
                text: ar.dev.name
                color: ar.fg
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            PlasmaComponents.Label {
                text: ar.dev.detail || "Audio device"
                color: ar.fg
                opacity: 0.72
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
        AppIcon {
            visible: ar.dev.def
            name: "check"
            color: ar.fg
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
        }
    }
}
