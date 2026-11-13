import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../components"

ColumnLayout {
    readonly property int pagePreferredHeight: 480
    spacing: 12
    Layout.fillWidth: true
    Layout.fillHeight: true

    SubHeader { title: "Date & time" }

    // قسم الساعة والتاريخ
    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 4
        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            text: root.clockSecondsText
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 2.2
            font.bold: true
        }
        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            text: root.clockNow.toLocaleDateString(root.enLoc, "dddd, MMMM d, yyyy")
            opacity: 0.75
        }

        // مفتاح التبديل لنظام AM / PM
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 4
            spacing: 8
            PlasmaComponents.Label {
                text: "12-hour format (AM/PM)"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.8
            }
            PlasmaComponents.Switch {
                checked: root.use12h
                onToggled: root.set12h(checked)
            }
        }
    }

    // فاصل خفيف لتنظيم الحواف
    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: root.edge
        opacity: 0.5
    }

    // شريط التنقل بين الأشهر
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        Layout.rightMargin: 4
        PlasmaComponents.ToolButton { icon.name: "go-previous-symbolic"; onClicked: root.calShift(-1) }
        PlasmaComponents.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.enLoc.monthName(root.calMonth) + " " + root.calYear
            font.bold: true
        }
        PlasmaComponents.ToolButton { text: "Today"; onClicked: root.calToday() }
        PlasmaComponents.ToolButton { icon.name: "go-next-symbolic"; onClicked: root.calShift(1) }
    }

    // شبكة أيام التقويم
    GridLayout {
        Layout.fillWidth: true
        columns: 7
        rowSpacing: 4
        columnSpacing: 4

        Repeater {
            model: 7
            PlasmaComponents.Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: root.enLoc.dayName((Qt.locale().firstDayOfWeek + index) % 7, Locale.ShortFormat)
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.6
            }
        }

        Repeater {
            model: root.calCells(root.calYear, root.calMonth)
            Rectangle {
                id: cc
                readonly property var md: modelData
                readonly property bool today: {
                    var n = root.clockNow, x = new Date(cc.md.ts)
                    return x.getFullYear() === n.getFullYear() && x.getMonth() === n.getMonth() && x.getDate() === n.getDate()
                }
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                radius: 6
                color: cc.today ? Kirigami.Theme.highlightColor : (cellHover.containsMouse ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.10) : "transparent")
                PlasmaComponents.Label {
                    anchors.centerIn: parent
                    text: cc.md.d
                    color: cc.today ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                    opacity: cc.md.inMonth ? 1 : 0.35
                }
                MouseArea { id: cellHover; anchors.fill: parent; hoverEnabled: true }
            }
        }
    }

    // عنصر مرن لملء أي مساحة فارغة بدقة ودفع الزر السفلي مكانه الصحيح
    Item { Layout.fillHeight: true }

    PlasmaComponents.Button {
        Layout.fillWidth: true
        text: "Date & time settings"
        icon.name: "preferences-system-time"
        onClicked: { root.expanded = false; sh.run("kcmshell6 kcm_clock") }
    }
}
