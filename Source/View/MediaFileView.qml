import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Components"
import AppState 1.0

Item {
    property real scaleFactor: parent ? Math.min(parent.width / 1024, parent.height / 600) : 1.0

    property real topControlButtonSize: 90
    property real topControlIconSize: 45
    property real topControlSearchHeight: 60
    property real topControlSearchRadius: 12 // Aligned with input field radius
    property real topControlSearchIconSize: 30
    property real topControlSearchFontSize: 22 // Aligned with formFieldFontSize
    property real topControlSpacing: 30
    property real topControlMargin: 18
    property real topControlTopMargin: 20

    property real mediaTitleFontSize: 24
    property real mediaItemHeight: 50
    property real mediaItemFontSize: 16
    property real mediaSpacing: 6
    property real mediaItemMargin: 30

    property int itemsPerPage: 25
    property int currentPage: 0
    property int totalPages: Math.ceil(AppState.currentMediaFiles.length / itemsPerPage)

    FileDialog {
        id: fileDialog
        title: "Select Music Files"
        nameFilters: ["Music files (*.mp3 *.wav *.m4a)"]
        fileMode: FileDialog.OpenFiles
        onAccepted: {
            console.log("Selected files:", fileDialog.selectedFiles);
            let newFiles = [];
            for (let i = 0; i < fileDialog.selectedFiles.length; i++) {
                let songId = 0;
                playlistViewModel.addSongToPlaylist(AppState.currentPlaylistId, songId);
                newFiles.push({
                    id: songId,
                    title: fileDialog.selectedFiles[i].split('/').pop(),
                    artists: ["Unknown Artist"],
                    file_path: fileDialog.selectedFiles[i]
                });
            }
            AppState.setState({
                mediaFiles: newFiles
            });
        }
        onRejected: {
            console.log("File selection canceled");
        }
    }

    function getCurrentPageItems() {
        let startIndex = currentPage * itemsPerPage;
        let endIndex = Math.min(startIndex + itemsPerPage, AppState.currentMediaFiles.length);
        return AppState.currentMediaFiles.slice(startIndex, endIndex);
    }

    Timer {
        id: searchDebounceTimer
        interval: 200
        repeat: false
        onTriggered: {
            console.log("Search query:", searchInput.text);
            if (songViewModel && searchInput.text !== "Search Songs") {
                songViewModel.search(searchInput.text);
            }
        }
    }

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
                    flat: true
                    onClicked: {
                        console.log("Back button clicked, navigating back");
                        NavigationManager.goBack();
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
                            onTextChanged: {
                                searchDebounceTimer.restart();
                            }
                        }
                    }
                }

                HoverButton {
                    Layout.preferredWidth: topControlButtonSize * scaleFactor
                    Layout.preferredHeight: topControlButtonSize * scaleFactor
                    flat: true
                    onClicked: {
                        fileDialog.open();
                        console.log("Add song button clicked");
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
                    text: AppState.currentPlaylistName
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
                    interactive: true
                    cacheBuffer: 2000
                    maximumFlickVelocity: 4000
                    flickDeceleration: 1500

                    model: getCurrentPageItems()

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
                                text: (currentPage * itemsPerPage + index + 1) + ". " + modelData.title + " - " + (modelData.artists ? modelData.artists.join(", ") : "Unknown Artist")
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
                                        AppState.setState({
                                            title: modelData.title,
                                            artist: modelData.artists ? modelData.artists.join(", ") : "Unknown Artist",
                                            filePath: modelData.file_path,
                                            playlistId: AppState.currentPlaylistId
                                        });
                                        songViewModel.playSong(modelData.id, modelData.title, modelData.artists);
                                        NavigationManager.navigateTo("qrc:/Source/View/MediaPlayerView.qml");
                                        console.log("Selected song:", modelData.title, "Artists:", modelData.artists.join(", "), "Playing and navigated to MediaPlayerView");
                                    }
                                }
                            }

                            HoverButton {
                                Layout.preferredWidth: mediaItemHeight * scaleFactor
                                Layout.preferredHeight: mediaItemHeight * scaleFactor
                                flat: true
                                onClicked: {
                                    playlistViewModel.removeSongFromPlaylist(AppState.currentPlaylistId, modelData.id);
                                    console.log("Removed song:", modelData.title, "from playlist ID:", AppState.currentPlaylistId);
                                }
                                background: Rectangle {
                                    color: parent.hovered ? "#e6e9ec" : "transparent"
                                    radius: 10 * scaleFactor
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
                        anchors.centerIn: parent
                        text: "No songs in this playlist"
                        font.pixelSize: mediaItemFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#2d3748"
                        visible: AppState.currentMediaFiles.length === 0
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20 * scaleFactor
                    visible: AppState.currentMediaFiles.length > 0

                    HoverButton {
                        text: "Previous"
                        enabled: currentPage > 0
                        Layout.preferredWidth: 100 * scaleFactor
                        Layout.preferredHeight: 40 * scaleFactor
                        defaultColor: "#2b6cb0"
                        hoverColor: "#3182ce"
                        radius: 12 * scaleFactor
                        font.pixelSize: mediaItemFontSize * scaleFactor
                        font.family: "Arial"
                        onClicked: {
                            currentPage--;
                            mediaFileView.model = getCurrentPageItems();
                            console.log("Previous page, current:", currentPage + 1);
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "#ffffff" : "#a0aec0"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: parent.radius
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: parent.enabled ? (parent.hovered ? "#3182ce" : "#2b6cb0") : "#e2e8f0"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: parent.enabled ? (parent.hovered ? "#2c5282" : "#2a4365") : "#e2e8f0"
                                }
                            }
                        }
                    }

                    Text {
                        text: totalPages > 0 ? ("Page " + (currentPage + 1) + " of " + totalPages) : "No pages"
                        font.pixelSize: mediaItemFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#2d3748"
                    }

                    HoverButton {
                        text: "Next"
                        enabled: currentPage < totalPages - 1
                        Layout.preferredWidth: 100 * scaleFactor
                        Layout.preferredHeight: 40 * scaleFactor
                        defaultColor: "#2b6cb0"
                        hoverColor: "#3182ce"
                        radius: 12 * scaleFactor
                        font.pixelSize: mediaItemFontSize * scaleFactor
                        font.family: "Arial"
                        onClicked: {
                            currentPage++;
                            mediaFileView.model = getCurrentPageItems();
                            console.log("Next page, current:", currentPage + 1);
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "#ffffff" : "#a0aec0"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: parent.radius
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: parent.enabled ? (parent.hovered ? "#3182ce" : "#2b6cb0") : "#e2e8f0"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: parent.enabled ? (parent.hovered ? "#2c5282" : "#2a4365") : "#e2e8f0"
                                }
                            }
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
                AppState.setState({
                    mediaFiles: songs
                });
                console.log("MediaFileView: Loaded songs for playlist ID:", playlistId, "Count:", songs.length, "Message:", message);
            }
        }

        function onSongAddedToPlaylist(playlistId) {
            if (playlistId === AppState.currentPlaylistId) {
                playlistViewModel.loadSongsInPlaylist(playlistId);
                console.log("MediaFileView: Song added to playlist ID:", playlistId);
            }
        }

        function onSongRemovedFromPlaylist(playlistId) {
            if (playlistId === AppState.currentPlaylistId) {
                playlistViewModel.loadSongsInPlaylist(playlistId);
                console.log("MediaFileView: Song removed from playlist ID:", playlistId);
            }
        }

        function onErrorOccurred(error) {
            console.log("MediaFileView: Error:", error);
        }
    }

    Connections {
        target: songViewModel
        function onErrorOccurred(error) {
            console.log("MediaFileView: Song playback error:", error);
        }
    }

    Component.onCompleted: {
        console.log("MediaFileView: Component completed, initial song count:", AppState.currentMediaFiles.length);
        if (AppState.currentPlaylistId !== -1) {
            playlistViewModel.loadSongsInPlaylist(AppState.currentPlaylistId);
        }
    }
}
