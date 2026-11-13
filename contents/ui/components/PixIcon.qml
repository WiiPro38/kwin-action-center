import QtQuick

Item {
    id: px
    property var pix: null
    onPixChanged: if (pix && pix.w > 0 && pix.w <= 256 && pix.h > 0 && pix.h <= 256) cv.requestPaint()

    Canvas {
        id: cv
        // فرض أبعاد دنيا آمنة تماماً لمنع انهيار الـ Buffer
        width: px.pix && px.pix.w > 0 && px.pix.w <= 256 ? px.pix.w : 1
        height: px.pix && px.pix.h > 0 && px.pix.h <= 256 ? px.pix.h : 1

        readonly property real k: (px.width > 0 && px.height > 0 && width > 0 && height > 0) ? Math.min(px.width / width, px.height / height) : 1
        scale: isNaN(k) || k <= 0 ? 1 : k
        transformOrigin: Item.TopLeft

        x: (px.width - width * scale) / 2
        y: (px.height - height * scale) / 2
        smooth: true

        Component.onCompleted: if (px.pix && px.pix.w > 0) requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var p = px.pix
            if (!p || !p.d || p.w <= 0 || p.h <= 0 || p.w > 256 || p.h > 256) return
                try {
                    var img = ctx.createImageData(p.w, p.h)
                    var n = p.w * p.h
                    for (var i = 0; i < n; i++) {
                        var o = i * 4
                        if (o + 3 < p.d.length) {
                            img.data[o]     = p.d[o + 1]
                            img.data[o + 1] = p.d[o + 2]
                            img.data[o + 2] = p.d[o + 3]
                            img.data[o + 3] = p.d[o]
                        }
                    }
                    ctx.drawImage(img, 0, 0)
                } catch (e) {}
        }
    }
}
