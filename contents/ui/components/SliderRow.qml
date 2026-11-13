import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PlasmaComponents

RowLayout {
    id: sr
    property string iconName
    property real from: 0
    property real to: 100
    property real value: 0
    property real stepSize: 1
    property string unit: "%"
    property bool showMax: false
    signal moved(real v)
    signal iconClicked()

    Layout.fillWidth: true
    spacing: 10

    AppIcon {
        name: sr.iconName
        Layout.preferredWidth: 20
        Layout.preferredHeight: 20
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: sr.iconClicked()
        }
    }

    PlasmaComponents.Slider {
        id: sl
        Layout.fillWidth: true
        from: sr.from
        to: sr.to
        stepSize: sr.stepSize
        snapMode: QQC2.Slider.SnapAlways
        value: sr.value
        onMoved: sr.moved(value)
    }

    PlasmaComponents.Label {
        text: Math.round(sl.value) + (sr.showMax ? "/" + Math.round(sr.to) : sr.unit)
        Layout.preferredWidth: 48
        horizontalAlignment: Text.AlignRight
    }
}
