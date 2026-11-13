import QtQuick
import QtQuick.Layouts

Item {
    id: full
    readonly property int fixedWidth: 380

    // فرض حد أدنى صارم للارتفاع (480 بكسل) أو أكثر حسب محتوى الصفحة مع إضافة هوامش الإطار
    readonly property real rawPageHeight: pageLoader.item && pageLoader.item.implicitHeight > 0
    ? pageLoader.item.implicitHeight
    : (pageLoader.item && pageLoader.item.pagePreferredHeight !== undefined ? pageLoader.item.pagePreferredHeight : 450)

    readonly property real currentPageHeight: Math.max(500, rawPageHeight + 28)

    Layout.preferredWidth: fixedWidth
    Layout.minimumWidth: fixedWidth
    Layout.maximumWidth: fixedWidth

    Layout.preferredHeight: currentPageHeight
    Layout.minimumHeight: currentPageHeight
    Layout.maximumHeight: currentPageHeight

    clip: true
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true

    Loader {
        id: pageLoader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 14
        asynchronous: false
        source: {
            switch (root.page) {
                case 0: return "pages/HomePage.qml"
                case 1: return "pages/WifiPage.qml"
                case 2: return "pages/BluetoothPage.qml"
                case 3: return "pages/PowerPage.qml"
                case 4: return "pages/NightLightPage.qml"
                case 5: return "pages/SharePage.qml"
                case 6: return "pages/TraySettingsPage.qml"
                case 7: return "pages/AudioPage.qml"
                case 8: return "pages/TrayOverflowPage.qml"
                case 9: return "pages/DBusMenuPage.qml"
                case 10: return "pages/CalendarPage.qml"
                case 11: return "pages/AboutPage.qml"
                case 12: return "pages/MediaPage.qml" // صفحة الوسائط المنفصلة
                default: return "pages/HomePage.qml"
            }
        }
    }
}
