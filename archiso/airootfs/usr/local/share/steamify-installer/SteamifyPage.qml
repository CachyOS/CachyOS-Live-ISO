// Steamify's page in Calamares (packagechooserq@steamifypage, method legacy),
// styled like the rest of CachyOS's installer: its palette, standard
// controls, CachyOS's turquoise for the selected row. Left the options,
// right what the selected (or hovered) one does.
// The rows come from Steamify itself: calamares-online.sh writes
// ../steamify/qml/Items.qml from `steamify.sh --defaults --list` (the newest
// Steamify, else the ISO's), so new options show up without a new ISO; the
// explanations are the app's (Texts.qml, same folder).
// The choice goes to Calamares' global storage as packagechooser_steamifypage:
// the ids that are on, comma-separated, plus "boot" for Boot into Desktop
// ("none" when nothing is on); steamify-install passes it to
// `steamify.sh --defaults --options ... --boot ...`.
import io.calamares.core 1.0
import io.calamares.ui 1.0
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../steamify/qml"

Item {
    id: page
    width: parent.width
    height: parent.height

    SystemPalette { id: pal; colorGroup: SystemPalette.Active }
    readonly property color accent: "#00CED1"

    // Only what can be set up here (Steamify leaves out the rest).
    readonly property var rows: Items.rows.filter(function (r) { return r.selectable; })
    property var want: ({})
    property string boot: "gamescope"
    property int sel: 0

    function label(r) { return (Texts.items[r.id] || {}).label || r.label; }
    function hint(r) { return (Texts.items[r.id] || {}).hint || r.hint; }
    function shown(r) { return !r.parent || !!want[r.parent]; }

    // Steamify's own rules: a sub-option needs its parent (turning a parent
    // off turns its sub-options off); single user mode needs the conversion.
    function toggle(id) {
        var w = Object.assign({}, want);
        w[id] = !w[id];
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            if (w[id] && r.id === id && r.parent) w[r.parent] = true;
            if (!w[id] && r.parent === id && r.kind === "toggle") w[r.id] = false;
            if (w[id] && r.parent === id && r.kind === "toggle") w[r.id] = true;   // opt-out sub-options
        }
        if (id === "single" && w.single) w.gaming = true;
        if (id === "gaming" && !w.gaming) { w.single = false; boot = "gamescope"; }
        want = w;
    }

    function choice() {
        var on = [];
        for (var i = 0; i < rows.length; i++)
            if (rows[i].kind === "toggle" && want[rows[i].id]) on.push(rows[i].id);
        if (want.gaming && boot === "desktop") on.push("boot");
        return on.length ? on.join(",") : "none";
    }
    onWantChanged: config.packageChoice = choice()
    onBootChanged: config.packageChoice = choice()
    Component.onCompleted: {
        // Preselected like Steamify's first run.
        var w = {};
        for (var i = 0; i < rows.length; i++) if (rows[i].kind === "toggle") w[rows[i].id] = rows[i].on;
        want = w;
        config.packageChoice = choice();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Label {
            Layout.fillWidth: true
            text: "Steamify sets up the SteamOS experience while CachyOS installs. Everything can be changed later with the Steamify app."
            wrapMode: Text.WordWrap
            color: pal.windowText
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            ListView {
                id: list
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 55
                clip: true
                spacing: 4
                boundsBehavior: Flickable.StopAtBounds
                model: page.rows
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property var it: modelData
                    readonly property bool vis: page.shown(it)
                    readonly property bool selected: vis && index === page.sel
                    width: list.width - 12
                    height: vis ? 52 : 0
                    visible: vis
                    radius: 4
                    color: selected ? Qt.rgba(page.accent.r, page.accent.g, page.accent.b, 0.18) : pal.base
                    border.width: 1
                    border.color: selected ? page.accent : Qt.rgba(pal.windowText.r, pal.windowText.g, pal.windowText.b, 0.15)

                    MouseArea {
                        anchors.fill: parent; hoverEnabled: true
                        // Hovering explains a row too, like selecting it.
                        onEntered: page.sel = row.index
                        onClicked: { page.sel = row.index; if (row.it.kind === "toggle") page.toggle(row.it.id); }
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: row.it.parent ? 32 : 12
                        anchors.rightMargin: 12
                        spacing: 12
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Label { Layout.fillWidth: true; text: page.label(row.it); font.bold: true; elide: Text.ElideRight; color: pal.text }
                            Label { Layout.fillWidth: true; text: page.hint(row.it); elide: Text.ElideRight; color: pal.text; opacity: 0.7; font.pointSize: 8.5 }
                        }
                        Switch {
                            visible: row.it.kind === "toggle"
                            checked: !!page.want[row.it.id]
                            onToggled: { page.sel = row.index; page.toggle(row.it.id); }
                        }
                        RowLayout {
                            visible: row.it.kind === "choice"
                            spacing: 4
                            RadioButton { text: "Gaming mode"; checked: page.boot === "gamescope"
                                          onClicked: { page.sel = row.index; page.boot = "gamescope"; } }
                            RadioButton { text: "Desktop"; checked: page.boot === "desktop"
                                          onClicked: { page.sel = row.index; page.boot = "desktop"; } }
                        }
                    }
                }
            }

            // What the selected (or hovered) option does.
            Rectangle {
                id: detail
                readonly property var it: page.rows[page.sel] || ({})
                readonly property var tx: Texts.items[it.id] || ({})
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 45
                radius: 4
                color: pal.base
                border.width: 1
                border.color: Qt.rgba(pal.windowText.r, pal.windowText.g, pal.windowText.b, 0.15)
                onItChanged: flick.contentY = 0

                Flickable {
                    id: flick
                    anchors.fill: parent
                    anchors.margins: 16
                    clip: true
                    contentHeight: col.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ColumnLayout {
                        id: col
                        width: flick.width - 12
                        spacing: 10
                        Label { Layout.fillWidth: true; text: detail.it.id ? page.label(detail.it) : ""; font.bold: true; font.pointSize: 13
                                wrapMode: Text.WordWrap; color: pal.text }
                        Label { Layout.fillWidth: true; text: detail.tx.body || page.hint(detail.it) || ""; wrapMode: Text.WordWrap; color: pal.text }
                        Label { visible: (detail.tx.changes || []).length > 0; text: "What it changes"; font.bold: true; color: pal.text; topPadding: 4 }
                        Repeater {
                            model: detail.tx.changes || []
                            Label { required property string modelData; Layout.fillWidth: true; text: "•  " + modelData
                                    wrapMode: Text.WordWrap; color: pal.text }
                        }
                    }
                }
            }
        }
    }
}
