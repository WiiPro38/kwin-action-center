
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../components"

PlasmaComponents.ScrollView {
    id: audioScroll
    readonly property int pagePreferredHeight: 560
    contentWidth: availableWidth
    clip: true

    ColumnLayout {
        id: soundCol
        width: audioScroll.availableWidth
        spacing: 10

    SubHeader { title: "Volume" }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 52
        radius: 8
        color: Kirigami.Theme.alternateBackgroundColor
        border.width: 1
        border.color: root.edge

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            SliderRow {
                iconName: root.volumeIcon
                from: 0
                to: 100
                stepSize: 1
                value: root.muted ? 0 : root.volume
                onIconClicked: root.toggleMute()
                onMoved: v => root.setVolume(Math.round(v))
            }
        }
    }

    PlasmaComponents.Label {
        visible: root.sinks.length > 0
        text: "Output devices"
        font.bold: true
    }
    PlasmaComponents.Label {
        visible: root.wirelessSinks.length > 0
        text: "Wireless outputs · Bluetooth"
        opacity: 0.72
        font.pointSize: Kirigami.Theme.smallFont.pointSize
    }
    Repeater {
        model: root.wirelessSinks
        AudioRow {
            dev: modelData
            onPicked: root.setDefaultAudio(modelData.nodeName, false)
        }
    }
    PlasmaComponents.Label {
        visible: root.wiredSinks.length > 0
        text: "Wired outputs"
        opacity: 0.72
        font.pointSize: Kirigami.Theme.smallFont.pointSize
    }
    Repeater {
        model: root.wiredSinks
        AudioRow {
            dev: modelData
            onPicked: root.setDefaultAudio(modelData.nodeName, false)
        }
    }

    PlasmaComponents.Label {
        visible: root.sources.length > 0
        text: "Input devices"
        font.bold: true
    }
    PlasmaComponents.Label {
        visible: root.wirelessSources.length > 0
        text: "Wireless inputs · Bluetooth"
        opacity: 0.72
        font.pointSize: Kirigami.Theme.smallFont.pointSize
    }
    Repeater {
        model: root.wirelessSources
        AudioRow {
            dev: modelData
            onPicked: root.setDefaultAudio(modelData.nodeName, true)
        }
    }
    PlasmaComponents.Label {
        visible: root.wiredSources.length > 0
        text: "Wired inputs"
        opacity: 0.72
        font.pointSize: Kirigami.Theme.smallFont.pointSize
    }
    Repeater {
        model: root.wiredSources
        AudioRow {
            dev: modelData
            onPicked: root.setDefaultAudio(modelData.nodeName, true)
        }
    }

    PlasmaComponents.Button {
        text: "Sound settings"
        icon.name: "configure"
        Layout.fillWidth: true
        onClicked: { root.expanded = false; sh.run("kcmshell6 kcm_pulseaudio") }
    }
}
}
