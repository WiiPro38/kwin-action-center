import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Rectangle {
    id: st
    property string iconName
    property string title
    property string subtitle
    property bool active: false
    property bool hasDetails: true
    signal toggled()
    signal detailsClicked()

    Layout.fillWidth: true
    Layout.preferredHeight: 68
    radius: 8
    color: active ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
    border.width: 1
    border.color: active ? "transparent" : root.edge

    readonly property color fg: active ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: st.hasDetails ? divider.left : parent.right
        anchors.margins: 3
        radius: 6
        color: st.fg
        opacity: leftArea.pressed ? 0.22 : (leftArea.containsMouse ? 0.12 : 0)
    }

    Rectangle {
        id: divider
        visible: st.hasDetails
        width: 1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: 14
        anchors.bottomMargin: 14
        anchors.rightMargin: 40
        color: st.fg
        opacity: 0.35
    }

    Rectangle {
        visible: st.hasDetails
        anchors.left: divider.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 3
        radius: 6
        color: st.fg
        opacity: rightArea.pressed ? 0.22 : (rightArea.containsMouse ? 0.12 : 0)
    }

    MouseArea {
        id: leftArea
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: st.hasDetails ? divider.left : parent.right
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: st.toggled()
    }
    MouseArea {
        id: rightArea
        visible: st.hasDetails
        anchors.left: divider.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: st.detailsClicked()
    }

    RowLayout {
        anchors.left: parent.left
        anchors.right: st.hasDetails ? divider.left : parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        anchors.rightMargin: 8
        spacing: 10

        AppIcon {
            name: st.iconName
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            color: st.fg
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            PlasmaComponents.Label {
                text: st.title
                font.bold: true
                color: st.fg
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            PlasmaComponents.Label {
                text: st.subtitle
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                color: st.fg
                opacity: 0.8
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    AppIcon {
        visible: st.hasDetails
        name: "chevron-right"
        anchors.left: divider.right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 16
        color: st.fg
    }
}
