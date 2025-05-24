import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtMultimedia
import "Components"
import AppState 1.0

Item {
    readonly property real scaleFactor: Math.min(parent.width / 1024, parent.height / 600)

    property real topControlButtonSize: 90
    property real topControlIconSize: 45
    property real topControlSearchHeight: 60
    property real topControlSearchRadius: 12 // Changed to match input field radius
    property real topControlSearchIconSize: 30
    property real topControlSearchFontSize: 22 // Aligned with formFieldFontSize
    property real topControlSpacing: 30
    property real topControlMargin: 18

    property real songInfoTitleSize: 44
    property real songInfoArtistSize: 36
    property real songInfoTimeSize: 34
    property real songInfoSpacing: 20

    property real controlButtonSize: 60
    property real controlIconSize: 24
    property real controlPlayIconSize: 30
    property real controlSpacing: 30

    property real volumeIconSize: 24
    property real volumeSliderWidth: 100
    property real volumeSliderHeight: 24
    property real volumeSpacing: 8

    property real searchResultMaxHeight: 300
    property real searchResultItemHeight: 40
    property real searchResultFontSize: 16
    property real searchResultMargin: 10

    property bool shuffle: false
    property int repeatMode: 0 // 0: No repeat, 1: Repeat one, 2: Repeat all
    property bool muted: false
    property real previousVolume: 0.5
    property bool isSearching: false
    property bool allSongsLoaded: false

    function formatDuration(milliseconds) {
        if (!milliseconds || milliseconds < 0 || isNaN(milliseconds)) {
            return "0:00";
        }
        let seconds = Math.floor(milliseconds / 1000);
        let minutes = Math.floor(seconds / 60);
        let secs = Math.floor(seconds % 60);
        return minutes + ":" + (secs < 10 ? "0" : "") + secs;
    }

    function normalizeString(str) {
        return str.trim().replace(/\s+/g, " ");
    }

    function findCurrentSongIndex(songList) {
        if (songList.length === 0 || !AppState.currentMediaTitle) {
            console.log("Song list empty or no current song");
            return 0;
        }
        let normalizedTitle = normalizeString(AppState.currentMediaTitle);
        let normalizedArtist = normalizeString(AppState.currentMediaArtist);
        for (let i = 0; i < songList.length; i++) {
            let song = songList[i];
            let songTitle = normalizeString(song.title);
            let songArtists = normalizeString(song.artists ? song.artists.join(", ") : "Unknown Artist");
            if (songTitle === normalizedTitle && songArtists === normalizedArtist) {
                return i;
            }
        }
        console.log("Current song not found in list, defaulting to index 0");
        return 0;
    }

    function playSongAtIndex(songList, index) {
        if (index < 0 || index >= songList.length) {
            console.log("Invalid song index:", index);
            return;
        }
        let song = songList[index];
        let artistsStr = song.artists ? song.artists.join(", ") : "Unknown Artist";
        AppState.setState({
            title: song.title,
            artist: artistsStr,
            filePath: song.file_path,
            playlistId: AppState.currentPlaylistId
        });
        songViewModel.playSong(song.id, song.title, song.artists);
        console.log("Playing song at index:", index, "Title:", song.title, "Artists:", artistsStr);
    }

    function getAllSongsFromModel() {
        let songs = [];
        if (songViewModel && songViewModel.songModel && allSongsLoaded) {
            for (let i = 0; i < songViewModel.songModel.rowCount(); i++) {
                let index = songViewModel.songModel.index(i, 0);
                songs.push({
                    id: songViewModel.songModel.data(index, songViewModel.songModel.IdRole),
                    title: songViewModel.songModel.data(index, songViewModel.songModel.TitleRole),
                    artists: songViewModel.songModel.data(index, songViewModel.songModel.ArtistsRole),
                    file_path: songViewModel.songModel.data(index, songViewModel.songModel.FilePathRole),
                    genres: songViewModel.songModel.data(index, songViewModel.songModel.GenresRole)
                });
            }
        }
        return songs;
    }

    function handleNext() {
        let songList = AppState.currentPlaylistId !== -1 ? AppState.currentMediaFiles : getAllSongsFromModel();
        if (songList.length === 0) {
            console.log("No songs available to play");
            return;
        }

        let currentIndex = findCurrentSongIndex(songList);
        if (repeatMode === 1) {
            playSongAtIndex(songList, currentIndex);
        } else {
            let nextIndex;
            if (shuffle) {
                nextIndex = Math.floor(Math.random() * songList.length);
                while (nextIndex === currentIndex && songList.length > 1) {
                    nextIndex = Math.floor(Math.random() * songList.length);
                }
            } else {
                nextIndex = currentIndex + 1;
                if (nextIndex >= songList.length) {
                    if (repeatMode === 2) {
                        nextIndex = 0;
                    } else {
                        console.log("Reached end of song list, stopping");
                        return;
                    }
                }
            }
            playSongAtIndex(songList, nextIndex);
        }
    }

    function handlePrevious() {
        let songList = AppState.currentPlaylistId !== -1 ? AppState.currentMediaFiles : getAllSongsFromModel();
        if (songList.length === 0) {
            console.log("No songs available to play");
            return;
        }

        let currentIndex = findCurrentSongIndex(songList);
        if (repeatMode === 1) {
            playSongAtIndex(songList, currentIndex);
        } else {
            let prevIndex;
            if (shuffle) {
                prevIndex = Math.floor(Math.random() * songList.length);
                while (prevIndex === currentIndex && songList.length > 1) {
                    prevIndex = Math.floor(Math.random() * songList.length);
                }
            } else {
                prevIndex = currentIndex - 1;
                if (prevIndex < 0) {
                    if (repeatMode === 2) {
                        prevIndex = songList.length - 1;
                    } else {
                        console.log("Reached start of song list, stopping");
                        return;
                    }
                }
            }
            playSongAtIndex(songList, prevIndex);
        }
    }

    FolderDialog {
        id: folderDialog
        title: "Select Media Files Directory"
        onAccepted: {
            let folderPath = folderDialog.currentFolder.toString().replace("file://", "");
            console.log("FolderDialog::folderDialog - Selected Folder:", folderPath);
            AppState.setState({
                mediaFiles: [
                    {
                        title: "Folder Song 1",
                        artist: "Unknown Artist",
                        duration: 180000
                    },
                    {
                        title: "Folder Song 2",
                        artist: "Unknown Artist",
                        duration: 180000
                    }
                ]
            });
        }
        onRejected: {
            console.log("FolderDialog::folderDialog - Folder Selection Canceled");
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
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20 * scaleFactor
            width: parent.width * 0.8
            spacing: 5 * scaleFactor
            z: 2

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 35 * scaleFactor
                spacing: topControlSpacing * scaleFactor

                HoverButton {
                    Layout.preferredWidth: topControlButtonSize * scaleFactor
                    Layout.preferredHeight: topControlButtonSize * scaleFactor
                    flat: true
                    onClicked: folderDialog.open()
                    background: Rectangle {
                        color: parent.hovered ? "#e6e9ec" : "transparent"
                        radius: 10 * scaleFactor
                    }
                    Image {
                        source: "qrc:/Assets/folder.png"
                        width: topControlIconSize * scaleFactor
                        height: topControlIconSize * scaleFactor
                        anchors.centerIn: parent
                        opacity: parent.hovered ? 1.0 : 0.8
                    }
                }

                HoverButton {
                    Layout.preferredWidth: topControlButtonSize * scaleFactor
                    Layout.preferredHeight: topControlButtonSize * scaleFactor
                    flat: true
                    onClicked: {
                        NavigationManager.navigateTo("qrc:/Source/View/PlaylistView.qml");
                        console.log("Navigate to PlaylistView");
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#e6e9ec" : "transparent"
                        radius: 10 * scaleFactor
                    }
                    Image {
                        source: "qrc:/Assets/playlist.png"
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
                        onClicked: {
                            searchInput.forceActiveFocus();
                            if (searchInput.text !== "Search" && songViewModel) {
                                searchResultsView.visible = true;
                            }
                            console.log("Search bar clicked");
                        }
                    }

                    RowLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: topControlMargin * scaleFactor
                        spacing: topControlSpacing * scaleFactor

                        Image {
                            source: "qrc:/Assets/search.png"
                            Layout.preferredWidth: topControlSearchIconSize * scaleFactor
                            Layout.preferredHeight: topControlSearchIconSize * scaleFactor
                            Layout.alignment: Qt.AlignVCenter
                            opacity: 0.8
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            text: "Search"
                            color: "#2d3748"
                            font.pixelSize: topControlSearchFontSize * scaleFactor
                            font.family: "Arial"
                            verticalAlignment: TextInput.AlignVCenter
                            onActiveFocusChanged: {
                                if (activeFocus && text === "Search") {
                                    text = "";
                                }
                                if (activeFocus && text !== "" && songViewModel) {
                                    searchResultsView.visible = true;
                                    console.log("Search bar focused, showing results for:", text);
                                } else if (!activeFocus) {
                                    if (text === "") {
                                        text = "Search";
                                    }
                                    searchResultsView.visible = false;
                                    isSearching = false;
                                    console.log("Search bar lost focus");
                                }
                            }
                            onTextChanged: {
                                if (text !== "Search" && text.length >= 1 && songViewModel) {
                                    isSearching = true;
                                    searchResultsView.visible = true;
                                    songViewModel.search(text);
                                    console.log("Search query changed, executing search for:", text);
                                } else {
                                    isSearching = false;
                                    searchResultsView.visible = false;
                                    songViewModel.search("");
                                    console.log("Search cleared");
                                }
                            }
                            onAccepted: {
                                if (songViewModel && songViewModel.songModel.count > 0) {
                                    let songId = songViewModel.songModel.data(songViewModel.songModel.index(0, 0), songViewModel.songModel.IdRole);
                                    let title = songViewModel.songModel.data(songViewModel.songModel.index(0, 0), songViewModel.songModel.TitleRole);
                                    let artists = songViewModel.songModel.data(songViewModel.songModel.index(0, 0), songViewModel.songModel.ArtistsRole);
                                    songViewModel.playSong(songId, title, artists);
                                    AppState.setState({
                                        title: title,
                                        artist: artists.join(", "),
                                        playlistId: -1
                                    });
                                    searchResultsView.visible = false;
                                    searchInput.focus = false;
                                    isSearching = false;
                                    console.log("Selected first result, title:", title);
                                }
                            }
                        }
                    }
                }

                HoverButton {
                    id: profileButton
                    Layout.preferredWidth: topControlButtonSize * scaleFactor
                    Layout.preferredHeight: topControlButtonSize * scaleFactor
                    flat: true
                    onClicked: profileMenu.open()
                    background: Rectangle {
                        color: parent.hovered ? "#e6e9ec" : "transparent"
                        radius: 10 * scaleFactor
                    }
                    Image {
                        source: "qrc:/Assets/profile.png"
                        width: topControlIconSize * scaleFactor
                        height: topControlIconSize * scaleFactor
                        anchors.centerIn: parent
                        opacity: parent.hovered ? 1.0 : 0.8
                    }
                }

                Menu {
                    id: profileMenu
                    x: profileButton.x
                    y: profileButton.y + profileButton.height
                    width: 180 * scaleFactor

                    background: Rectangle {
                        color: "#ffffff"
                        border.color: "#d0d7de"
                        border.width: 1
                        radius: 8
                    }

                    MenuItem {
                        text: "View Details Account"
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 16 * scaleFactor
                            font.family: "Arial"
                            color: "#2d3748"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            leftPadding: 10
                        }
                        background: Rectangle {
                            color: parent.hovered ? "#f0f0f0" : "#ffffff"
                        }
                        onTriggered: {
                            NavigationManager.navigateTo("qrc:/Source/View/ProfileView.qml");
                            console.log("View Details Account clicked, navigating to ProfileView");
                        }
                    }
                    MenuItem {
                        text: "Setting"
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 16 * scaleFactor
                            font.family: "Arial"
                            color: "#2d3748"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            leftPadding: 10
                        }
                        background: Rectangle {
                            color: parent.hovered ? "#f0f0f0" : "#ffffff"
                        }
                        onTriggered: {
                            console.log("Setting clicked");
                        }
                    }
                    MenuItem {
                        text: "Logout"
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 16 * scaleFactor
                            font.family: "Arial"
                            color: "#2d3748"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            leftPadding: 10
                        }
                        background: Rectangle {
                            color: parent.hovered ? "#f0f0f0" : "#ffffff"
                        }
                        onTriggered: {
                            NavigationManager.navigateTo("qrc:/Source/View/LoginView.qml");
                            console.log("Logout clicked, navigated to LoginView");
                        }
                    }
                }
            }

            ListView {
                id: searchResultsView
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min((songViewModel ? songViewModel.songModel.count : 0) * searchResultItemHeight * scaleFactor, searchResultMaxHeight * scaleFactor)
                visible: false
                clip: true
                interactive: true
                model: songViewModel ? songViewModel.songModel : null
                z: 2

                Loader {
                    anchors.fill: parent
                    sourceComponent: {
                        if (songViewModel && songViewModel.songModel.isLoading) {
                            return loadingComponent;
                        } else if (songViewModel && songViewModel.songModel.count === 0 && isSearching) {
                            return noResultsComponent;
                        } else {
                            return songListComponent;
                        }
                    }
                }

                Component {
                    id: songListComponent
                    ListView {
                        model: searchResultsView.model
                        width: searchResultsView.width
                        height: searchResultsView.height
                        clip: true
                        interactive: true

                        delegate: Rectangle {
                            width: searchResultsView.width
                            height: searchResultItemHeight * scaleFactor
                            color: mouseArea.containsMouse ? "#f0f0f0" : "#ffffff"
                            border.color: "#d0d7de"
                            border.width: 1

                            Text {
                                anchors.fill: parent
                                anchors.margins: searchResultMargin * scaleFactor
                                text: {
                                    let artistsStr = model.artists.join(", ");
                                    console.log("Search Result - Title:", model.title, "Artists:", artistsStr);
                                    return model.title + " - " + artistsStr;
                                }
                                font.pixelSize: searchResultFontSize * scaleFactor
                                font.family: "Arial"
                                color: "#2d3748"
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    parent.color = "#f0f0f0";
                                }
                                onExited: {
                                    parent.color = "#ffffff";
                                }
                                onClicked: {
                                    if (songViewModel) {
                                        songViewModel.playSong(model.id, model.title, model.artists);
                                        AppState.setState({
                                            title: model.title,
                                            artist: model.artists.join(", "),
                                            playlistId: -1
                                        });
                                        songViewModel.fetchAllSongs();
                                        searchResultsView.visible = false;
                                        searchInput.focus = false;
                                        isSearching = false;
                                        console.log("Selected search result, title:", model.title, "artists:", model.artists.join(", "));
                                    }
                                }
                            }
                        }
                    }
                }

                Component {
                    id: loadingComponent
                    Rectangle {
                        color: "#f6f8fa"
                        Text {
                            anchors.centerIn: parent
                            text: "Searching..."
                            font.pixelSize: searchResultFontSize * scaleFactor
                            font.family: "Arial"
                            color: "#2d3748"
                        }
                    }
                }

                Component {
                    id: noResultsComponent
                    Rectangle {
                        color: "#f6f8fa"
                        Text {
                            anchors.centerIn: parent
                            text: "No songs found"
                            font.pixelSize: searchResultFontSize * scaleFactor
                            font.family: "Arial"
                            color: "#2d3748"
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

                onVisibleChanged: {
                    opacity = visible ? 1.0 : 0.5;
                    console.log("SearchResultsView visibility changed:", visible);
                }

                onModelChanged: {
                    console.log("Search results updated, count:", songViewModel ? songViewModel.songModel.count : 0);
                    if (songViewModel && songViewModel.songModel.count > 0 && isSearching) {
                        searchResultsView.visible = true;
                    }
                }
            }
        }

        ColumnLayout {
            id: songInfoLayout
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 150 * scaleFactor
            spacing: songInfoSpacing * scaleFactor
            width: parent.width * 0.8
            z: 1
            visible: AppState.currentMediaTitle !== "Unknown Title"
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
            opacity: visible ? 1.0 : 0.0

            Text {
                id: playlistText
                Layout.alignment: Qt.AlignHCenter
                text: AppState.currentPlaylistName
                visible: AppState.currentPlaylistId !== -1
                font.pixelSize: songInfoArtistSize * scaleFactor
                font.family: "Arial"
                font.weight: Font.Medium
                color: "#2d3748"
            }

            Text {
                id: titleText
                Layout.alignment: Qt.AlignHCenter
                text: AppState.currentMediaTitle
                font.pixelSize: songInfoTitleSize * scaleFactor
                font.family: "Arial"
                font.weight: Font.Bold
                color: "#1a202c"
            }

            Text {
                id: artistText
                Layout.alignment: Qt.AlignHCenter
                text: {
                    console.log("Song Info - Artist:", AppState.currentMediaArtist);
                    return AppState.currentMediaArtist;
                }
                font.pixelSize: songInfoArtistSize * scaleFactor
                font.family: "Arial"
                color: "#2d3748"
            }
        }

        ColumnLayout {
            id: playerControlsLayout
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: songInfoLayout.visible ? songInfoLayout.bottom : parent.top
            anchors.topMargin: songInfoLayout.visible ? 20 * scaleFactor : 150 * scaleFactor
            spacing: songInfoSpacing * scaleFactor
            width: parent.width * 0.8
            z: 1
            visible: AppState.currentMediaTitle !== "Unknown Title"
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
            Behavior on anchors.topMargin {
                NumberAnimation {
                    duration: 200
                }
            }
            opacity: visible ? 1.0 : 0.0

            Text {
                id: timeText
                Layout.alignment: Qt.AlignHCenter
                text: (songViewModel ? formatDuration(songViewModel.position) : "0:00") + " / " + (songViewModel ? formatDuration(songViewModel.duration) : "0:00")
                font.pixelSize: songInfoTimeSize * scaleFactor
                font.family: "Arial"
                color: "#2d3748"
            }

            SliderComponent {
                id: progressSlider
                Layout.fillWidth: true
                Layout.preferredHeight: 30 * scaleFactor
                minValue: 0.0
                maxValue: songViewModel ? songViewModel.duration : 0
                step: 1000
                value: songViewModel ? songViewModel.position : 0
                backgroundColor: "#e2e8f0"
                fillColor: "#2b6cb0"
                handleColor: "#ffffff"
                handlePressedColor: "#3182ce"
                borderColor: "#d0d7de"
                onValueChanged: {
                    if (pressed && songViewModel) {
                        songViewModel.setPosition(value);
                    }
                    console.log("Progress slider value:", value);
                }
            }

            RowLayout {
                id: controlButtons
                Layout.alignment: Qt.AlignHCenter
                spacing: controlSpacing * scaleFactor

                HoverButton {
                    Layout.preferredWidth: controlButtonSize * scaleFactor
                    Layout.preferredHeight: controlButtonSize * scaleFactor
                    flat: true
                    onClicked: {
                        shuffle = !shuffle;
                        console.log("Shuffle Button Clicked, enabled:", shuffle);
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#e6e9ec" : "transparent"
                        radius: 10 * scaleFactor
                    }
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/Assets/shuffle.png"
                        width: controlIconSize * scaleFactor
                        height: controlIconSize * scaleFactor
                        opacity: shuffle ? 1.0 : 0.8
                    }
                }

                HoverButton {
                    Layout.preferredWidth: controlButtonSize * scaleFactor
                    Layout.preferredHeight: controlButtonSize * scaleFactor
                    flat: true
                    onClicked: {
                        handlePrevious();
                        console.log("Previous Button Clicked");
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#e6e9ec" : "transparent"
                        radius: 10 * scaleFactor
                    }
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/Assets/prev.png"
                        width: controlIconSize * scaleFactor
                        height: controlIconSize * scaleFactor
                        opacity: parent.hovered ? 1.0 : 0.8
                    }
                }

                HoverButton {
                    id: playButton
                    Layout.preferredWidth: controlButtonSize * scaleFactor
                    Layout.preferredHeight: controlButtonSize * scaleFactor
                    flat: true
                    property string imageSource: songViewModel && songViewModel.isPlaying ? "qrc:/Assets/pause.png" : "qrc:/Assets/play.png"
                    onClicked: {
                        if (songViewModel) {
                            if (songViewModel.isPlaying) {
                                songViewModel.pause();
                            } else {
                                songViewModel.play();
                            }
                            console.log(songViewModel.isPlaying ? "Pause Button Clicked" : "Play Button Clicked");
                        }
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#e6e9ec" : "transparent"
                        radius: 10 * scaleFactor
                    }
                    Image {
                        anchors.centerIn: parent
                        source: playButton.imageSource
                        width: controlPlayIconSize * scaleFactor
                        height: controlPlayIconSize * scaleFactor
                        opacity: parent.hovered ? 1.0 : 0.8
                    }
                }

                HoverButton {
                    Layout.preferredWidth: controlButtonSize * scaleFactor
                    Layout.preferredHeight: controlButtonSize * scaleFactor
                    flat: true
                    onClicked: {
                        handleNext();
                        console.log("Next Button Clicked");
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#e6e9ec" : "transparent"
                        radius: 10 * scaleFactor
                    }
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/Assets/next.png"
                        width: controlIconSize * scaleFactor
                        height: controlIconSize * scaleFactor
                        opacity: parent.hovered ? 1.0 : 0.8
                    }
                }

                HoverButton {
                    Layout.preferredWidth: controlButtonSize * scaleFactor
                    Layout.preferredHeight: controlButtonSize * scaleFactor
                    flat: true
                    onClicked: {
                        repeatMode = (repeatMode + 1) % 3;
                        console.log("Repeat Button Clicked, mode:", repeatMode);
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#e6e9ec" : "transparent"
                        radius: 10 * scaleFactor
                    }
                    Image {
                        anchors.centerIn: parent
                        source: repeatMode === 1 ? "qrc:/Assets/repeat-one.png" : "qrc:/Assets/repeat.png"
                        width: controlIconSize * scaleFactor
                        height: controlIconSize * scaleFactor
                        opacity: repeatMode > 0 ? 1.0 : 0.8
                    }
                }
            }

            RowLayout {
                id: volumeControl
                Layout.alignment: Qt.AlignHCenter
                spacing: volumeSpacing * scaleFactor

                HoverButton {
                    Layout.preferredWidth: volumeIconSize * scaleFactor
                    Layout.preferredHeight: volumeIconSize * scaleFactor
                    flat: true
                    onClicked: {
                        if (songViewModel) {
                            muted = !muted;
                            if (muted) {
                                previousVolume = songViewModel.volume;
                                songViewModel.setVolume(0);
                            } else {
                                songViewModel.setVolume(previousVolume);
                            }
                            console.log("Volume Button Clicked, muted:", muted, "volume:", songViewModel.volume);
                        }
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#e6e9ec" : "transparent"
                        radius: 10 * scaleFactor
                    }
                    Image {
                        anchors.centerIn: parent
                        source: muted || (songViewModel && songViewModel.volume === 0) ? "qrc:/Assets/muted.png" : "qrc:/Assets/volume.png"
                        width: volumeIconSize * scaleFactor
                        height: volumeIconSize * scaleFactor
                        opacity: parent.hovered ? 1.0 : 0.8
                    }
                }

                SliderComponent {
                    id: volumeSlider
                    Layout.preferredWidth: volumeSliderWidth * scaleFactor
                    Layout.preferredHeight: volumeSliderHeight * scaleFactor
                    minValue: 0.0
                    maxValue: 1.0
                    step: 0.1
                    value: songViewModel ? songViewModel.volume : 0.5
                    backgroundColor: "#e2e8f0"
                    fillColor: "#2b6cb0"
                    handleColor: "#ffffff"
                    handlePressedColor: "#3182ce"
                    borderColor: "#d0d7de"
                    onValueChanged: {
                        if (songViewModel) {
                            songViewModel.setVolume(value);
                            muted = (value === 0);
                            if (!muted) {
                                previousVolume = value;
                            }
                            console.log("Volume slider value:", value);
                        }
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            z: 0
            propagateComposedEvents: true
            onPressed: function (mouse) {
                if (!searchResultsView.contains(searchResultsView.mapFromItem(mouseArea, mouse.x, mouse.y)) && !searchInput.contains(searchInput.mapFromItem(mouseArea, mouse.x, mouse.y))) {
                    searchInput.focus = false;
                    searchResultsView.visible = false;
                    isSearching = false;
                    console.log("Focus removed from search bar, text:", searchInput.text);
                }
                mouse.accepted = false;
            }
        }
    }

    Connections {
        target: songViewModel
        function onErrorOccurred(error) {
            console.log("MediaPlayerView: Playback error:", error);
        }
        function onAllSongsFetched() {
            allSongsLoaded = true;
            console.log("MediaPlayerView: All songs fetched, count:", songViewModel.songModel.count);
        }
    }

    Component.onCompleted: {
        console.log("MediaPlayerView: Component completed");
        if (AppState.currentPlaylistId === -1) {
            songViewModel.fetchAllSongs();
        }
    }
}
