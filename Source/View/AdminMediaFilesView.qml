import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./Components"
import AppState 1.0

Item {
    property real scaleFactor: parent ? Math.min(parent.width / 1024, parent.height / 600) : 1.0

    property real topControlButtonSize: 90
    property real topControlIconSize: 45
    property real topControlSearchHeight: 60
    property real topControlSearchRadius: 12
    property real topControlSearchIconSize: 30
    property real topControlSearchFontSize: 22
    property real topControlSpacing: 30
    property real topControlMargin: 18
    property real topControlTopMargin: 20

    property real playlistItemHeight: 50
    property real playlistItemFontSize: 16
    property real playlistItemMargin: 30
    property real playlistSpacing: 6

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#f5f7fa"
            }
            GradientStop {
                position: 1.0
                color: "#e8ecef"
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: function (mouse) {
                searchInput.focus = false;
                mouse.accepted = false;
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: playlistSpacing * scaleFactor

            RowLayout {
                id: topControl
                Layout.topMargin: topControlTopMargin * scaleFactor
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width * 0.8
                Layout.preferredHeight: topControlSearchHeight * scaleFactor
                Layout.alignment: Qt.AlignHCenter
                spacing: topControlSpacing * scaleFactor

                HoverButton {
                    Layout.preferredWidth: topControlButtonSize * scaleFactor
                    Layout.preferredHeight: topControlButtonSize * scaleFactor
                    flat: true
                    onClicked: {
                        NavigationManager.navigateTo("qrc:/Source/View/AdminDashboard.qml");
                        console.log("AdminMediaFiles: Back to AdminDashboardView");
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#e6e9ec" : "transparent"
                        radius: 10 * scaleFactor
                    }
                    Image {
                        source: "qrc:/Assets/back.png"
                        width: topControlIconSize * scaleFactor
                        height: topControlIconSize * scaleFactor
                        anchors.centerIn: parent
                        opacity: parent.hovered ? 1.0 : 0.8
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: topControlSearchHeight * scaleFactor
                    radius: topControlSearchRadius * scaleFactor
                    color: "#f6f8fa"
                    border.color: searchInput.activeFocus ? "#3182ce" : "#d0d7de"
                    border.width: searchInput.activeFocus ? 2 * scaleFactor : 1 * scaleFactor

                    MouseArea {
                        anchors.fill: parent
                        onClicked: function (mouse) {
                            searchInput.forceActiveFocus();
                            mouse.accepted = true;
                        }
                    }

                    RowLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: topControlMargin * scaleFactor
                        spacing: topControlSpacing * scaleFactor

                        Image {
                            source: "qrc:/Assets/search.png"
                            Layout.preferredWidth: topControlSearchIconSize * scaleFactor
                            Layout.preferredHeight: topControlSearchIconSize * scaleFactor
                            opacity: 0.8
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            text: "Search Media"
                            color: "#1a202c"
                            font.pixelSize: topControlSearchFontSize * scaleFactor
                            font.family: "Arial"
                            onActiveFocusChanged: {
                                if (activeFocus && text === "Search Media") {
                                    text = "";
                                }
                            }
                            onFocusChanged: {
                                if (!focus && text === "") {
                                    text = "Search Media";
                                }
                            }
                            onTextChanged: {
                                if (text !== "Search Media" && text) {
                                    console.log("AdminMediaFiles: Search query:", text);
                                    songViewModel.search(text);
                                } else {
                                    songViewModel.fetchAllSongs();
                                    console.log("AdminMediaFiles: Search cleared");
                                }
                            }
                        }
                    }
                }

                HoverButton {
                    Layout.preferredWidth: topControlButtonSize * scaleFactor
                    Layout.preferredHeight: topControlButtonSize * scaleFactor
                    flat: true
                    onClicked: {
                        NavigationManager.navigateTo("qrc:/Source/View/AdminUploadFile.qml");
                        console.log("AdminMediaFiles: Navigate to AdminUploadFileView");
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#e6e9ec" : "transparent"
                        radius: 10 * scaleFactor
                    }
                    Image {
                        source: "qrc:/Assets/add.png"
                        width: topControlIconSize * scaleFactor
                        height: topControlIconSize * scaleFactor
                        anchors.centerIn: parent
                        opacity: parent.hovered ? 1.0 : 0.8
                    }
                }
            }

            ListView {
                id: mediaListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.8
                Layout.topMargin: playlistSpacing * scaleFactor
                Layout.bottomMargin: playlistSpacing * scaleFactor
                Layout.leftMargin: playlistItemMargin * scaleFactor
                Layout.rightMargin: playlistItemMargin * scaleFactor
                Layout.alignment: Qt.AlignHCenter
                clip: true
                interactive: true
                model: songViewModel ? songViewModel.songModel : null
                cacheBuffer: 2000
                maximumFlickVelocity: 4000
                flickDeceleration: 1500

                delegate: Rectangle {
                    width: mediaListView.width
                    height: playlistItemHeight * scaleFactor
                    color: "#ffffff"
                    border.color: "#d0d7de"
                    border.width: 1
                    visible: model && model.title && model.artists

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10 * scaleFactor
                        anchors.rightMargin: 10 * scaleFactor
                        spacing: 8 * scaleFactor

                        Text {
                            text: model ? (index + 1) + ". " + (model.title || "Unknown Title") + " - " + (Array.isArray(model.artists) ? model.artists.join(", ") : model.artists || "Unknown Artist") : ""
                            font.pixelSize: playlistItemFontSize * scaleFactor
                            font.family: "Arial"
                            color: "#1a202c"
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            elide: Text.ElideRight

                            MouseArea {
                                id: textMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                propagateComposedEvents: true
                                onClicked: function (mouse) {
                                    mouse.accepted = false;
                                }
                                onContainsMouseChanged: {
                                    parent.parent.parent.color = containsMouse ? "#f0f0f0" : "#ffffff";
                                }
                            }
                        }

                        HoverButton {
                            Layout.preferredWidth: topControlIconSize * scaleFactor
                            Layout.preferredHeight: topControlIconSize * scaleFactor
                            flat: true
                            z: 1
                            onClicked: {
                                if (model) {
                                    popup.songId = model.id || -1;
                                    popup.songTitle = model.title || "Unknown Title";
                                    popup.songArtists = Array.isArray(model.artists) ? model.artists.join(", ") : model.artists || "Unknown Artist";
                                    popup.songGenres = Array.isArray(model.genres) ? model.genres.join(", ") : model.genres || "";
                                    popup.open();
                                    console.log("AdminMediaFiles: More button clicked for song:", popup.songTitle);
                                }
                            }
                            onHoveredChanged: {
                                console.log("AdminMediaFiles: More button hover:", hovered);
                            }
                            background: Rectangle {
                                color: parent.hovered ? "#e6e9ec" : "transparent"
                                radius: 10 * scaleFactor
                            }
                            Image {
                                source: "qrc:/Assets/more.png"
                                width: topControlIconSize * scaleFactor * 0.6
                                height: topControlIconSize * scaleFactor * 0.6
                                anchors.centerIn: parent
                                opacity: parent.hovered ? 1.0 : 0.8
                            }
                        }
                    }
                }

                Popup {
                    id: popup
                    x: (parent.width - width) / 2
                    y: (parent.height - height) / 2
                    width: 200 * scaleFactor
                    height: 100 * scaleFactor
                    modal: true
                    focus: true
                    background: Rectangle {
                        color: "#ffffff"
                        border.color: "#d0d7de"
                        radius: 8 * scaleFactor
                    }

                    property int songId: -1
                    property string songTitle: ""
                    property string songArtists: ""
                    property string songGenres: ""

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10 * scaleFactor
                        spacing: playlistSpacing * scaleFactor

                        HoverButton {
                            Layout.fillWidth: true
                            text: "Edit"
                            defaultColor: "#2b6cb0"
                            hoverColor: "#3182ce"
                            radius: 12 * scaleFactor
                            font.pixelSize: playlistItemFontSize * scaleFactor
                            font.family: "Arial"
                            onClicked: {
                                editPopup.songId = popup.songId;
                                editPopup.title = popup.songTitle;
                                editPopup.genres = popup.songGenres;
                                editPopup.artists = popup.songArtists;
                                editPopup.open();
                                popup.close();
                                console.log("AdminMediaFiles: Edit clicked for song ID:", popup.songId);
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: parent.radius
                                gradient: Gradient {
                                    GradientStop {
                                        position: 0.0
                                        color: parent.hovered ? "#3182ce" : "#2b6cb0"
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: parent.hovered ? "#2c5282" : "#2a4365"
                                    }
                                }
                            }
                        }

                        HoverButton {
                            Layout.fillWidth: true
                            text: "Delete"
                            defaultColor: "#e53e3e"
                            hoverColor: "#c53030"
                            radius: 12 * scaleFactor
                            font.pixelSize: playlistItemFontSize * scaleFactor
                            font.family: "Arial"
                            onClicked: {
                                adminViewModel.deleteSong(popup.songId);
                                popup.close();
                                console.log("AdminMediaFiles: Delete clicked for song ID:", popup.songId);
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: parent.radius
                                gradient: Gradient {
                                    GradientStop {
                                        position: 0.0
                                        color: parent.hovered ? "#c53030" : "#e53e3e"
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: parent.hovered ? "#9b2c2c" : "#c53030"
                                    }
                                }
                            }
                        }
                    }
                }

                Popup {
                    id: editPopup
                    x: (parent.width - width) / 2
                    y: (parent.height - height) / 2
                    width: 300 * scaleFactor
                    height: 300 * scaleFactor
                    modal: true
                    focus: true
                    background: Rectangle {
                        color: "#ffffff"
                        border.color: "#d0d7de"
                        radius: 12 * scaleFactor
                    }

                    property int songId: -1
                    property string title: ""
                    property string genres: ""
                    property string artists: ""

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20 * scaleFactor
                        spacing: 10 * scaleFactor

                        Text {
                            text: "Edit Song"
                            font.pixelSize: 20 * scaleFactor
                            font.family: "Arial"
                            color: "#1a202c"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        TextField {
                            id: editTitleInput
                            Layout.fillWidth: true
                            text: editPopup.title
                            placeholderText: "Song Title"
                            placeholderTextColor: "#718096"
                            color: "#1a202c"
                            font.pixelSize: 16 * scaleFactor
                            font.family: "Arial"
                            background: Rectangle {
                                color: "#f6f8fa"
                                radius: 8 * scaleFactor
                                border.color: parent.activeFocus ? "#3182ce" : "#d0d7de"
                                border.width: parent.activeFocus ? 2 : 1
                            }
                        }

                        TextField {
                            id: editGenresInput
                            Layout.fillWidth: true
                            text: editPopup.genres
                            placeholderText: "Genres (comma-separated)"
                            placeholderTextColor: "#718096"
                            color: "#1a202c"
                            font.pixelSize: 16 * scaleFactor
                            font.family: "Arial"
                            background: Rectangle {
                                color: "#f6f8fa"
                                radius: 8 * scaleFactor
                                border.color: parent.activeFocus ? "#3182ce" : "#d0d7de"
                                border.width: parent.activeFocus ? 2 : 1
                            }
                        }

                        TextField {
                            id: editArtistsInput
                            Layout.fillWidth: true
                            text: editPopup.artists
                            placeholderText: "Artists (comma-separated)"
                            placeholderTextColor: "#718096"
                            color: "#1a202c"
                            font.pixelSize: 16 * scaleFactor
                            font.family: "Arial"
                            background: Rectangle {
                                color: "#f6f8fa"
                                radius: 8 * scaleFactor
                                border.color: parent.activeFocus ? "#3182ce" : "#d0d7de"
                                border.width: parent.activeFocus ? 2 : 1
                            }
                        }

                        HoverButton {
                            Layout.fillWidth: true
                            text: "Save"
                            defaultColor: "#2b6cb0"
                            hoverColor: "#3182ce"
                            radius: 12 * scaleFactor
                            font.pixelSize: 16 * scaleFactor
                            font.family: "Arial"
                            onClicked: {
                                adminViewModel.updateSong(editPopup.songId, editTitleInput.text, editGenresInput.text, editArtistsInput.text);
                                editPopup.close();
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: parent.radius
                                gradient: Gradient {
                                    GradientStop {
                                        position: 0.0
                                        color: parent.hovered ? "#3182ce" : "#2b6cb0"
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: parent.hovered ? "#2c5282" : "#2a4365"
                                    }
                                }
                            }
                        }
                    }
                }

                Popup {
                    id: notificationPopup
                    x: (parent.width - width) / 2
                    y: (parent.height - height) / 2
                    width: 300 * scaleFactor
                    height: 100 * scaleFactor
                    modal: true
                    focus: true
                    background: Rectangle {
                        color: notificationPopup.notificationColor
                        radius: 8 * scaleFactor
                    }

                    property string message: ""
                    property color notificationColor: "#48bb78"

                    Text {
                        anchors.centerIn: parent
                        text: notificationPopup.message
                        font.pixelSize: 16 * scaleFactor
                        font.family: "Arial"
                        color: "#ffffff"
                        wrapMode: Text.Wrap
                    }

                    Timer {
                        interval: 2000
                        running: notificationPopup.visible
                        onTriggered: notificationPopup.close()
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: songViewModel && songViewModel.songModel && songViewModel.songModel.isLoading ? "Loading..." : "No songs found"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    font.family: "Arial"
                    color: "#1a202c"
                    visible: mediaListView.count === 0 || (songViewModel && songViewModel.songModel && songViewModel.songModel.isLoading)
                }
            }
        }

        Connections {
            target: adminViewModel
            function onUpdateFinished(success, message) {
                notificationPopup.message = message;
                notificationPopup.notificationColor = success ? "#48bb78" : "#e53e3e";
                notificationPopup.open();
                if (success) {
                    songViewModel.fetchAllSongs();
                }
                console.log("AdminMediaFiles: Update finished, success:", success, "message:", message);
            }

            function onDeleteFinished(success, message) {
                notificationPopup.message = message;
                notificationPopup.notificationColor = success ? "#48bb78" : "#e53e3e";
                notificationPopup.open();
                if (success) {
                    songViewModel.fetchAllSongs();
                }
                console.log("AdminMediaFiles: Delete finished, success:", success, "message:", message);
            }
        }

        Component.onCompleted: {
            songViewModel.fetchAllSongs();
            console.log("AdminMediaFilesView: Component completed at", new Date().toLocaleString(Qt.locale(), ""));
        }
    }
}
