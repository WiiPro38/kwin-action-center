import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: ico
    property string name: ""
    property color color: Kirigami.Theme.textColor

    // تحديد أبعاد افتراضية آمنة وصارمة لمنع أي تمدد خاطئ للذاكرة
    implicitWidth: 24
    implicitHeight: 24

    Image {
        id: img
        anchors.centerIn: parent

        // تقييد الأبعاد بأمان تام داخل المساحة المتاحة وعدم السماح بتجاوز الحجم الطبيعي
        width: Math.min(ico.width, ico.height, 32)
        height: Math.min(ico.width, ico.height, 32)

        source: (ico.name && ico.name !== "" && width > 0 && height > 0) ? Qt.resolvedUrl("../../icons/" + ico.name + ".png") : ""

        fillMode: Image.PreserveAspectFit

        // الأهم: تحديد sourceSize يجبر محرك الصور على قراءة الصورة بالحجم المطلوب فقط وليس بحجمها الأصلي الخام
        sourceSize: Qt.size(32, 32)

        asynchronous: true
        cache: true
        visible: status === Image.Ready
    }
}
