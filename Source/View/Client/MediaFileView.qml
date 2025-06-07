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

    property int itemsPerPage: 25
    property int currentPage: 0
    property int totalPages: {
        let files = AppState.currentMediaFiles;
        return Math.ceil((files && typeof files.length === 'number' ? files.length : 0) / itemsPerPage);
    }

    function getCurrentPageItems() {
        let files = AppState.currentMediaFiles;
        if (!files || typeof files.length !== 'number') {
            console.log("MediaFileView: currentMediaFiles is invalid or not array-like:", files);
            return [];
        }
        if (files.length === 0) {
            console.log("MediaFileView: currentMediaFiles is empty");
            return [];
        }
        let startIndex = currentPage * itemsPerPage;
        let endIndex = Math.min(startIndex + itemsPerPage, files.length);
        console.log("MediaFileView: getCurrentPageItems - startIndex:", startIndex, "endIndex:", endIndex, "total:", files.length);
        let jsArray = [];
        for (let i = 0; i < files.length; i++) {
            jsArray.push(files[i]);
        }
        return jsArray.slice(startIndex, endIndex);
    }

    Timer {
        id: searchDebounceTimer
        interval: 200
        repeat: false
        onTriggered: {
            console.log("Search query:", searchInput.text, "Playlist ID:", AppState.currentPlaylistId);
            if (searchInput.text !== "Search Songs" && searchInput.text !== "" && AppState.currentPlaylistId !== -1) {
                playlistViewModel.searchSongsInPlaylist(AppState.currentPlaylistId, searchInput.text);
            } else {
                songSearchResultsModel.clear();
                mediaFileView.model = getCurrentPageItems();
                errorText.visible = false;
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
                        songSearchResultsModel.clear();
                        searchInput.text = "Search Songs";
                        errorText.visible = false;
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
                        console.log("Add song button clicked, navigating to AddSongView");
                        NavigationManager.navigateTo("qrc:/Songs/View/Client/AddSong.qml");
                    }
                    background: Rectangle {
                        color: "transparent"
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

                ListModel {
                    id: songSearchResultsModel
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
                    model: searchInput.text !== "Search Songs" && searchInput.text !== "" ? songSearchResultsModel : getCurrentPageItems()

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
                                    let songData = (searchInput.text !== "Search Songs" && searchInput.text !== "") ? model : modelData;
                                    if (!songData) {
                                        console.log("MediaFileView: songData is undefined, index:", index);
                                        return (index + 1) + ". Unknown Title - Unknown Artist";
                                    }
                                    let indexText = (searchInput.text !== "Search Songs" && searchInput.text !== "") ? (index + 1) : (currentPage * itemsPerPage + index + 1);
                                    let title = songData.title || "Unknown Title";
                                    let artists = songData.artists || ["Unknown Artist"];
                                    let artistsText = "Unknown Artist";

                                    // Đồng bộ xử lý artists cho cả search và non-search
                                    if (typeof artists === "string") {
                                        // Xử lý trường hợp artists là chuỗi (e.g., "Dangrangto,PUPPY")
                                        console.log("MediaFileView: Artists is string, splitting:", artists);
                                        artists = artists.split(",").map(a => a.trim()).filter(a => a.length > 0);
                                        if (artists.length === 0) {
                                            artists = ["Unknown Artist"];
                                        }
                                    } else if (Array.isArray(artists) || artists instanceof Array) {
                                        // Xử lý mảng, bao gồm nested arrays
                                        if (artists.length > 0 && (Array.isArray(artists[0]) || artists[0] instanceof Array)) {
                                            console.log("MediaFileView: Detected nested artists array, flattening:", JSON.stringify(artists));
                                            artists = artists[0];
                                        }
                                        // Xử lý trường hợp mảng chứa chuỗi đơn (e.g., ["Dangrangto,PUPPY"])
                                        if (artists.length === 1 && typeof artists[0] === "string" && artists[0].includes(",")) {
                                            console.log("MediaFileView: Single string array with comma, splitting:", artists[0]);
                                            artists = artists[0].split(",").map(a => a.trim()).filter(a => a.length > 0);
                                        }
                                        if (artists.length === 0) {
                                            artists = ["Unknown Artist"];
                                        }
                                    } else {
                                        console.log("MediaFileView: Invalid artists type:", typeof artists, JSON.stringify(artists));
                                        artists = ["Unknown Artist"];
                                    }

                                    artistsText = artists.join(", ");
                                    console.log("MediaFileView: Song:", title, "Artists:", artistsText, "Raw artists:", JSON.stringify(artists));
                                    return indexText + ". " + title + " - " + artistsText;
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
                                        let songData = (searchInput.text !== "Search Songs" && searchInput.text !== "") ? model : modelData;
                                        if (!songData) {
                                            console.log("MediaFileView: Cannot play song, songData is undefined");
                                            errorText.text = "Cannot play song: Invalid data";
                                            errorText.visible = true;
                                            return;
                                        }
                                        let artists = songData.artists || ["Unknown Artist"];
                                        // Đồng bộ xử lý artists
                                        if (typeof artists === "string") {
                                            console.log("MediaFileView: Artists is string for playback, splitting:", artists);
                                            artists = artists.split(",").map(a => a.trim()).filter(a => a.length > 0);
                                            if (artists.length === 0) {
                                                artists = ["Unknown Artist"];
                                            }
                                        } else if (Array.isArray(artists) && artists.length > 0 && (Array.isArray(artists[0]) || artists[0] instanceof Array)) {
                                            console.log("MediaFileView: Flattening nested artists for playback:", JSON.stringify(artists));
                                            artists = artists[0];
                                        } else if (Array.isArray(artists) && artists.length === 1 && typeof artists[0] === "string" && artists[0].includes(",")) {
                                            console.log("MediaFileView: Single string array with comma for playback, splitting:", artists[0]);
                                            artists = artists[0].split(",").map(a => a.trim()).filter(a => a.length > 0);
                                        } else if (!Array.isArray(artists)) {
                                            console.log("MediaFileView: Invalid artists type for playback:", typeof artists, JSON.stringify(artists));
                                            artists = ["Unknown Artist"];
                                        }
                                        AppState.setState({
                                            title: songData.title || "Unknown Title",
                                            artist: artists.length > 0 ? artists.join(", ") : "Unknown Artist",
                                            filePath: songData.file_path || "",
                                            playlistId: AppState.currentPlaylistId
                                        });
                                        songViewModel.playSong(songData.id, songData.title || "Unknown Title", artists);
                                        NavigationManager.navigateTo("qrc:/Songs/View/Client/MediaPlayerView.qml");
                                        console.log("Selected song:", songData.title || "Unknown Title", "Artists:", artists.join(", "), "Playing and navigated to MediaPlayerView");
                                    }
                                }
                            }

                            HoverButton {
                                Layout.preferredWidth: mediaItemHeight * scaleFactor
                                Layout.preferredHeight: mediaItemHeight * scaleFactor
                                flat: true
                                onClicked: {
                                    let songData = (searchInput.text !== "Search Songs" && searchInput.text !== "") ? model : modelData;
                                    if (!songData) {
                                        console.log("MediaFileView: Cannot remove song, songData is undefined");
                                        errorText.text = "Cannot remove song: Invalid data";
                                        errorText.visible = true;
                                        return;
                                    }
                                    playlistViewModel.removeSongFromPlaylist(AppState.currentPlaylistId, songData.id);
                                    console.log("Removed song:", songData.title || "Unknown Title", "from playlist ID:", AppState.currentPlaylistId);
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
                        id: noResultsText
                        anchors.centerIn: parent
                        text: searchInput.text !== "Search Songs" && searchInput.text !== "" ? "No search results" : "No songs in this playlist"
                        font.pixelSize: mediaItemFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#2d3748"
                        visible: mediaFileView.count === 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
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
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
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
                    visible: {
                        let files = AppState.currentMediaFiles;
                        return files && typeof files.length === 'number' && files.length > 0 && (searchInput.text === "Search Songs" || searchInput.text === "");
                    }

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
                console.log("MediaFileView: Loading songs for playlist ID:", playlistId, "Song count:", songs.length, "Message:", message);
                console.log("MediaFileView: Songs data:", JSON.stringify(songs));
                AppState.setState({
                    mediaFiles: songs,
                    playlistName: AppState.currentPlaylistName
                });
                console.log("MediaFileView: currentMediaFiles structure:", JSON.stringify(AppState.currentMediaFiles));
                totalPages = Math.ceil((AppState.currentMediaFiles && typeof AppState.currentMediaFiles.length === 'number' ? AppState.currentMediaFiles.length : 0) / itemsPerPage);
                currentPage = 0;
                mediaFileView.model = getCurrentPageItems();
                errorText.visible = false;
                console.log("MediaFileView: Loaded songs for playlist ID:", playlistId, "Count:", songs.length, "Message:", message);
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
                if (searchInput.text !== "Search Songs" && searchInput.text !== "") {
                    for (var i = 0; i < songSearchResultsModel.count; i++) {
                        if (songSearchResultsModel.get(i).id === songId) {
                            songSearchResultsModel.remove(i);
                            break;
                        }
                    }
                }
                let files = AppState.currentMediaFiles;
                let updatedMediaFiles = [];
                for (let j = 0; j < files.length; j++) {
                    if (files[j].id !== songId) {
                        updatedMediaFiles.push(files[j]);
                    }
                }
                AppState.setState({
                    mediaFiles: updatedMediaFiles
                });
                console.log("MediaFileView: Updated currentMediaFiles structure:", JSON.stringify(AppState.currentMediaFiles));
                totalPages = Math.ceil((AppState.currentMediaFiles && typeof AppState.currentMediaFiles.length === 'number' ? AppState.currentMediaFiles.length : 0) / itemsPerPage);
                if (currentPage >= totalPages && totalPages > 0) {
                    currentPage = totalPages - 1;
                } else if (totalPages === 0) {
                    currentPage = 0;
                }
                mediaFileView.model = getCurrentPageItems();
                console.log("MediaFileView: Song removed from playlist ID:", playlistId, "Song ID:", songId, "Updated song count:", AppState.currentMediaFiles.length);
            }
        }

        function onSongSearchResultsLoaded(playlistId, songs, message) {
            if (playlistId === AppState.currentPlaylistId) {
                console.log("MediaFileView: Song search results loaded for playlist ID:", playlistId, "Count:", songs.length, "Message:", message);
                console.log("MediaFileView: Search songs data:", JSON.stringify(songs));
                songSearchResultsModel.clear();
                for (var i = 0; i < songs.length; i++) {
                    let artists = songs[i].artists || ["Unknown Artist"];
                    // Đồng bộ xử lý artists giống non-search mode
                    if (typeof artists === "string") {
                        // Xử lý trường hợp artists là chuỗi (e.g., "Dangrangto,PUPPY")
                        console.log("MediaFileView: Search artists is string, splitting:", artists);
                        artists = artists.split(",").map(a => a.trim()).filter(a => a.length > 0);
                        if (artists.length === 0) {
                            artists = ["Unknown Artist"];
                        }
                    } else if (Array.isArray(artists) || artists instanceof Array) {
                        // Xử lý mảng, bao gồm nested arrays và chuỗi đơn
                        if (artists.length > 0 && (Array.isArray(artists[0]) || artists[0] instanceof Array)) {
                            console.log("MediaFileView: Search flattening nested artists array:", JSON.stringify(artists));
                            artists = artists[0];
                        }
                        if (artists.length === 1 && typeof artists[0] === "string" && artists[0].includes(",")) {
                            console.log("MediaFileView: Search single string array with comma, splitting:", artists[0]);
                            artists = artists[0].split(",").map(a => a.trim()).filter(a => a.length > 0);
                        }
                        if (artists.length === 0) {
                            artists = ["Unknown Artist"];
                        }
                    } else {
                        console.log("MediaFileView: Search invalid artists type, converting:", typeof artists, JSON.stringify(artists));
                        artists = ["Unknown Artist"];
                    }
                    console.log("MediaFileView: Appending song", songs[i].title, "with artists:", JSON.stringify(artists));
                    songSearchResultsModel.append({
                        id: songs[i].id || 0,
                        title: songs[i].title || "Unknown Title",
                        artists: artists,
                        file_path: songs[i].file_path || "",
                        genres: Array.isArray(songs[i].genres) ? songs[i].genres : []
                    });
                }
                mediaFileView.model = (searchInput.text !== "Search Songs" && searchInput.text !== "") ? songSearchResultsModel : getCurrentPageItems();
                errorText.visible = false;
                console.log("MediaFileView: Updated songSearchResultsModel, count:", songSearchResultsModel.count);
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

    Binding {
        target: mediaFileView
        property: "model"
        value: searchInput.text !== "Search Songs" && searchInput.text !== "" ? songSearchResultsModel : getCurrentPageItems()
        when: AppState.currentMediaFilesChanged || searchInput.textChanged
    }

    Component.onCompleted: {
        console.log("MediaFileView: Component completed, initial song count:", AppState.currentMediaFiles && typeof AppState.currentMediaFiles.length === 'number' ? AppState.currentMediaFiles.length : 0, "Playlist ID:", AppState.currentPlaylistId);
        console.log("MediaFileView: Initial currentMediaFiles:", JSON.stringify(AppState.currentMediaFiles));
        if (AppState.currentPlaylistId !== -1 && (!AppState.currentMediaFiles || typeof AppState.currentMediaFiles.length !== 'number' || AppState.currentMediaFiles.length === 0)) {
            playlistViewModel.loadSongsInPlaylist(AppState.currentPlaylistId);
        }
    }
}
