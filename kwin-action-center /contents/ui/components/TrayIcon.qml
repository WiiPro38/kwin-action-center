import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: ti
    property var item: null

    // Fallback logic flags
    readonly property bool usePix: !!(item && item.pix && !item.icon)
    readonly property string themeFile: (item && item.localIcon) ? item.localIcon : ""

    // Check if the icon name looks dangerous or is empty
    readonly property string iconName: (ti.item && ti.item.icon) ? ti.item.icon : "application-x-executable"

    // 1. Safe Pixmap / Bitmap rendering (Highest priority & safest)
    PixIcon {
        anchors.fill: parent
        visible: ti.usePix
        pix: ti.usePix ? ti.item.pix : null
    }

    // 2. Safe Local File Image rendering (PNG/SVG converted locally)
    Image {
        id: localImg
        anchors.fill: parent
        visible: !ti.usePix && ti.themeFile !== ""
        source: ti.themeFile
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(32, 32) // Force strict bounding box to prevent "Buffer size too big" crash!
        asynchronous: true
        cache: false
    }

    // 3. Kirigami Icon with a fixed, small size (never stretches to parent)
    Kirigami.Icon {
        visible: !ti.usePix && ti.themeFile === ""
        anchors.centerIn: parent
        width: Math.max(1, Math.min(ti.width > 0 ? ti.width : 16, 32))
        height: width
        source: ti.iconName.length < 512 ? ti.iconName : "application-x-executable"
    }
}
