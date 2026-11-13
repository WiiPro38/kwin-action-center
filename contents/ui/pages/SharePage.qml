
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../components"

ColumnLayout {
    readonly property int pagePreferredHeight: 500
    spacing: 10

    SubHeader {
        title: "Nearby Share"
        showRefresh: true
        onRefreshClicked: root.refreshShare()
    }

    PlasmaComponents.Label {
        visible: root.kdeDevices.length === 0
        text: "No devices available via KDE Connect.\nInstall KDE Connect on your phone and pair it with this device."
        opacity: 0.7
        wrapMode: Text.Wrap
        Layout.fillWidth: true
        Layout.topMargin: 20
        horizontalAlignment: Text.AlignHCenter
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 6
        model: root.kdeDevices

        delegate: Rectangle {
            id: dRow
            required property var modelData
            width: ListView.view.width
            height: 60
            radius: 8
            color: Kirigami.Theme.alternateBackgroundColor
            border.width: 1
            border.color: root.edge

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 10

                AppIcon {
                    name: "phone"
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                }
                PlasmaComponents.Label {
                    text: dRow.modelData.name
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                PlasmaComponents.Button {
                    text: "Send file"
                    icon.name: "document-send"
                    onClicked: root.shareFile(dRow.modelData.id)
                }
            }
        }
    }

    PlasmaComponents.Button {
        text: "Open KDE Connect"
        icon.name: "kdeconnect"
        Layout.fillWidth: true
        onClicked: sh.run("kdeconnect-app")
    }
}
