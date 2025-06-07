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

    property real mediaTitleFontSize: 24
    property real mediaItemHeight: 50
    property real mediaItemFontSize: 16
    property real mediaSpacing: 6
    property real mediaItemMargin: 30

    Timer {
        id: searchDebounceTimer
        interval: 500
        repeat: false
        onTriggered: {
            console.log("Search query:", searchInput.text, "Playlist ID:", AppState.currentPlaylistId);
            if (searchInput.text !== "Search Songs" && searchInput.text !== "" && AppState.currentPlaylistId !== -1) {
                playlistViewModel.searchSongsInPlaylist(AppState.currentPlaylistId, searchInput.text);
            } else {
                playlistViewModel.playlistModel.searchSongModel.clear();
                errorText.visible = false;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f5f7fa"

        ColumnLayout {
            anchors.fill: parent
            spacing: mediaSpacing * scaleFactor

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
                    onClicked: {
                        console.log("Back button clicked, navigating back");
                        searchInput.text = "Search Songs";
                        playlistViewModel.playlistModel.searchSongModel.clear();
                        errorText.visible = false;
                        NavigationManager.goBack();
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
                        onClicked: searchInput.forceActiveFocus()
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
                            color: "#2d3748"
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
                            onTextChanged: searchDebounceTimer.restart()
                        }
                    }
                }

                HoverButton {
                    Layout.preferredWidth: topControlButtonSize * scaleFactor
                    Layout.preferredHeight: topControlButtonSize * scaleFactor
                    onClicked: {
                        console.log("Add song button clicked, navigating to AddSongView");
                        NavigationManager.navigateTo("qrc:/Songs/View/Client/AddSong.qml");
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

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.8
                Layout.topMargin: mediaSpacing * scaleFactor
                Layout.bottomMargin: mediaSpacing * scaleFactor
                Layout.alignment: Qt.AlignHCenter
                spacing: mediaSpacing * scaleFactor

                Text {
                    id: mediaTitle
                    text: AppState.currentPlaylistName || "Unknown Playlist"
                    font.pixelSize: mediaTitleFontSize * scaleFactor
                    font.family: "Arial"
                    font.weight: Font.Bold
                    color: "#1a202c"
                    Layout.fillWidth: true
                    Layout.leftMargin: mediaItemMargin * scaleFactor
                    Layout.rightMargin: mediaItemMargin * scaleFactor
                }

                ListView {
                    id: mediaFileView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: mediaItemMargin * scaleFactor
                    Layout.rightMargin: mediaItemMargin * scaleFactor
                    clip: true
                    model: searchInput.text !== "Search Songs" && searchInput.text !== "" ? playlistViewModel.playlistModel.searchSongModel : playlistViewModel.playlistModel.pageSongModel

                    delegate: Rectangle {
                        width: mediaFileView.width
                        height: mediaItemHeight * scaleFactor
                        color: mouseArea.containsMouse ? "#f0f0f0" : "#ffffff"
                        border.color: "#d0d7de"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10 * scaleFactor
                            anchors.rightMargin: 10 * scaleFactor
                            spacing: 8 * scaleFactor

                            Text {
                                text: {
                                    if (!model || !model.title || !model.artists) {
                                        return (index + 1) + ". Unknown Song - Unknown Artist";
                                    }
                                    let indexText = searchInput.text !== "Search Songs" && searchInput.text !== "" ? (index + 1) : (playlistViewModel.currentPage * playlistViewModel.itemsPerPage + index + 1);
                                    let artistsText = model.artists.join(", ") || "Unknown Artist";
                                    return indexText + ". " + (model.title || "Unknown Title") + " - " + artistsText;
                                }
                                font.pixelSize: mediaItemFontSize * scaleFactor
                                font.family: "Arial"
                                color: "#2d3748"
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                elide: Text.ElideRight
                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (!model || !model.id || !model.title || !model.artists || !model.file_path) {
                                            console.log("Invalid song data, cannot play. ID:", model ? model.id : "undefined", "Title:", model ? model.title : "undefined", "Artists:", model ? model.artists : "undefined", "File Path:", model ? model.file_path : "undefined");
                                            errorText.text = "Cannot play song: Invalid data";
                                            errorText.visible = true;
                                            return;
                                        }
                                        console.log("Selected song:", model.title, "Artists:", model.artists.join(", "), "ID:", model.id, "File Path:", model.file_path);
                                        AppState.setState({
                                            title: model.title,
                                            artist: model.artists.join(", "),
                                            filePath: model.file_path,
                                            playlistId: AppState.currentPlaylistId
                                        });
                                        songViewModel.playSong(model.id, model.title, model.artists);
                                        NavigationManager.navigateTo("qrc:/Source/View/Client/MediaPlayerView.qml");
                                    }
                                }
                            }

                            HoverButton {
                                Layout.preferredWidth: mediaItemHeight * scaleFactor
                                Layout.preferredHeight: mediaItemHeight * scaleFactor
                                onClicked: {
                                    if (!model || !model.id) {
                                        console.log("Invalid song data, cannot remove");
                                        errorText.text = "Cannot remove song: Invalid data";
                                        errorText.visible = true;
                                        return;
                                    }
                                    console.log("Removing song:", model.title || "Unknown", "ID:", model.id);
                                    playlistViewModel.removeSongFromPlaylist(AppState.currentPlaylistId, model.id);
                                }
                                Image {
                                    source: "qrc:/Assets/delete.png"
                                    width: mediaItemFontSize * scaleFactor
                                    height: mediaItemFontSize * scaleFactor
                                    anchors.centerIn: parent
                                    opacity: parent.hovered ? 1.0 : 0.8
                                }
                            }
                        }
                    }

                    Text {
                        id: noResultsText
                        anchors.centerIn: parent
                        text: searchInput.text !== "Search Songs" && searchInput.text !== "" ? "No search results" : "No songs in this playlist"
                        font.pixelSize: mediaItemFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#2d3748"
                        visible: mediaFileView.count === 0
                    }

                    Text {
                        id: errorText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: noResultsText.bottom
                        anchors.topMargin: mediaSpacing * scaleFactor
                        text: ""
                        font.pixelSize: mediaItemFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#ff0000"
                        visible: false
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20 * scaleFactor
                    visible: playlistViewModel.totalPages > 0 && (searchInput.text === "Search Songs" || searchInput.text === "")

                    HoverButton {
                        text: "Previous"
                        enabled: playlistViewModel.currentPage > 0
                        Layout.preferredWidth: 100 * scaleFactor
                        Layout.preferredHeight: 40 * scaleFactor
                        onClicked: {
                            playlistViewModel.setCurrentPage(playlistViewModel.currentPage - 1);
                            console.log("Previous page, current:", playlistViewModel.currentPage + 1);
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "#ffffff" : "#a0aec0"
                            font.pixelSize: mediaItemFontSize * scaleFactor
                            font.family: "Arial"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: 12 * scaleFactor
                            color: parent.enabled ? (parent.hovered ? "#3182ce" : "#2b6cb0") : "#e2e8f0"
                        }
                    }

                    Text {
                        text: playlistViewModel.totalPages > 0 ? ("Page " + (playlistViewModel.currentPage + 1) + " of " + playlistViewModel.totalPages) : "No pages"
                        font.pixelSize: mediaItemFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#2d3748"
                    }

                    HoverButton {
                        text: "Next"
                        enabled: playlistViewModel.currentPage < playlistViewModel.totalPages - 1
                        Layout.preferredWidth: 100 * scaleFactor
                        Layout.preferredHeight: 40 * scaleFactor
                        onClicked: {
                            playlistViewModel.setCurrentPage(playlistViewModel.currentPage + 1);
                            console.log("Next page, current:", playlistViewModel.currentPage + 1);
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "#ffffff" : "#a0aec0"
                            font.pixelSize: mediaItemFontSize * scaleFactor
                            font.family: "Arial"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: 12 * scaleFactor
                            color: parent.enabled ? (parent.hovered ? "#3182ce" : "#2b6cb0") : "#e2e8f0"
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: playlistViewModel
        function onSongsLoaded(playlistId, songs, message) {
            if (playlistId === AppState.currentPlaylistId) {
                console.log("MediaFileView: Loading songs for playlist ID:", playlistId, "Message:", message);
                AppState.setState({
                    mediaFiles: songs,
                    playlistName: AppState.currentPlaylistName
                });
                errorText.visible = false;
            }
        }

        function onSongAddedToPlaylist(playlistId) {
            if (playlistId === AppState.currentPlaylistId) {
                playlistViewModel.loadSongsInPlaylist(playlistId);
                console.log("MediaFileView: Song added to playlist ID:", playlistId);
            }
        }

        function onSongRemovedFromPlaylist(playlistId, songId) {
            if (playlistId === AppState.currentPlaylistId) {
                playlistViewModel.loadSongsInPlaylist(playlistId);
                console.log("MediaFileView: Song removed from playlist ID:", playlistId, "Song ID:", songId);
            }
        }

        function onSongSearchResultsLoaded(playlistId, songs, message) {
            if (playlistId === AppState.currentPlaylistId) {
                console.log("MediaFileView: Song search results loaded for playlist ID:", playlistId, "Count:", songs.length, "Message:", message);
                errorText.visible = false;
            }
        }

        function onErrorOccurred(error) {
            console.log("MediaFileView: Error:", error);
            errorText.text = error;
            errorText.visible = true;
        }
    }

    Connections {
        target: songViewModel
        function onErrorOccurred(error) {
            console.log("MediaFileView: Song playback error:", error);
            errorText.text = error;
            errorText.visible = true;
        }
    }

    Component.onCompleted: {
        console.log("MediaFileView: Component completed, Playlist ID:", AppState.currentPlaylistId);
        if (AppState.currentPlaylistId !== -1) {
            playlistViewModel.loadSongsInPlaylist(AppState.currentPlaylistId);
        }
    }
}
