import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../components"

ColumnLayout {
    readonly property int pagePreferredHeight: 480
    spacing: 20
    Layout.fillWidth: true
    Layout.fillHeight: true

    SubHeader { title: "Media Player" }

    // حالة عدم وجود وسائط نشطة
    ColumnLayout {
        visible: !root.mediaActive
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 90
        spacing: 14

        Kirigami.Icon {
            source: "applications-multimedia"
            Layout.preferredWidth: 72
            Layout.preferredHeight: 72
            Layout.alignment: Qt.AlignHCenter
            opacity: 0.4
        }
        PlasmaComponents.Label {
            text: "No media playing"
            opacity: 0.6
            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // واجهة التحكم بالمشغل النشط
    ColumnLayout {
        visible: root.mediaActive
        Layout.fillWidth: true
        Layout.topMargin: 5
        spacing: 24

        // اسم التطبيق مع أيقونته في الأعلى بحجم واضح
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8
            opacity: 0.85

            Kirigami.Icon {
                source: root.mediaIdentity.toLowerCase() || "applications-multimedia"
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
            }
            PlasmaComponents.Label {
                text: root.mediaIdentity.charAt(0).toUpperCase() + root.mediaIdentity.slice(1)
                font.pointSize: Kirigami.Theme.smallFont.pointSize + 1
                font.bold: true
            }
        }

        // بطاقة غلاف الألبوم أو الأيقونة بحجم أكبر وبارز (160x160)
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 160
            Layout.preferredHeight: 160
            radius: 22
            color: Kirigami.Theme.alternateBackgroundColor
            border.width: 1
            border.color: root.edge
            clip: true

            Image {
                id: artImg
                anchors.fill: parent
                source: root.mediaArtUrl !== "" ? root.mediaArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready
            }

            Kirigami.Icon {
                anchors.centerIn: parent
                width: 80
                height: 80
                source: root.mediaIdentity.toLowerCase() || "applications-multimedia"
                visible: artImg.status !== Image.Ready
                opacity: 0.8
            }
        }

        // تفاصيل الأغنية (العنوان والفنان بخط عريض وواضح)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            spacing: 8

            PlasmaComponents.Label {
                text: root.mediaTitle !== "" ? root.mediaTitle : "Unknown Track"
                font.bold: true
                font.pointSize: Kirigami.Theme.defaultFont.pointSize + 4
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
            }
            PlasmaComponents.Label {
                text: root.mediaArtist !== "" ? root.mediaArtist : "Unknown Artist"
                font.pointSize: Kirigami.Theme.smallFont.pointSize + 2
                opacity: 0.75
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        Item { Layout.preferredHeight: 10 }

        // أزرار التحكم السفلى بمقاسات كبيرة ومريحة جداً للاستخدام
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 36

            // زر السابق
            PlasmaComponents.ToolButton {
                icon.name: "media-skip-backward"
                Layout.preferredWidth: 60
                Layout.preferredHeight: 60
                icon.width: 40
                icon.height: 40
                onClicked: root.mediaCommand("previous")
            }

            // زر التشغيل والإيقاف الرئيسي (كبير وبارز 72x72)
            Rectangle {
                Layout.preferredWidth: 72
                Layout.preferredHeight: 72
                radius: 36
                color: playMouse.containsMouse ? Qt.lighter(Kirigami.Theme.highlightColor, 1.1) : Kirigami.Theme.highlightColor

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: 36
                    height: 36
                    source: root.mediaPlaying ? "media-playback-pause" : "media-playback-start"
                    color: Kirigami.Theme.highlightedTextColor
                }

                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.mediaCommand("play-pause")
                }
            }

            // زر التالي
            PlasmaComponents.ToolButton {
                icon.name: "media-skip-forward"
                Layout.preferredWidth: 60
                Layout.preferredHeight: 60
                icon.width: 40
                icon.height: 40
                onClicked: root.mediaCommand("next")
            }
        }
    }

    Item { Layout.fillHeight: true }
}
