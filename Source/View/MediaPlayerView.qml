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
    property real topControlSearchRadius: 30
    property real topControlSearchIconSize: 30
    property real topControlSearchFontSize: 24
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
    property int repeatMode: 0 // 0: No repeat, 1: Repeat one, 2: Repeat playlist
    property bool muted: false
    property real previousVolume: 0.5
    property bool isSearching: false

    function formatDuration(milliseconds) {
        if (!milliseconds || milliseconds < 0 || isNaN(milliseconds)) {
            return "0:00";
        }
        let seconds = Math.floor(milliseconds / 1000);
        let minutes = Math.floor(seconds / 60);
        let secs = Math.floor(seconds % 60);
        return minutes + ":" + (secs < 10 ? "0" : "") + secs;
    }

    // Hàm tìm chỉ số bài hát hiện tại trong danh sách playlist
    function findCurrentSongIndex() {
        if (AppState.currentMediaFiles.length === 0 || !AppState.currentMediaTitle) {
            return -1;
        }
        for (let i = 0; i < AppState.currentMediaFiles.length; i++) {
            let song = AppState.currentMediaFiles[i];
            if (song.title === AppState.currentMediaTitle && song.artists.join(", ") === AppState.currentMediaArtist) {
                return i;
            }
        }
        return -1;
    }

    // Hàm phát bài hát tại chỉ số cụ thể
    function playSongAtIndex(index) {
        if (index < 0 || index >= AppState.currentMediaFiles.length) {
            console.log("Invalid song index:", index);
            return;
        }
        let song = AppState.currentMediaFiles[index];
        AppState.setState({
            title: song.title,
            artist: song.artists ? song.artists.join(", ") : "Unknown Artist",
            filePath: song.file_path,
            playlistId: AppState.currentPlaylistId
        });
        songViewModel.playSong(song.id, song.title, song.artists);
        console.log("Playing song at index:", index, "Title:", song.title, "Artists:", song.artists.join(", "));
    }

    // Hàm xử lý nút Next
    function handleNext() {
        if (AppState.currentPlaylistId === -1 || AppState.currentMediaFiles.length === 0) {
            console.log("No playlist or empty playlist, cannot go to next song");
            return;
        }

        let currentIndex = findCurrentSongIndex();
        if (currentIndex === -1) {
            console.log("Current song not found in playlist");
            return;
        }

        if (repeatMode === 1) {
            // Repeat one: Phát lại bài hiện tại
            playSongAtIndex(currentIndex);
        } else {
            let nextIndex;
            if (shuffle) {
                // Shuffle: Chọn ngẫu nhiên một bài khác
                nextIndex = Math.floor(Math.random() * AppState.currentMediaFiles.length);
                while (nextIndex === currentIndex && AppState.currentMediaFiles.length > 1) {
                    nextIndex = Math.floor(Math.random() * AppState.currentMediaFiles.length);
                }
            } else {
                // Không shuffle: Chuyển đến bài tiếp theo
                nextIndex = currentIndex + 1;
                if (nextIndex >= AppState.currentMediaFiles.length) {
                    if (repeatMode === 2) {
                        nextIndex = 0; // Repeat playlist: Quay lại đầu
                    } else {
                        console.log("Reached end of playlist, stopping");
                        return;
                    }
                }
            }
            playSongAtIndex(nextIndex);
        }
    }

    // Hàm xử lý nút Previous
    function handlePrevious() {
        if (AppState.currentPlaylistId === -1 || AppState.currentMediaFiles.length === 0) {
            console.log("No playlist or empty playlist, cannot go to previous song");
            return;
        }

        let currentIndex = findCurrentSongIndex();
        if (currentIndex === -1) {
            console.log("Current song not found in playlist");
            return;
        }

        if (repeatMode === 1) {
            // Repeat one: Phát lại bài hiện tại
            playSongAtIndex(currentIndex);
        } else {
            let prevIndex;
            if (shuffle) {
                // Shuffle: Chọn ngẫu nhiên một bài khác
                prevIndex = Math.floor(Math.random() * AppState.currentMediaFiles.length);
                while (prevIndex === currentIndex && AppState.currentMediaFiles.length > 1) {
                    prevIndex = Math.floor(Math.random() * AppState.currentMediaFiles.length);
                }
            } else {
                // Không shuffle: Chuyển đến bài trước
                prevIndex = currentIndex - 1;
                if (prevIndex < 0) {
                    if (repeatMode === 2) {
                        prevIndex = AppState.currentMediaFiles.length - 1; // Repeat playlist: Quay lại cuối
                    } else {
                        console.log("Reached start of playlist, stopping");
                        return;
                    }
                }
            }
            playSongAtIndex(prevIndex);
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
                        duration: 240000
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
        color: "white"

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
                    Image {
                        source: "qrc:/Assets/folder.png"
                        width: topControlIconSize * scaleFactor
                        height: topControlIconSize * scaleFactor
                        anchors.centerIn: parent
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
                    Image {
                        source: "qrc:/Assets/playlist.png"
                        width: topControlIconSize * scaleFactor
                        height: topControlIconSize * scaleFactor
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: topControlSearchHeight * scaleFactor
                    radius: topControlSearchRadius * scaleFactor
                    color: "#e0e0e0"

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
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            text: "Search"
                            color: "#666666"
                            font.pixelSize: topControlSearchFontSize * scaleFactor
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
                                        artist: artists.join(", ")
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
                    Image {
                        source: "qrc:/Assets/profile.png"
                        width: topControlIconSize * scaleFactor
                        height: topControlIconSize * scaleFactor
                        anchors.centerIn: parent
                    }
                }

                Menu {
                    id: profileMenu
                    x: profileButton.x
                    y: profileButton.y + profileButton.height
                    width: 180 * scaleFactor

                    background: Rectangle {
                        color: "#ffffff"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 5
                    }

                    MenuItem {
                        text: "View Details Account"
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 16 * scaleFactor
                            color: "#333333"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            leftPadding: 10
                        }
                        onTriggered: {
                            console.log("View Details Account clicked");
                        }
                    }
                    MenuItem {
                        text: "Setting"
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 16 * scaleFactor
                            color: "#333333"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            leftPadding: 10
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
                            color: "#333333"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            leftPadding: 10
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
                            border.color: "#e0e0e0"
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
                                color: "#333333"
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
                                            artist: model.artists.join(", ")
                                        });
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
                        color: "#f0f0f0"
                        Text {
                            anchors.centerIn: parent
                            text: "Searching..."
                            font.pixelSize: searchResultFontSize * scaleFactor
                            color: "#666666"
                        }
                    }
                }

                Component {
                    id: noResultsComponent
                    Rectangle {
                        color: "#f0f0f0"
                        Text {
                            anchors.centerIn: parent
                            text: "No songs found"
                            font.pixelSize: searchResultFontSize * scaleFactor
                            color: "#666666"
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
                visible: false
                font.pixelSize: songInfoArtistSize * scaleFactor
                color: "#666666"
                font.bold: true
            }

            Text {
                id: titleText
                Layout.alignment: Qt.AlignHCenter
                text: AppState.currentMediaTitle
                font.pixelSize: songInfoTitleSize * scaleFactor
                color: "#000000"
                font.bold: true
            }

            Text {
                id: artistText
                Layout.alignment: Qt.AlignHCenter
                text: {
                    console.log("Song Info - Artist:", AppState.currentMediaArtist);
                    return AppState.currentMediaArtist;
                }
                font.pixelSize: songInfoArtistSize * scaleFactor
                color: "#333333"
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
                color: "#666666"
            }

            SliderComponent {
                id: progressSlider
                Layout.fillWidth: true
                Layout.preferredHeight: 30 * scaleFactor
                minValue: 0.0
                maxValue: songViewModel ? songViewModel.duration : 0
                step: 1000
                value: songViewModel ? songViewModel.position : 0
                backgroundColor: "#cccccc"
                fillColor: "#000000"
                handleColor: "#ffffff"
                handlePressedColor: "#000000"
                borderColor: "#000000"
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
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/Assets/shuffle.png"
                        width: controlIconSize * scaleFactor
                        height: controlIconSize * scaleFactor
                        opacity: shuffle ? 1.0 : 0.5
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
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/Assets/prev.png"
                        width: controlIconSize * scaleFactor
                        height: controlIconSize * scaleFactor
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
                    Image {
                        anchors.centerIn: parent
                        source: playButton.imageSource
                        width: controlPlayIconSize * scaleFactor
                        height: controlPlayIconSize * scaleFactor
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
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/Assets/next.png"
                        width: controlIconSize * scaleFactor
                        height: controlIconSize * scaleFactor
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
                    Image {
                        anchors.centerIn: parent
                        source: repeatMode === 1 ? "qrc:/Assets/repeat-one.png" : "qrc:/Assets/repeat.png"
                        width: controlIconSize * scaleFactor
                        height: controlIconSize * scaleFactor
                        opacity: repeatMode > 0 ? 1.0 : 0.5
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
                    Image {
                        anchors.centerIn: parent
                        source: muted || (songViewModel && songViewModel.volume === 0) ? "qrc:/Assets/muted.png" : "qrc:/Assets/volume.png"
                        width: volumeIconSize * scaleFactor
                        height: volumeIconSize * scaleFactor
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
                    backgroundColor: "#cccccc"
                    fillColor: "#000000"
                    handleColor: "#ffffff"
                    handlePressedColor: "#000000"
                    borderColor: "#000000"
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
        // Có thể hiển thị thông báo lỗi nếu cần
        }
    }

    Component.onCompleted: {
        console.log("MediaPlayerView: Component completed");
    }
}
