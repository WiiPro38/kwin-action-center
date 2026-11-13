import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami
import org.kde.notificationmanager as NotificationManager

PlasmoidItem {
    id: root
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true

    // ============ الحالة العامة (State) ============
    property bool wifiOn: false
    property string wifiName: ""
    property bool ethernetOn: false
    property var ethernetDevices: []
    property string ethernetBusyDevice: ""
    property string ethernetMessage: ""
    property bool hotspotOn: false
    property bool hotspotBusy: false
    property string hotspotConnection: ""
    property string hotspotName: ""
    property string hotspotPassword: ""
    property string hotspotMessage: ""
    property bool btOn: false
    property int volume: 0
    property bool muted: false

    property bool hasBattery: false
    property int batteryLevel: 0
    property string batteryStatus: ""
    readonly property bool charging: batteryStatus === "Charging"

    property string profile: ""
    property var profiles: []
    // ============ نظام التحكم بالوسائط (MPRIS Media Control) ============
    property bool mediaActive: false
    property string mediaTitle: ""
    property string mediaArtist: ""
    property string mediaAlbum: ""
    property string mediaArtUrl: ""
    property bool mediaPlaying: false
    property string mediaIdentity: ""
    // السطوع
    property int brightness: 0
    property int brightnessMax: 0
    property int kbdBrightness: 0
    property int kbdMax: 0
    readonly property int brightnessPct: brightnessMax > 0 ? Math.round(brightness / brightnessMax * 100) : 0

    // حماية العين
    property bool nightOn: false
    property int nightTemp: 4500

    // المشاركة وأجهزة USB
    property var kdeDevices: []
    property var usbDevices: []
    property string usbMsg: ""

    // التاريخ والوقت مع دعم 12h / 24h
    readonly property var enLoc: Qt.locale("en_US")
    property var clockNow: new Date()
    property bool use12h: false

    readonly property string clockText: clockNow.toLocaleTimeString(enLoc, use12h ? "h:mm AP" : "hh:mm")
    readonly property string clockSecondsText: clockNow.toLocaleTimeString(enLoc, use12h ? "h:mm:ss AP" : "hh:mm:ss")
    readonly property string dateText: clockNow.toLocaleDateString(enLoc, "dd/MM/yyyy")
    property int calYear: new Date().getFullYear()
    property int calMonth: new Date().getMonth()

    function set12h(val) {
        use12h = val
        try { Plasmoid.configuration.use12h = val } catch (e) {}
    }
    function load12h() {
        try { use12h = !!Plasmoid.configuration.use12h } catch (e) {}
    }

    // تطبيقات الشريط (StatusNotifierItem)
    property var trayData: ({})
    property var trayKeys: []
    property var trayInlineKeys: []
    property var trayOverflowKeys: []
    property var trayHiddenOwn: ({})
    property string trayMsg: ""
    property int maxInline: 4
    readonly property int trayInlineLimit: maxInline
    property bool trayLoopOn: true

    // لوحة المفاتيح
    property var kbLayouts: []
    property int kbIndex: -1
    readonly property string kbLabel: (kbIndex >= 0 && kbIndex < kbLayouts.length) ? String(kbLayouts[kbIndex].short).toUpperCase().slice(0, 3) : ""
    readonly property string kbTip: (kbIndex >= 0 && kbIndex < kbLayouts.length) ? "Keyboard layout: " + kbLayouts[kbIndex].name + (kbLayouts.length > 1 ? " (click to switch)" : "") : ""

    // قائمة التطبيقات (DBusMenu)
    property var menuItem: null
    property string menuTitle: ""
    property var menuStack: []
    property var menuNodes: []
    property string menuError: ""
    property bool menuLoading: false

    // أجهزة الصوت
    property var sinks: []
    property var sources: []
    readonly property var wiredSinks: sinks.filter(d => !d.wireless)
    readonly property var wirelessSinks: sinks.filter(d => d.wireless)
    readonly property var wiredSources: sources.filter(d => !d.wireless)
    readonly property var wirelessSources: sources.filter(d => d.wireless)

    // حالة حماية العين الفعلية من KWin
    property bool nightStatusKnown: false
    property bool nightAvail: true
    property bool nightRunning: false
    property int nightCurrent: 0
    readonly property string nightStatus: {
        if (!nightStatusKnown) return ""
            if (!nightOn) return "Status: off"
                if (!nightAvail) return "Status: not supported in this session or on this display"
                    if (nightRunning) return "Status: running — current temperature " + nightCurrent + "K"
                        return "Status: enabled but not started yet, try turning it off and on"
    }

    // مراقبة الأداء
    property int cpuPct: 0
    property int memPct: 0
    property double prevCpuTotal: 0
    property double prevCpuIdle: 0

    // رقم الصفحة النشطة
    property int page: 0

    property var wifiNetworks: []
    property var knownWifi: []
    property string selectedSsid: ""
    property string wifiMessage: ""
    property bool wifiBusy: false

    property var btDevices: []
    property bool btScanning: false
    property string btBusy: ""

    property bool dnd: false
    property bool airplane: false
    property double airplaneGuard: 0
    readonly property color edge: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)

    readonly property string networkIcon: {
        if (wifiOn && wifiName !== "") return "wifi"
            if (ethernetOn) return "ethernet"
                return "wifi-off"
    }
    readonly property string volumeIcon: {
        if (muted || volume === 0) return "vol-mute"
            if (volume < 34) return "vol-low"
                if (volume < 67) return "vol-low"
                    return "vol-high"
    }
    readonly property string batteryIcon: {
        var l = Math.min(100, Math.max(0, Math.round(batteryLevel / 10) * 10))
        return "battery-" + ("000" + l).slice(-3) + (charging ? "-charging" : "")
    }

    preferredRepresentation: compactRepresentation
    compactRepresentation: Component {
        CompactRepresentation {}
    }

    fullRepresentation: Component {
        FullRepresentation {}
    }

    toolTipMainText: ""
    toolTipSubText: ""

    onExpandedChanged: {
        clockKick()
        if (root.expanded) {
            refresh()
            sysWaitLoop()
            trayWaitLoop()
        } else {
            page = 0
            selectedSsid = ""
            wifiMessage = ""
            menuNodes = []
        }
    }

    Component.onCompleted: {
        load12h();
        loadTrayHidden(); refresh(); refreshProfiles(); refreshTray();
        trayWaitLoop(); refreshKbList(); usbWaitLoop(); sysWaitLoop(); loadAirplane()
    }

    // ============ مشغل الأوامر التفاعلي (بدون تسريب ذاكرة) ============
    P5Support.DataSource {
        id: sh
        engine: "executable"
        connectedSources: []
        property var handlers: new Map()
        property int seq: 0

        onNewData: (source, data) => {
            if (!data || data["exit code"] === undefined) return
                disconnectSource(source)
                var h = handlers.get(source)
                handlers.delete(source)
                var o = (data["stdout"] || "").trim()
                var e = (data["stderr"] || "").trim()
                var c = data["exit code"]
                if (h) Qt.callLater(() => h(o, e, c))
        }

        function run(cmd, cb) {
            seq = (seq + 1) % 30
            var key = cmd + "\n# " + seq
            if (cb) handlers.set(key, cb)
                connectSource(key)
        }
    }

    function refreshMedia() {
        var cmd = "playerctl metadata --format '{{status}}|{{title}}|{{artist}}|{{album}}|{{artUrl}}|{{playerName}}' 2>/dev/null | head -n1; "
        + "playerctl status 2>/dev/null | head -n1"

        sh.run(cmd, out => {
            var lines = out.trim().split("\n")
            var line0 = lines[0] || ""

            if (line0.indexOf("|") >= 0) {
                var parts = line0.split("|")
                var st = parts[0].trim()
                mediaPlaying = (st === "Playing")
                mediaTitle = parts[1] || "Unknown Track"
                mediaArtist = parts[2] || ""
                mediaAlbum = parts[3] || ""
                mediaArtUrl = parts[4] || ""
                mediaIdentity = parts[5] || "media-player"
                mediaActive = true
            } else if (line0 === "Playing" || line0 === "Paused") {
                mediaPlaying = (line0 === "Playing")
                mediaActive = true

                sh.run("playerctl title 2>/dev/null | head -n1", t => { if(t.trim()) mediaTitle = t.trim() })
                sh.run("playerctl artist 2>/dev/null | head -n1", a => { if(a.trim()) mediaArtist = a.trim() })
                sh.run("playerctl metadata --format '{{playerName}}' 2>/dev/null | head -n1", p => { if(p.trim()) mediaIdentity = p.trim() })
            } else {
                mediaActive = false
            }
        })
    }

    function mediaCommand(act) {
        sh.run("playerctl " + act + " 2>/dev/null", () => refreshMedia())
    }

    // مراقبة الوسائط عند فتح الويدجت أو تحديث النظام
    Timer {
        interval: 2000
        repeat: true
        running: root.expanded
        triggeredOnStart: true
        onTriggered: root.refreshMedia()
    }

    // ============ منطق لوحة المفاتيح ============

    readonly property string kbCall: "busctl --user --json=short call org.kde.keyboard /Layouts org.kde.KeyboardLayouts "
    function lastJson(out) {
        var line = String(out).split("\n").filter(x => x.trim().charAt(0) === "{").pop()
        return JSON.parse(line)
    }
    function refreshKbList() {
        sh.run(kbCall + "getLayoutsList 2>/dev/null", out => {
            try {
                var j = lastJson(out)
                kbLayouts = (j.data[0] || []).map(e => ({ short: e[0], name: e[2] || e[1] || e[0] }))
                refreshKb()
            } catch (e) {}
        })
    }
    function refreshKb() {
        sh.run(kbCall + "getLayout 2>/dev/null", out => {
            try { var n = lastJson(out).data[0]; if (n !== kbIndex) kbIndex = n } catch (e) {}
        })
    }
    function nextKb() {
        if (kbLayouts.length < 2) return
            var n = (kbIndex + 1) % kbLayouts.length
            kbIndex = n
            sh.run("busctl --user call org.kde.keyboard /Layouts org.kde.KeyboardLayouts setLayout u " + n, () => refreshKb())
    }
    Timer { interval: 60000; repeat: true; running: root.kbLayouts.length > 0; onTriggered: root.refreshKb() }
    Timer { interval: 300000; repeat: true; running: true; onTriggered: root.refreshKbList() }

    property Item compactItem: null
    readonly property bool inShell: Qt.application.name !== "plasmoidviewer"

    // ============ الساعة والتقويم ============
    function clockKick() {
        clockNow = new Date()
        var fast = expanded && page === 10
        clockTimer.interval = fast ? 1000 - Date.now() % 1000 + 5 : 60000 - Date.now() % 60000 + 30
        clockTimer.restart()
    }
    Timer { id: clockTimer; interval: 1000; repeat: false; running: true; onTriggered: root.clockKick() }
    function calShift(n) {
        var m = calMonth + n, y = calYear
        while (m < 0) { m += 12; y-- }
        while (m > 11) { m -= 12; y++ }
        calMonth = m; calYear = y
    }
    function calToday() { var t = new Date(); calYear = t.getFullYear(); calMonth = t.getMonth() }
    onPageChanged: { if (page === 10) calToday(); clockKick() }
    function calCells(y, m) {
        var first = new Date(y, m, 1)
        var lead = (first.getDay() - Qt.locale().firstDayOfWeek + 7) % 7
        var out = []
        for (var i = 0; i < 42; i++) {
            var d = new Date(y, m, 1 - lead + i)
            out.push({ d: d.getDate(), inMonth: d.getMonth() === m, ts: d.getTime() })
        }
        return out
    }

    // ============ أحداث النظام العامة ============
    readonly property string sysWaitScript: [
        "f=$(mktemp -u \"${XDG_RUNTIME_DIR:-/tmp}/ptry-ev.XXXXXX\"); mkfifo \"$f\" || exit 0",
        "exec 3<>\"$f\"; rm -f \"$f\"",
        "( exec timeout 65 dbus-monitor --session \"type='signal',interface='org.kde.KeyboardLayouts'\" \"type='signal',interface='org.kde.ScreenBrightness.Display'\" \"type='signal',interface='org.kde.ScreenBrightness'\" \"type='signal',path='/org/kde/KWin/NightLight'\" >&3 2>/dev/null ) & p1=$!",
        "( exec timeout 65 dbus-monitor --system \"type='signal',sender='org.freedesktop.NetworkManager',path='/org/freedesktop/NetworkManager'\" \"type='signal',sender='org.freedesktop.NetworkManager',interface='org.freedesktop.NetworkManager.Device',member='StateChanged'\" \"type='signal',sender='org.freedesktop.UPower',path_namespace='/org/freedesktop/UPower/devices'\" \"type='signal',sender='org.freedesktop.UPower',path='/org/freedesktop/UPower/PowerProfiles'\" \"type='signal',path='/net/hadess/PowerProfiles'\" \"type='signal',sender='org.bluez',path_namespace='/org/bluez/hci0'\" >&3 2>/dev/null ) & p2=$!",
        "( exec timeout 65 pactl subscribe >&3 2>/dev/null ) & p3=$!",
        "t=55; out=\"\"; st0=0",
        "while read -r -t $t -u 3 l; do",
        "  case \"$l\" in",
        "    Event*) case \"$l\" in *\" on sink \"*|*\" on server\"*) k=vol;; *) continue;; esac;;",
        "    signal*)",
        "      case \"$l\" in",
        "        *member=layoutChanged*) k=kb;;",
        "        *interface=org.kde.ScreenBrightness*) k=br;;",
        "        *path=/org/kde/KWin/NightLight*) k=night;;",
        "        *path=/org/freedesktop/NetworkManager*) k=net;;",
        "        *path=/org/freedesktop/UPower/devices/*) k=bat;;",
        "        *path=/org/bluez/hci0\\;*) k=bt;;",
        "        *path=/org/bluez/hci0/*) k=btdev;;",
        "        *path=/net/hadess/PowerProfiles*|*path=/org/freedesktop/UPower/PowerProfiles*) k=prof;;",
        "        *) continue;;",
        "      esac;;",
        "    *) continue;;",
        "  esac",
        "  case \" $out \" in *\" $k \"*) ;; *) out=\"$out $k\";; esac",
        "  n=${EPOCHREALTIME/./}; [ \"$st0\" = 0 ] && st0=$n",
        "  t=0.15",
        "  [ $((n-st0)) -gt 400000 ] && break",
        "done",
        "kill $p1 $p2 $p3 2>/dev/null",
        "echo \"$out\""
    ].join("\n")

    function sysWaitLoop() {
        if (!root) return
            var t0 = Date.now()
            sh.run("bash -c " + q(sysWaitScript), out => {
                if (!root) return
                    var tags = out.trim().split(/\s+/).filter(x => x)
                    var elapsed = Date.now() - t0
                    if (tags.length === 0 || elapsed < 500) {
                        sysRetry.interval = 4000
                        sysRetry.restart()
                    } else {
                        Qt.callLater(sysWaitLoop)
                    }
                    handleSysTags(tags)
            })
    }
    Timer { id: sysRetry; interval: 4000; onTriggered: root.sysWaitLoop() }

    function handleSysTags(tags) {
        var has = t => tags.indexOf(t) >= 0
        if (has("vol")) refreshVolume()
            if (has("br")) { refreshBrightness(); refreshKbdLight() }
            if (has("kb")) refreshKb()
                if (has("bat")) refreshBattery()
                    if (has("net")) { refreshNet(); if (expanded && page === 1 && !wifiBusy) refreshWifiList() }
                    if (has("bt")) refreshBtState()
                        if (has("btdev") && expanded && page === 2) refreshBt()
                            if (has("night")) { refreshNightCfg(); if (expanded && page === 4) refreshNightStatus() }
                            if (has("prof")) refreshActiveProfile()
    }

    // ============ USB عبر udev ============
    readonly property string usbWaitScript: [
        "coproc U { exec udevadm monitor --udev --subsystem-match=block --subsystem-match=usb 2>/dev/null; }",
        "t=55; hit=0; st0=0",
        "while read -r -t $t -u \"${U[0]}\" l; do",
        "  case \"$l\" in UDEV*) ;; *) continue;; esac",
        "  hit=1; n=${EPOCHREALTIME/./}",
        "  [ \"$st0\" = 0 ] && st0=$n",
        "  t=0.5",
        "  [ $((n-st0)) -gt 3000000 ] && break",
        "done",
        "kill \"$U_PID\" 2>/dev/null",
        "echo $hit"
    ].join("\n")

    function usbWaitLoop() {
        if (!root) return
            var t0 = Date.now()
            sh.run("bash -c " + q(usbWaitScript), out => {
                if (!root) return
                    if (out.trim() === "1") { refreshUsb(); usbLater.restart() }
                    if (Date.now() - t0 < 400) usbRetry.restart()
                        else usbWaitLoop()
            })
    }
    Timer { id: usbRetry; interval: 5000; onTriggered: root.usbWaitLoop() }
    Timer { id: usbLater; interval: 2000; onTriggered: root.refreshUsb() }

    function q(s) { return "'" + String(s).replace(/'/g, "'\\''") + "'" }

    function profileLabel(p) {
        if (p === "power-saver") return "Power Saver"
            if (p === "performance") return "Performance"
                if (p === "balanced") return "Balanced"
                    return p
    }
    function profileDesc(p) {
        if (p === "power-saver") return "Extends battery life"
            if (p === "performance") return "Maximum performance, higher power use"
                return "Balance between performance and power"
    }
    function profileIcon(p) {
        if (p === "power-saver") return "leaf"
            if (p === "performance") return "zap"
                return "gauge"
    }
    function statusLabel(s) {
        if (s === "Charging") return "Charging"
            if (s === "Discharging") return "On battery"
                if (s === "Full") return "Full"
                    if (s === "Not charging") return "Plugged in"
                        return s
    }

    // ============ معالجة السطوع والصوت ============
    property int pendingBrightness: -1
    property int pendingKbd: -1
    property int pendingVolume: -1
    property bool brBusy: false
    property bool kbdBusy: false
    property bool volBusy: false
    property double lastBrAdjust: 0
    property double lastKbdAdjust: 0
    property double lastVolAdjust: 0

    property var brWrite: null
    property string brRead: ""
    property bool brDetecting: false

    function setBrightnessPct(p) {
        var raw = Math.max(1, Math.round(p / 100 * brightnessMax))
        brightness = raw
        pendingBrightness = raw
        lastBrAdjust = Date.now()
        applyBrightness()
    }
    function applyBrightness() {
        if (brBusy || pendingBrightness < 0) return
            var v = pendingBrightness
            pendingBrightness = -1
            brBusy = true
            sh.run(brWrite ? brWrite(v) : ("brightnessctl -q set " + v),
                   () => { brBusy = false; lastBrAdjust = Date.now(); if (pendingBrightness >= 0) applyBrightness() })
    }

    function setKbd(v) {
        kbdBrightness = v
        pendingKbd = v
        lastKbdAdjust = Date.now()
        applyKbd()
    }
    function applyKbd() {
        if (kbdBusy || pendingKbd < 0) return
            var k = pendingKbd
            pendingKbd = -1
            kbdBusy = true
            sh.run("busctl --user call org.kde.KeyboardBrightnessControl /org/kde/KeyboardBrightnessControl org.kde.KeyboardBrightnessControl setKeyboardBrightness i " + k
            + " 2>/dev/null || busctl --user call org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/KeyboardBrightnessControl org.kde.Solid.PowerManagement.Actions.KeyboardBrightnessControl setKeyboardBrightness i " + k
            + " 2>/dev/null || brightnessctl -q -d '*kbd_backlight*' set " + k,
            () => { kbdBusy = false; lastKbdAdjust = Date.now(); if (pendingKbd >= 0) applyKbd() })
    }

    function setVolume(v) {
        volume = v
        muted = false
        pendingVolume = v
        lastVolAdjust = Date.now()
        applyVolume()
    }
    function applyVolume() {
        if (volBusy || pendingVolume < 0) return
            var v = pendingVolume
            pendingVolume = -1
            volBusy = true
            sh.run("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (v / 100).toFixed(2),
                   () => { volBusy = false; lastVolAdjust = Date.now(); if (pendingVolume >= 0) applyVolume() })
    }

    // ============ حماية العين ============
    property bool nightBusy: false
    property bool nightDirty: false
    property double lastNightAdjust: 0

    function setNight(on, temp) {
        nightOn = on
        nightTemp = temp
        lastNightAdjust = Date.now()
        if (nightBusy) nightDirty = true
            else applyNight()
    }
    function bytesArg(k) {
        var a = [k.length]
        for (var i = 0; i < k.length; i++) a.push(k.charCodeAt(i))
            return a.join(" ")
    }
    function applyNight() {
        nightBusy = true
        nightDirty = false
        var base = "kwriteconfig6 --file kwinrc --group NightColor --key "
        var keys = ["Active", "Mode", "NightTemperature"]
        var emit = "busctl --user emit /kconfig/kwinrc org.kde.kconfig.notify ConfigChanged 'a{saay}' 1 NightColor "
        + keys.length + " " + keys.map(bytesArg).join(" ")
        var cmd = base + "Active " + (nightOn ? "true" : "false")
        + " && " + base + "Mode Constant"
        + " && " + base + "NightTemperature " + nightTemp
        + " ; " + emit
        + " ; busctl --user call org.kde.KWin /KWin org.kde.KWin reconfigure"
        if (nightOn)
            cmd += " ; busctl --user call org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight preview u " + nightTemp
            sh.run(cmd, () => { nightBusy = false; lastNightAdjust = Date.now(); nightStatusTimer.restart(); if (nightDirty) applyNight() })
    }

    // ============ دوال التحديث ============
    function refreshNet() {
        sh.run("nmcli radio wifi", out => wifiOn = (out.trim() === "enabled"))
        sh.run("nmcli -t -f active,ssid dev wifi | grep '^yes' | head -n1 | cut -d: -f2",
               out => wifiName = out.trim())

        // تصفية دقيقة لعرض كروت الإيثرنت الحقيقية فقط واستبعاد loopback والواي فاي
        sh.run("nmcli -t --escape no -f DEVICE,TYPE,STATE,CONNECTION device status",
               out => {
                   var rows = []
                   out.split("\n").forEach(line => {
                       var a = line.trim().split(":")
                       if (a.length < 3 || !a[0]) return
                           var devName = (a[0] || "").toLowerCase()
                           var type = (a[1] || "").toLowerCase()
                           var state = (a[2] || "").toLowerCase()

                           // استبعاد الـ loopback والواي فاي والـ bridges الوهمية، وقبول الأجهزة السلكية فقط
                           if (devName === "lo" || devName.indexOf("wlan") === 0 || devName.indexOf("wlo") === 0 || devName.indexOf("p2p") === 0) return

                               if ((type === "ethernet" || type === "usb" || type === "bridge" || devName.indexOf("en") === 0 || devName.indexOf("eth") === 0)
                                   && state.indexOf("connected") === 0) {
                                   rows.push({
                                       device: a[0],
                                       connection: a.slice(3).join(":") || "Wired connection",
                                             state: a[2] || "Connected",
                                             mac: "",
                                             speed: "",
                                             ip: "",
                                             gateway: ""
                                   })
                                   }
                   })
                   ethernetDevices = rows
                   ethernetOn = rows.length > 0
               })
        refreshHotspot()
    }
    function disconnectEthernet(device) {
        if (!device || ethernetBusyDevice !== "") return
        ethernetBusyDevice = device
        ethernetMessage = ""
        sh.run("nmcli device disconnect " + q(device), (out, err, code) => {
            ethernetBusyDevice = ""
            if (code !== 0) ethernetMessage = (err || out || "Could not disconnect wired network").split("\n")[0]
            refreshNet()
            later.restart()
        })
    }
    function openNetworkSettings() {
        sh.run("kcmshell6 kcm_networkmanagement 2>/dev/null || systemsettings kcm_networkmanagement")
    }
    function refreshHotspot() {
        var cmd = "nmcli -t -f NAME,TYPE connection show --active | while IFS=: read -r n t; do if [ \"$t\" = \"802-11-wireless\" ] && [ \"$(nmcli -g 802-11-wireless.mode connection show \"$n\" 2>/dev/null)\" = \"ap\" ]; then printf '%s|%s\\n' \"$n\" \"$(nmcli -g 802-11-wireless.ssid connection show \"$n\" 2>/dev/null)\"; fi; done | head -n1"
        sh.run(cmd, out => {
            var a = out.split("|")
            hotspotOn = a.length > 1 && a[0] !== ""
            hotspotConnection = hotspotOn ? a[0] : ""
            hotspotName = hotspotOn ? a.slice(1).join("|").trim() : ""
            if (hotspotOn) {
                sh.run("nmcli --show-secrets -g 802-11-wireless-security.psk connection show " + q(hotspotConnection), secret => hotspotPassword = secret)
            } else {
                hotspotPassword = ""
            }
        })
    }
    function toggleHotspot() {
        if (hotspotBusy) return
        hotspotBusy = true
        hotspotMessage = ""
        if (hotspotOn && hotspotConnection !== "") {
            sh.run("nmcli connection down " + q(hotspotConnection), (out, err, code) => {
                hotspotBusy = false
                if (code !== 0) hotspotMessage = err || out || "Could not stop hotspot"
                refreshHotspot(); later.restart()
            })
        } else {
            var cmd = "nmcli radio wifi on; dev=$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2==\"wifi\"{print $1; exit}'); [ -n \"$dev\" ] || exit 2; nmcli device wifi hotspot ifname \"$dev\" con-name ZIRAM-Hotspot ssid ZIRAM-Hotspot"
            sh.run(cmd, (out, err, code) => {
                hotspotBusy = false
                if (code !== 0) hotspotMessage = err || out || "Could not start hotspot. Check that Wi-Fi is available."
                refreshHotspot(); refreshNet(); later.restart()
            })
        }
    }
    function refreshBtState() {
        sh.run("bluetoothctl show | grep -c 'Powered: yes'", out => btOn = (out === "1"))
    }
    function refreshVolume() {
        sh.run("wpctl get-volume @DEFAULT_AUDIO_SINK@", out => {
            if (volBusy || pendingVolume >= 0 || Date.now() - lastVolAdjust < 2500) return
                var m = out.match(/([0-9.]+)/)
                if (m) volume = Math.round(parseFloat(m[1]) * 100)
                    muted = out.indexOf("MUTED") >= 0
        })
    }
    function refreshBattery() {
        sh.run('b=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1); [ -n "$b" ] && echo "$(cat $b/capacity) $(cat $b/status)"', out => {
            var m = out.match(/^(\d+)\s+(.+)$/)
            hasBattery = !!m
            if (m) { batteryLevel = parseInt(m[1]); batteryStatus = m[2] }
        })
    }
    function refreshKbdLight() {
        sh.run('d=$(ls -d /sys/class/leds/*kbd_backlight* 2>/dev/null | head -n1); [ -n "$d" ] && echo "$(cat $d/brightness) $(cat $d/max_brightness)"', out => {
            if (kbdBusy || pendingKbd >= 0 || Date.now() - lastKbdAdjust < 2500) return
                var m = out.match(/^(\d+)\s+(\d+)/)
                if (m) { kbdMax = parseInt(m[2]); kbdBrightness = parseInt(m[1]) } else kbdMax = 0
        })
    }
    function refreshNightCfg() {
        sh.run("kreadconfig6 --file kwinrc --group NightColor --key Active --default false; kreadconfig6 --file kwinrc --group NightColor --key NightTemperature --default 4500", out => {
            if (nightBusy || nightDirty || Date.now() - lastNightAdjust < 2500) return
                var l = out.split("\n")
                nightOn = (l[0] === "true")
                var t = parseInt(l[1])
                if (t) nightTemp = t
        })
    }
    function refresh() {
        refreshNet()
        refreshBtState()
        refreshVolume()
        refreshBattery()
        refreshActiveProfile()
        refreshBrightness()
        refreshKbdLight()
        refreshNightCfg()
        refreshDnd()
        if (expanded) refreshShare()
            refreshUsb()
            if (expanded && page === 7) refreshAudioDevices()
                if (expanded && page === 4) refreshNightStatus()
                    if (expanded && profiles.length === 0) refreshProfiles()
    }

    function cutv(cmd) { return "$(" + cmd + " 2>/dev/null | cut -d' ' -f2)" }

    function detectBrightness() {
        if (brDetecting) return
            brDetecting = true
            sh.run("busctl --user get-property org.kde.ScreenBrightness /org/kde/ScreenBrightness org.kde.ScreenBrightness DisplaysDBusNames 2>/dev/null", out => {
                var cands = []
                var m = out.match(/"([A-Za-z0-9_]+)"/)
                if (m) {
                    var path = "/org/kde/ScreenBrightness/" + m[1]
                    var iface = "org.kde.ScreenBrightness.Display"
                    var base = "busctl --user "
                    cands.push({
                        read: "echo " + cutv(base + "get-property org.kde.ScreenBrightness " + path + " " + iface + " Brightness")
                        + " " + cutv(base + "get-property org.kde.ScreenBrightness " + path + " " + iface + " MaxBrightness"),
                               write: v => base + "call org.kde.ScreenBrightness " + path + " " + iface + " SetBrightness iu " + v + " 0"
                    })
                }
                var po = "org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl"
                cands.push({
                    read: "echo " + cutv("busctl --user call " + po + " brightness") + " " + cutv("busctl --user call " + po + " brightnessMax"),
                           write: v => "busctl --user call " + po + " setBrightness i " + v
                })
                cands.push({
                    read: "brightnessctl -m 2>/dev/null | head -n1 | cut -d, -f3,5 | tr , ' '",
                    write: v => "brightnessctl -q set " + v
                })
                tryBrightness(cands, 0)
            })
    }
    function tryBrightness(cands, i) {
        if (i >= cands.length) { brDetecting = false; brightnessMax = 0; return }
        sh.run(cands[i].read, out => {
            var m = out.match(/^(\d+)\s+(\d+)/)
            if (m && parseInt(m[2]) > 0) {
                brRead = cands[i].read
                brWrite = cands[i].write
                brightnessMax = parseInt(m[2])
                brightness = parseInt(m[1])
                brDetecting = false
            } else {
                tryBrightness(cands, i + 1)
            }
        })
    }
    function refreshBrightness() {
        if (brRead === "") { detectBrightness(); return }
        sh.run(brRead, out => {
            if (brBusy || pendingBrightness >= 0 || Date.now() - lastBrAdjust < 2500) return
                var m = out.match(/^(\d+)\s+(\d+)/)
                if (m && parseInt(m[2]) > 0) { brightnessMax = parseInt(m[2]); brightness = parseInt(m[1]) }
        })
    }

    readonly property string ppd1: "net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles"
    readonly property string ppd2: "org.freedesktop.UPower.PowerProfiles /org/freedesktop/UPower/PowerProfiles org.freedesktop.UPower.PowerProfiles"

    function refreshProfiles() {
        sh.run("busctl get-property " + ppd1 + " Profiles 2>/dev/null"
        + " || busctl get-property " + ppd2 + " Profiles 2>/dev/null"
        + " || powerprofilesctl list 2>/dev/null", out => {
            var found = []
            ;["power-saver", "balanced", "performance"].forEach(p => {
                if (out.indexOf('"' + p + '"') >= 0 || out.indexOf(p + ":") >= 0) found.push(p)
            })
            profiles = found
        })
    }
    function refreshActiveProfile() {
        sh.run(profReadCmd(), out => {
            var m = out.match(/"([a-z-]+)"/)
            profile = m ? m[1] : out
        })
    }

    function refreshStats() {
        sh.run("head -n1 /proc/stat; grep -E '^(MemTotal|MemAvailable):' /proc/meminfo", out => {
            var lines = out.split("\n")
            var c = lines[0].trim().split(/\s+/).slice(1).map(Number)
            var idle = c[3] + (c[4] || 0)
            var total = c.reduce((x, y) => x + y, 0)
            if (prevCpuTotal > 0 && total > prevCpuTotal)
                cpuPct = Math.max(0, Math.min(100, Math.round(100 * (1 - (idle - prevCpuIdle) / (total - prevCpuTotal)))))
                prevCpuTotal = total
                prevCpuIdle = idle
                var mt = 0
                var ma = 0
                lines.slice(1).forEach(l => {
                    var m = l.match(/^(\w+):\s+(\d+)/)
                    if (m) { if (m[1] === "MemTotal") mt = parseInt(m[2]); else ma = parseInt(m[2]) }
                })
                if (mt > 0) memPct = Math.round(100 * (1 - ma / mt))
        })
    }
    Timer {
        interval: 1500
        repeat: true
        running: root.expanded && root.page === 3
        triggeredOnStart: true
        onTriggered: root.refreshStats()
    }

    function refreshNightStatus() {
        sh.run("busctl --user get-property org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight available running currentTemperature 2>/dev/null", out => {
            var l = out.split("\n")
            if (l.length < 3) { nightStatusKnown = false; return }
            nightStatusKnown = true
            nightAvail = l[0].indexOf("true") >= 0
            nightRunning = l[1].indexOf("true") >= 0
            nightCurrent = parseInt(l[2].split(" ")[1]) || 0
        })
    }
    Timer { id: nightStatusTimer; interval: 900; onTriggered: root.refreshNightStatus() }

    function toggleNight() {
        var t = nightTemp > 5500 ? 4500 : nightTemp
        setNight(!nightOn, t)
    }

    function refreshShare() {
        sh.run("kdeconnect-cli -a --id-name-only 2>/dev/null", out => {
            var arr = []
            out.split("\n").forEach(l => {
                var m = l.match(/^([0-9a-fA-F_-]+)\s+(.+)$/)
                if (m) arr.push({ id: m[1], name: m[2] })
            })
            kdeDevices = arr
        })
    }
    function shareFile(id) {
        sh.run('f=$(kdialog --getopenfilename "$HOME" 2>/dev/null); [ -n "$f" ] && kdeconnect-cli -d ' + id + ' --share "$f"')
    }

    function refreshUsb() {
        sh.run("lsblk -J -o NAME,PATH,LABEL,SIZE,TRAN,HOTPLUG,RM,MOUNTPOINT,FSTYPE,TYPE,MODEL 2>/dev/null", out => {
            var list = []
            try {
                var j = JSON.parse(out)
                ;(j.blockdevices || []).forEach(d => {
                    var removable = d.tran === "usb" || d.rm === true || d.rm === 1 || d.rm === "1"
                    if (!removable) return
                        var parts = (d.children || []).filter(c => c.fstype)
                        if (parts.length === 0 && d.fstype) parts = [d]
                            if (parts.length === 0 && d.size && d.size !== "0B") parts = [d]
                                parts.forEach(c => list.push({
                                    path: c.path,
                                    disk: d.path,
                                    name: c.label || (d.model || "").trim() || c.name,
                                                             size: c.size || "",
                                                             mount: c.mountpoint || "",
                                                             fs: c.fstype || ""
                                }))
                })
            } catch (e) {
                list = []
            }
            usbDevices = list
        })
    }
    function usbOpen(d) {
        usbMsg = ""
        var find = "findmnt -rn -o TARGET -S " + q(d.path) + " | head -n1"
        sh.run("mp=$(" + find + "); "
        + "if [ -z \"$mp\" ]; then udisksctl mount -b " + q(d.path) + " >/dev/null 2>&1; mp=$(" + find + "); fi; "
        + "if [ -n \"$mp\" ]; then xdg-open \"$mp\"; else echo 'Could not mount the disk'; exit 1; fi",
        (out, err, code) => {
            if (code !== 0) usbMsg = (out || err || "Could not open the disk").split("\n")[0]
                refreshUsb()
        })
    }
    function usbEject(d) {
        usbMsg = "Ejecting…"
        sh.run("udisksctl unmount -b " + q(d.disk) + " >/dev/null 2>&1; "
        + "for p in $(lsblk -lnp -o PATH " + q(d.disk) + " | tail -n +2); do udisksctl unmount -b \"$p\" >/dev/null 2>&1; done; "
        + "udisksctl power-off -b " + q(d.disk) + " 2>&1",
               (out, err, code) => {
                   usbMsg = code !== 0 ? "Eject failed: " + (out || err).split("\n")[0] : ""
                   refreshUsb()
               })
    }

    // ============ مراقبة تطبيقات الدرج ============
    readonly property string trayWaitScript: [
        "skip=\" $1 \"",
        "coproc M { exec dbus-monitor --session \"type='signal',interface='org.kde.StatusNotifierItem'\" \"type='signal',interface='org.kde.StatusNotifierWatcher'\" 2>/dev/null; }",
        "t=55; out=\"\"; st0=0",
        "while read -r -t $t -u \"${M[0]}\" l; do",
        "  case \"$l\" in signal*) ;; *) continue;; esac",
        "  m=${l##*member=}; s=${l#*sender=}; s=${s%% *}",
        "  case \"$m\" in",
        "    NewIcon|NewAttentionIcon|NewOverlayIcon) case \"$skip\" in *\" $s \"*) continue;; esac; k=\"I:$s\";;",
        "    NewToolTip|NewTitle|NewStatus) k=\"S:$s\";;",
        "    StatusNotifierItemRegistered|StatusNotifierItemUnregistered) k=\"LIST\";;",
        "    *) continue;;",
        "  esac",
        "  case \" $out \" in *\" $k \"*) ;; *) out=\"$out $k\";; esac",
        "  n=${EPOCHREALTIME/./}",
        "  [ \"$st0\" = 0 ] && st0=$n",
        "  t=0.05",
        "  [ $((n-st0)) -gt 150000 ] && break",
        "done",
        "kill \"$M_PID\" 2>/dev/null",
        "echo \"$out\""
    ].join("\n")

    function stripHtml(t) {
        return String(t || "").replace(/<br\s*\/?>/gi, "\n").replace(/<[^>]*>/g, "")
        .replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, "\"").replace(/&amp;/g, "&").trim()
    }
    function pickPix(list) {
        if (!list || !Array.isArray(list) || list.length === 0) return null
        var best = null
        list.forEach(e => {
            if (!Array.isArray(e) || e.length < 3) return
            var w = e[0], h = e[1], d = e[2]
            // Reject invalid or oversized bitmaps: they cause "buffer size too big" and native crashes
            if (!(w >= 1 && w <= 256 && h >= 1 && h <= 256)) return
            if (!d || d.length < w * h * 4) return
            if (!best || Math.abs(w - 32) < Math.abs(best[0] - 32)) best = e
        })
        return best ? { w: best[0], h: best[1], d: best[2] } : null
    }
    function parseTrayItem(key, svc, path, owner, p) {
        var v = (name, def) => (p[name] && p[name].data !== undefined) ? p[name].data : def
        var status = v("Status", "Active")
        var icon = v("IconName", "")
        var pix = v("IconPixmap", [])
        if (status === "NeedsAttention") {
            var an = v("AttentionIconName", "")
            var ap = v("AttentionIconPixmap", [])
            if (an || ap.length > 0) { icon = an; pix = ap }
        }
        var tip = v("ToolTip", ["", [], "", ""])
        return {
            key: key,
            id: v("Id", "") || key,
            title: v("Title", "") || v("Id", "") || svc,
            status: status,
            icon: icon,
            themePath: v("IconThemePath", ""),
            pix: pickPix(pix),
            svc: svc,
            path: path,
            owner: owner,
            menu: v("Menu", ""),
            isMenu: !!v("ItemIsMenu", false),
            tipTitle: tip[2] || "",
            tipText: stripHtml(tip[3])
        }
    }
    function splitKey(key) {
        var i = key.indexOf("/")
        return i < 0 ? { svc: key, path: "/StatusNotifierItem" } : { svc: key.slice(0, i), path: key.slice(i) }
    }
    property var trayBusy: new Map()
    function fetchTrayItem(key, done) {
        if (trayBusy.get(key)) return
            trayBusy.set(key, true)
            var k = splitKey(key)
            sh.run("busctl --user --json=short call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus GetNameOwner s " + q(k.svc) + " 2>/dev/null; echo; "
            + "busctl --user --json=short call " + q(k.svc) + " " + q(k.path) + " org.freedesktop.DBus.Properties GetAll s org.kde.StatusNotifierItem 2>/dev/null", out => {
                trayBusy.delete(key)
                var owner = ""
                var props = null
                out.split("\n").forEach(l => {
                    l = l.trim()
                    if (!l) return
                        try {
                            var j = JSON.parse(l)
                            if (j.type === "s") owner = j.data[0]
                                else if (j.type === "a{sv}") props = j.data[0]
                        } catch (e) {}
                })
                var d = {}
                for (var x in trayData) d[x] = trayData[x]
                    d[key] = props ? parseTrayItem(key, k.svc, k.path, owner, props) : { failed: true }
                    trayData = d
                    rebuildTrayLists()
                    var cur = d[key]
                    if (cur && cur.themePath && cur.icon && cur.icon.indexOf("/") !== 0) {
                        var src = q(cur.themePath + "/" + cur.icon)
                        var nm = q(String(key).replace(/[^A-Za-z0-9]/g, "_").slice(-24) + "-" + cur.icon)
                        sh.run("d=\"${XDG_RUNTIME_DIR:-/tmp}/plasma-try-icons\"; mkdir -p \"$d\"; n=" + nm + "; "
                        + "for e in svg png; do if [ -f " + src + ".$e ]; then cp -f " + src + ".$e \"$d/$n.$e\" 2>/dev/null && echo \"$d/$n.$e\" && break; fi; done",
                        p => {
                            if (!p) return
                                if (!trayData[key] || !trayData[key].svc) return
                                    var d2 = {}
                                    for (var x in trayData) d2[x] = trayData[x]
                                        var c2 = {}
                                        for (var f in d2[key]) c2[f] = d2[key][f]
                                            c2.localIcon = "file://" + p
                                            d2[key] = c2
                                            trayData = d2
                        })
                    }
                    if (done) done()
            })
    }
    function rebuildTrayLists() {
        var keys = Object.keys(trayData).filter(x => trayData[x] && trayData[x].svc)
        keys.sort((a, b) => trayData[a].title.localeCompare(trayData[b].title))
        var vis = keys.filter(x => !trayHiddenOwn[trayData[x].id] && trayData[x].status !== "Passive")
        var lim = trayInlineLimit
        var inl = vis.slice(0, lim)
        var ovf = vis.slice(lim)
        if (JSON.stringify(keys) !== JSON.stringify(trayKeys)) trayKeys = keys
            if (JSON.stringify(inl) !== JSON.stringify(trayInlineKeys)) trayInlineKeys = inl
                if (JSON.stringify(ovf) !== JSON.stringify(trayOverflowKeys)) trayOverflowKeys = ovf
    }
    function refreshTray() {
        sh.run("busctl --user get-property org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.kde.StatusNotifierWatcher RegisteredStatusNotifierItems 2>/dev/null", out => {
            var keys = (out.match(/"[^"]*"/g) || []).map(x => x.slice(1, -1))
            var d = {}
            keys.forEach(x => { if (trayData[x]) d[x] = trayData[x] })
            trayData = d
            rebuildTrayLists()
            keys.filter(x => !trayData[x]).forEach(x => fetchTrayItem(x))
        })
    }

    property var iconLast: new Map()
    property var iconSkip: new Map()
    property int iconSkipCount: 0
    function skipList() {
        var now = Date.now(), o = []
        var dead = []
        iconSkip.forEach((v, k) => { if (v > now) o.push(k); else dead.push(k) })
        dead.forEach(k => iconSkip.delete(k))
        iconSkipCount = o.length
        return o.join(" ")
    }
    function fetchOwner(owner) {
        Object.keys(trayData).forEach(x => {
            var it = trayData[x]
            if (it && it.owner === owner) fetchTrayItem(x)
        })
    }
    function iconSignal(owner) {
        var now = Date.now()
        if (now - (iconLast.get(owner) || 0) < 1000) { iconSkip.set(owner, now + 15000); iconSkipCount = iconSkip.size }
        iconLast.set(owner, now)
        fetchOwner(owner)
    }
    Timer {
        interval: 1000; repeat: true; running: root.iconSkipCount > 0
        onTriggered: {
            var now = Date.now()
            root.iconSkip.forEach((v, k) => { if (v > now) root.fetchOwner(k) })
            root.skipList()
        }
    }
    function trayWaitLoop() {
        if (!trayLoopOn) return
            var t0 = Date.now()
            sh.run("bash -c " + q(trayWaitScript) + " _ " + q(skipList()), out => {
                if (!root) return
                    var toks = out.trim().split(/\s+/).filter(x => x)
                    if (toks.length === 0 && Date.now() - t0 < 500) {
                        trayRetry.interval = 4000
                        trayRetry.restart()
                    } else {
                        Qt.callLater(trayWaitLoop)
                    }
                    if (toks.indexOf("LIST") >= 0) refreshTray()
                        toks.forEach(t => {
                            if (t.indexOf("S:") === 0) fetchOwner(t.slice(2))
                                else if (t.indexOf("I:") === 0) iconSignal(t.slice(2))
                        })
            })
    }
    Timer { id: trayRetry; interval: 4000; onTriggered: root.trayWaitLoop() }

    function loadTrayHidden() {
        var m = {}
        var s = ""
        try { s = Plasmoid.configuration.hiddenTrayItems || "" } catch (e) { s = "" }
        s.split(",").forEach(x => { if (x) m[x] = true })
        trayHiddenOwn = m
        try { var n = Plasmoid.configuration.maxInlineTray; if (n > 0) maxInline = n } catch (e) {}
        rebuildTrayLists()
    }
    function setMaxInline(n) {
        maxInline = Math.max(1, Math.min(12, n))
        try { Plasmoid.configuration.maxInlineTray = maxInline } catch (e) {}
        rebuildTrayLists()
    }
    function trayIsHidden(id) {
        return !!trayHiddenOwn[id]
    }
    function trayScript(id, hide) {
        return "var id=" + JSON.stringify(id) + ";var hide=" + (hide ? "true" : "false") + ";"
        + "function L(w,k){var v=w.readConfig(k,'');if(typeof v=='string'){v=v?v.split(','):[]}"
        + "return [].concat(v).filter(function(x){return x&&x!=id})}"
        + "var ps=panels();for(var i=0;i<ps.length;i++){var ws=ps[i].widgets();"
        + "for(var j=0;j<ws.length;j++){var w=ws[j];if(w.type=='org.kde.plasma.systemtray'){"
        + "w.currentConfigGroup=['General'];var h=L(w,'hiddenItems'),s=L(w,'shownItems');"
        + "if(hide){h.push(id)}else{s.push(id)}"
        + "w.writeConfig('hiddenItems',h);w.writeConfig('shownItems',s);w.reloadConfig();}}}"
    }
    function setTrayHidden(id, hide) {
        var m = {}
        for (var k in trayHiddenOwn) m[k] = true
            if (hide) m[id] = true
                else delete m[id]
                    trayHiddenOwn = m
                    trayMsg = ""
                    try { Plasmoid.configuration.hiddenTrayItems = Object.keys(m).join(",") } catch (e) { trayMsg = "Could not save the setting" }
                    rebuildTrayLists()
                    sh.run("busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell evaluateScript s " + q(trayScript(id, hide)) + " >/dev/null 2>&1")
    }
    function trayCall(it, method, x, y) {
        sh.run("busctl --user call " + q(it.svc) + " " + q(it.path) + " org.kde.StatusNotifierItem " + method + " ii " + Math.round(x) + " " + Math.round(y))
    }
    function trayActivate(it, x, y) { trayCall(it, "Activate", x, y) }
    function trayMenu(it, x, y) { trayCall(it, "ContextMenu", x, y) }
    function traySecondary(it, x, y) { trayCall(it, "SecondaryActivate", x, y) }

    function trayMenuAvail(it) {
        return !!(it && it.menu && it.menu !== "/NO_DBUSMENU" && it.menu !== "/")
    }
    function trayClick(it, x, y) {
        if (it.isMenu && trayMenuAvail(it)) openTrayMenu(it)
            else trayActivate(it, x, y)
    }
    function trayRightClick(it, x, y) {
        if (trayMenuAvail(it)) {
            openTrayMenu(it)
        } else {
            expanded = false
            trayMenu(it, x, y)
        }
    }
    function menuBase(it) {
        return "call " + q(it.svc) + " " + q(it.menu) + " com.canonical.dbusmenu "
    }
    function mv(p, name, def) {
        return (p && p[name] && p[name].data !== undefined) ? p[name].data : def
    }
    function parseMenuNodes(kids) {
        var res = []
        ;(kids || []).forEach(kid => {
            var d = (kid && kid.data !== undefined) ? kid.data : kid
            var p = d[1]
            var ch = d[2] || []
            if (mv(p, "visible", true) === false) return
                res.push({
                    id: d[0],
                    type: mv(p, "type", "standard"),
                         label: String(mv(p, "label", "")).replace(/__/g, "\u0001").replace(/_/g, "").replace(/\u0001/g, "_"),
                         enabled: mv(p, "enabled", true) !== false,
                         icon: mv(p, "icon-name", ""),
                         toggle: mv(p, "toggle-type", ""),
                         checked: mv(p, "toggle-state", 0) === 1,
                         hasSub: mv(p, "children-display", "") === "submenu" || ch.length > 0,
                         kids: parseMenuNodes(ch)
                })
        })
        return res
    }
    function parseLayout(out) {
        var line = out.split("\n").filter(x => x.trim().charAt(0) === "{").pop()
        var j = JSON.parse(line)
        var lay = j.data.filter(x => Array.isArray(x))[0]
        if (lay && Array.isArray(lay[1])) lay = lay[1]
            return parseMenuNodes(lay[2])
    }
    function openTrayMenu(it) {
        menuItem = it
        menuTitle = it.title
        menuStack = []
        menuNodes = []
        menuError = ""
        menuLoading = true
        page = 9
        expanded = true
        sh.run("busctl --user " + menuBase(it) + "AboutToShow i 0 >/dev/null 2>&1; busctl --user --json=short " + menuBase(it) + "GetLayout iias 0 20 0 2>&1", out => {
            menuLoading = false
            try { menuNodes = parseLayout(out) } catch (e) { menuError = "Could not read this app's menu" }
        })
    }
    function menuEnter(node) {
        var push = kids => {
            menuStack = menuStack.concat([{ title: menuTitle, nodes: menuNodes }])
            menuTitle = node.label
            menuNodes = kids
        }
        if (node.kids.length > 0) { push(node.kids); return }
        sh.run("busctl --user " + menuBase(menuItem) + "AboutToShow i " + node.id + " >/dev/null 2>&1; busctl --user --json=short " + menuBase(menuItem) + "GetLayout iias " + node.id + " 20 0 2>&1", out => {
            try { push(parseLayout(out)) } catch (e) { menuError = "Could not open the submenu" }
        })
    }
    function menuBack() {
        if (menuStack.length === 0) { page = 0; return }
        var top = menuStack[menuStack.length - 1]
        menuStack = menuStack.slice(0, -1)
        menuTitle = top.title
        menuNodes = top.nodes
    }
    function menuClick(node) {
        if (!node.enabled) return
            if (node.hasSub) { menuEnter(node); return }
            sh.run("busctl --user " + menuBase(menuItem) + "Event isvu " + node.id + " clicked i 0 0")
            expanded = false
    }

    // ============ الصوت (PipeWire) ============
    function parseAudioJson(out, isSource, defaultName) {
        var parsed = JSON.parse(out || "[]")
        if (!Array.isArray(parsed)) return []
        return parsed.map(d => {
            var p = d.properties || {}
            var bus = String(p["device.bus"] || "").toLowerCase()
            var api = String(p["device.api"] || "").toLowerCase()
            var node = String(d.name || "")
            var wireless = bus.indexOf("bluetooth") >= 0 || api.indexOf("bluez") >= 0 || node.indexOf("bluez") >= 0 || !!p["api.bluez5.address"]
            var description = String(d.description || p["device.description"] || node || (isSource ? "Audio input" : "Audio output"))
            var detail = wireless ? "Bluetooth · Wireless" : (bus === "usb" ? "USB · Wired" : (bus ? bus.toUpperCase() + " · Wired" : "System audio device"))
            var address = String(p["api.bluez5.address"] || "")
            if (wireless && address) detail += " · " + address
            return { id: String(d.index === undefined ? node : d.index), nodeName: node, name: description, detail: detail, wireless: wireless, def: node === defaultName, state: String(d.state || "") }
        })
    }
    function refreshAudioDevices() {
        sh.run("pactl -f json list sinks 2>/dev/null", out => {
            sh.run("pactl get-default-sink 2>/dev/null", defaultSink => {
                try { sinks = parseAudioJson(out, false, defaultSink.trim()) }
                catch (e) { sinks = [] }
            })
        })
        sh.run("pactl -f json list sources 2>/dev/null", out => {
            sh.run("pactl get-default-source 2>/dev/null", defaultSource => {
                try { sources = parseAudioJson(out, true, defaultSource.trim()).filter(d => !d.nodeName.endsWith(".monitor")) }
                catch (e) { sources = [] }
            })
        })
    }
    function setDefaultAudio(nodeName, isSource) {
        if (!nodeName) return
        sh.run("pactl set-default-" + (isSource ? "source " : "sink ") + q(nodeName), () => {
            refreshAudioDevices(); later.restart()
        })
    }

    Timer {
        interval: 300000
        repeat: true
        running: true
        onTriggered: root.refreshTray()
    }
    Timer {
        interval: root.expanded ? 10000 : 60000
        repeat: true
        running: true
        onTriggered: {
            if (!root) return
                refreshNet()
                refreshBattery()
                refreshVolume()
                if (root.expanded) {
                    Qt.callLater(refresh)
                }
        }
    }
    Timer { id: later; interval: 1200; onTriggered: root.refresh() }

    // ============ أزرار التبديل ============
    function toggleWifi() {
        sh.run("nmcli radio wifi " + (wifiOn ? "off" : "on"), () => later.restart())
    }
    function toggleBt() {
        sh.run("bluetoothctl power " + (btOn ? "off" : "on"), () => later.restart())
    }
    function setAirplane(on) {
        airplane = on
        airplaneGuard = Date.now() + 8000
        airGuardTimer.restart()
        sh.run("kwriteconfig6 --file plasma-try-staterc --group Airplane --key On " + (on ? "true" : "false"))
        if (on) sh.run("nmcli radio wifi off; bluetoothctl power off", () => later.restart())
    }
    function toggleAirplane() { setAirplane(!airplane) }
    function checkAirplane() {
        if (airplane && Date.now() > airplaneGuard && (wifiOn || btOn)) setAirplane(false)
    }
    onWifiOnChanged: checkAirplane()
    onBtOnChanged: checkAirplane()
    Timer { id: airGuardTimer; interval: 8500; onTriggered: root.checkAirplane() }
    function loadAirplane() {
        airplaneGuard = Date.now() + 8000
        airGuardTimer.restart()
        sh.run("kreadconfig6 --file plasma-try-staterc --group Airplane --key On --default false", out => airplane = (out === "true"))
    }
    function toggleMute() {
        sh.run("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", () => later.restart())
    }
    function refreshDnd() {
        sh.run("kreadconfig6 --file plasmanotifyrc --group DoNotDisturb --key NotificationsInhibitedUntil", out => {
            var t = out ? Date.parse(out) : NaN
            dnd = !isNaN(t) && t > Date.now()
        })
    }
    function toggleDnd() {
        var on = !dnd
        dnd = on
        try {
            nmSettings.notificationsInhibitedUntil = on ? new Date(2099, 11, 31, 23, 59, 59) : new Date(2000, 0, 1)
            nmSettings.save()
        } catch (e) {}
        var w = "kwriteconfig6 --file plasmanotifyrc --group DoNotDisturb --key NotificationsInhibitedUntil "
        sh.run(on ? w + "2099-12-31T23:59:59" : w + "--delete", () => {
            try { nmSettings.load() } catch (e) {}
            refreshDnd()
        })
    }

    property string profileMsg: ""
    function profReadCmd() {
        return "busctl get-property " + ppd1 + " ActiveProfile 2>/dev/null"
        + " || busctl get-property " + ppd2 + " ActiveProfile 2>/dev/null"
        + " || powerprofilesctl get 2>/dev/null"
    }
    function setProfile(p) {
        profile = p
        profileMsg = ""
        var gd = "gdbus call --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles"
        + " --method org.freedesktop.DBus.Properties.Set net.hadess.PowerProfiles ActiveProfile \"<'" + p + "'>\""
        var cmd = "powerprofilesctl set " + p + " 2>&1"
        + " || busctl set-property " + ppd1 + " ActiveProfile s " + p + " 2>&1"
        + " || busctl set-property " + ppd2 + " ActiveProfile s " + p + " 2>&1"
        + " || " + gd + " 2>&1"
        sh.run(cmd, (out, err, code) => {
            sh.run(profReadCmd(), o => {
                var m = o.match(/"([a-z-]+)"/)
                var cur = m ? m[1] : o
                if (cur) profile = cur
                    if (cur !== p) {
                        var why = (out || err || "").split("\n")[0]
                        profileMsg = "Could not change mode to '" + profileLabel(p) + "'" + (why ? ": " + why : "")
                    }
            })
        })
    }
    function cycleProfile() {
        if (profiles.length === 0) return
            var i = profiles.indexOf(profile)
            setProfile(profiles[(i + 1) % profiles.length])
    }
    function openProjector() {
        root.expanded = false
        sh.run("busctl --user call org.kde.kscreen /osdService org.kde.kscreen.osdService showActionSelector 2>/dev/null || kcmshell6 kcm_kscreen")
    }

    // ============ شبكات الواي فاي ============
    function refreshWifiList() {
        sh.run("nmcli -t -f TYPE,NAME connection show | grep '^802-11-wireless'", out => {
            var k = []
            out.split("\n").forEach(l => {
                if (l) k.push(l.substring(l.indexOf(":") + 1).replace(/\\:/g, ":"))
            })
            knownWifi = k
            sh.run("nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list", out2 => {
                var map = {}
                out2.split("\n").forEach(line => {
                    if (!line) return
                        var p = line.replace(/\\:/g, "\u0001").split(":")
                        if (p.length < 4) return
                            var ssid = p.slice(3).join(":").replace(/\u0001/g, ":")
                            if (!ssid) return
                                var n = {
                                    ssid: ssid,
                                    signal: parseInt(p[1]) || 0,
                                         secure: p[2] !== "" && p[2] !== "--",
                                         inUse: p[0].trim() === "*",
                                         known: k.indexOf(ssid) >= 0
                                }
                                var o = map[ssid]
                                if (!o || n.inUse || (!o.inUse && n.signal > o.signal)) map[ssid] = n
                })
                var arr = Object.keys(map).map(key => map[key])
                arr.sort((a, b) => (Number(b.inUse) - Number(a.inUse)) || (b.signal - a.signal))
                wifiNetworks = arr
            })
        })
    }
    function rescanWifi() {
        wifiBusy = true
        sh.run("nmcli dev wifi rescan", () => wifiRescanTimer.restart())
    }
    Timer {
        id: wifiRescanTimer
        interval: 2500
        onTriggered: { root.wifiBusy = false; root.refreshWifiList() }
    }
    function connectWifi(n, pw) {
        wifiBusy = true
        wifiMessage = ""
        var cmd
        if (pw) cmd = "nmcli dev wifi connect " + q(n.ssid) + " password " + q(pw)
            else if (n.known) cmd = "nmcli connection up id " + q(n.ssid)
                else cmd = "nmcli dev wifi connect " + q(n.ssid)
                    sh.run(cmd, (out, err, code) => {
                        wifiBusy = false
                        if (code !== 0) wifiMessage = (err || out || "Connection failed").split("\n")[0]
                            else selectedSsid = ""
                                refresh()
                                refreshWifiList()
                    })
    }
    function disconnectWifi(ssid) {
        sh.run("nmcli connection down id " + q(ssid), () => { refresh(); later.restart(); refreshWifiList() })
    }

    // ============ أجهزة البلوتوث ============
    function refreshBt() {
        sh.run("echo '##all'; bluetoothctl devices; echo '##paired'; bluetoothctl devices Paired; echo '##conn'; bluetoothctl devices Connected", out => {
            var sec = ""
            var all = []
            var paired = {}
            var conn = {}
            out.split("\n").forEach(l => {
                if (l.indexOf("##") === 0) { sec = l.substring(2); return }
                var m = l.match(/^Device\s+([0-9A-Fa-f:]{17})\s*(.*)$/)
                if (!m) return
                    if (sec === "all") all.push({ mac: m[1], name: m[2] || m[1] })
                        else if (sec === "paired") paired[m[1]] = true
                            else if (sec === "conn") conn[m[1]] = true
            })
            var res = []
            all.forEach(d => {
                d.paired = !!paired[d.mac]
                d.connected = !!conn[d.mac]
                if (!d.paired && d.name.replace(/-/g, ":").toUpperCase() === d.mac.toUpperCase()) return
                    res.push(d)
            })
            res.sort((a, b) => (Number(b.connected) - Number(a.connected)) || (Number(b.paired) - Number(a.paired)))
            btDevices = res
        })
    }
    function scanBt() {
        btScanning = true
        sh.run("bluetoothctl --timeout 8 scan on", () => { btScanning = false; refreshBt() })
    }
    Timer {
        interval: 2000
        repeat: true
        running: root.btScanning
        onTriggered: root.refreshBt()
    }
    Timer {
        id: audioDeviceRefresh
        interval: 1800
        repeat: false
        onTriggered: root.refreshAudioDevices()
    }
    function btAction(d) {
        btBusy = d.mac
        var cmd
        if (d.connected) cmd = "bluetoothctl disconnect " + d.mac
        else if (d.paired) cmd = "bluetoothctl connect " + d.mac
        else cmd = "bluetoothctl pair " + d.mac + " && bluetoothctl trust " + d.mac + " && bluetoothctl connect " + d.mac
        sh.run(cmd, () => {
            btBusy = ""
            refreshBt()
            refresh()
            audioDeviceRefresh.restart()
        })
    }

    function openPage(i) {
        page = i
        if (i === 1) refreshWifiList()
            else if (i === 2) refreshBt()
                else if (i === 3) refreshProfiles()
                    else if (i === 4) refreshNightStatus()
                        else if (i === 5) refreshShare()
                            else if (i === 6) refreshTray()
                                else if (i === 7) { refreshAudioDevices(); refresh() }
    }

    // ============ الإشعارات ============
    // Do Not Disturb settings only (no notification model, no popups)
    NotificationManager.Settings { id: nmSettings }
}
