
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../components"

ColumnLayout {
    readonly property int pagePreferredHeight: 430
    spacing: 12

    SubHeader {
        title: "Eye protection"
        showSwitch: true
        switchChecked: root.nightOn
            onSwitchToggled: root.toggleNight()
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: eyeCol.implicitHeight + 28
        radius: 8
        color: Kirigami.Theme.alternateBackgroundColor
        border.width: 1
        border.color: root.edge

        ColumnLayout {
            id: eyeCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 10

            PlasmaComponents.Label {
                text: "Warms screen colors and reduces blue light for eye comfort, especially in the evening."
                wrapMode: Text.Wrap
                opacity: 0.85
                Layout.fillWidth: true
            }

            SliderRow {
                enabled: root.nightOn
                iconName: "eye"
                from: 2000
                to: 6500
                stepSize: 100
                unit: "K"
                value: root.nightTemp
                onMoved: v => root.setNight(true, Math.round(v / 100) * 100)
            }

            PlasmaComponents.Label {
                visible: root.nightStatus !== ""
                text: root.nightStatus
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                text: root.nightOn
                ? "Lower numbers = warmer colors and less blue light (6500K = no change)."
                : "Turn on the switch above to adjust color temperature."
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.7
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }
    }

    Item { Layout.fillHeight: true }

    PlasmaComponents.Button {
        text: "Night color settings"
        icon.name: "configure"
        Layout.fillWidth: true
        onClicked: sh.run("kcmshell6 kcm_nightlight")
    }
}
