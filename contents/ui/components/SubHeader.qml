import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

RowLayout {
    id: hd
    property string title
    property bool showSwitch: false
    property bool switchChecked: false
    property bool showRefresh: false
    property bool busy: false
    signal switchToggled()
    signal refreshClicked()

    Layout.fillWidth: true
    spacing: 6

    PlasmaComponents.ToolButton {
        icon.name: "go-previous-symbolic"
        onClicked: root.page = 0
    }
    PlasmaComponents.Label {
        text: hd.title
        font.bold: true
        font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1
        Layout.fillWidth: true
    }
    PlasmaComponents.BusyIndicator {
        visible: hd.busy
        running: visible
        Layout.preferredWidth: 22
        Layout.preferredHeight: 22
    }
    PlasmaComponents.ToolButton {
        visible: hd.showRefresh
        icon.name: "view-refresh-symbolic"
        enabled: !hd.busy
        onClicked: hd.refreshClicked()
    }
    PlasmaComponents.Switch {
        visible: hd.showSwitch
        checked: hd.switchChecked
        onToggled: hd.switchToggled()
    }
}
