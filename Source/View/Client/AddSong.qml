import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Components"
import "../Helper"
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
    property real playlistItemHeightMargin: 30
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
                        NavigationManager.goBack();
                        console.log("AddSong: Back to MediaFileView");
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
                            text: "Search Songs"
                            color: "#1a202c"
                            font.pixelSize: topControlSearchFontSize * scaleFactor
                            font.family: "Arial"
                            onActiveFocusChanged: {
                                if (activeFocus && text === "Search Songs") {
                                    text = "";
                                }
                            }
                            onFocusChanged: {
                                if (!focus && text === "") {
                                    text = "Search Songs";
                                }
                            }
                            onTextChanged: {
                                if (text !== "Search Songs" && text) {
                                    console.log("AddSong: Search query:", text);
                                    songViewModel.search(text);
                                } else {
                                    songViewModel.fetchAllSongs();
                                    console.log("AddSong: Search cleared");
                                }
                            }
                        }
                    }
                }
            }

            ListView {
                id: songListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.8
                Layout.topMargin: playlistSpacing * scaleFactor
                Layout.bottomMargin: playlistSpacing * scaleFactor
                Layout.leftMargin: playlistItemHeightMargin * scaleFactor
                Layout.rightMargin: playlistItemHeightMargin * scaleFactor
                Layout.alignment: Qt.AlignHCenter
                clip: true
                interactive: true
                model: songViewModel ? songViewModel.songModel : null
                cacheBuffer: 2000
                maximumFlickVelocity: 4000
                flickDeceleration: 1500

                delegate: Rectangle {
                    width: songListView.width
                    height: playlistItemHeight * scaleFactor
                    color: "#ffffff"
                    border.color: "#d0d7de"
                    border.width: 1
                    visible: model && model.title
                    Component.onCompleted: console.log("Delegate created for song:", model ? model.title : "undefined")

                    Rectangle {
                        id: hoverBackground
                        anchors.fill: parent
                        color: textMouseArea.containsMouse ? "#f0f0f0" : "transparent"
                        z: -1
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10 * scaleFactor
                        anchors.rightMargin: 10 * scaleFactor
                        spacing: 8 * scaleFactor

                        Text {
                            text: model ? (index + 1) + ". " + (model.title || "Unknown Title") + " - " + (Array.isArray(model.artists) && model.artists.length > 0 ? model.artists.join(", ") : model.artists || "Unknown Artist") + " - " + (Array.isArray(model.genres) && model.genres.length > 0 ? model.genres.join(", ") : model.genres || "Unknown Genre") : ""
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
                            }
                        }

                        HoverButton {
                            Layout.preferredWidth: topControlIconSize * scaleFactor
                            Layout.preferredHeight: topControlIconSize * scaleFactor
                            flat: true
                            onClicked: {
                                if (model && AppState.currentPlaylistId !== -1) {
                                    console.log("AddSong: Adding song to playlist - ID:", model.id, "Title:", model.title, "Playlist ID:", AppState.currentPlaylistId);
                                    playlistViewModel.addSongToPlaylist(AppState.currentPlaylistId, model.id);
                                } else {
                                    console.log("AddSong: Invalid playlist ID or model data");
                                    notificationPopup.message = "Cannot add song: Invalid playlist or song data";
                                    notificationPopup.notificationColor = "#e53e3e";
                                    notificationPopup.open();
                                }
                            }
                            background: Rectangle {
                                color: parent.hovered ? "#e6e9ec" : "transparent"
                                radius: 10 * scaleFactor
                            }
                            Image {
                                source: "qrc:/Assets/add.png"
                                width: topControlIconSize * scaleFactor * 0.6
                                height: topControlIconSize * scaleFactor * 0.6
                                anchors.centerIn: parent
                                opacity: client.hovered ? 1.0 : 0.8
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: songViewModel && songViewModel.songModel && songViewModel.songModel.isLoading ? "Loading..." : "No songs found"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    font.family: "Arial"
                    color: "#1a202c"
                    visible: songListView.count === 0 || (songViewModel && songViewModel.songModel && songViewModel.songModel.isLoading)
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
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: parent.width - 20 * scaleFactor
            }

            Timer {
                interval: 2000
                running: notificationPopup.visible
                onTriggered: notificationPopup.close()
            }
        }

        Connections {
            target: playlistViewModel
            function onSongAddedToPlaylist(playlistId) {
                if (playlistId === AppState.currentPlaylistId) {
                    notificationPopup.message = "Song added to playlist successfully";
                    notificationPopup.notificationColor = "#48bb78";
                    notificationPopup.open();
                    console.log("AddSong: Song added to playlist ID:", playlistId);
                }
            }

            function onErrorOccurred(error) {
                notificationPopup.notificationColor = "#e53e3e";
                if (error.includes("Song is already in the playlist")) {
                    notificationPopup.message = "Song is already in the playlist";
                } else {
                    notificationPopup.message = error || "Failed to add song to playlist";
                }
                notificationPopup.open();
                console.log("AddSong: Error:", error);
            }
        }

        Connections {
            target: songViewModel
            function onErrorOccurred(error) {
                notificationPopup.message = error || "Failed to load songs";
                notificationPopup.notificationColor = "#e53e3e";
                notificationPopup.open();
                console.log("AddSong: SongViewModel error:", error);
            }
        }

        Component.onCompleted: {
            songViewModel.fetchAllSongs();
            console.log("AddSongView: Component completed at", new Date().toLocaleString(Qt.locale(), ""));
        }
    }
}
