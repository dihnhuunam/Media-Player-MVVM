import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Components"

Item {
    // Properties from AppState and local state
    property string playlistName: AppState.currentPlaylistName
    property string title: AppState.currentMediaTitle
    property string artist: AppState.currentMediaArtist
    property string playTime: "0:00"
    property bool isPlaying: false
    property real volume: 0.5
    property bool shuffle: false
    property int repeatMode: 0 // 0: none, 1: repeat all, 2: repeat one
    property bool muted: false

    // Scale Factor
    readonly property real scaleFactor: Math.min(parent.width / 1024, parent.height / 600)

    // Top Controls Properties
    property real topControlButtonSize: 90
    property real topControlIconSize: 45
    property real topControlSearchHeight: 60
    property real topControlSearchRadius: 30
    property real topControlSearchIconSize: 30
    property real topControlSearchFontSize: 24
    property real topControlSpacing: 30
    property real topControlMargin: 18

    // Song Info Properties
    property real songInfoTitleSize: 44
    property real songInfoArtistSize: 36
    property real songInfoTimeSize: 34
    property real songInfoSpacing: 20

    // Control Buttons Properties
    property real controlButtonSize: 60
    property real controlIconSize: 24
    property real controlPlayIconSize: 30
    property real controlSpacing: 30

    // Volume Control Properties
    property real volumeIconSize: 24
    property real volumeSliderWidth: 100
    property real volumeSliderHeight: 24
    property real volumeSpacing: 8
    property real previousVolume: 0.5

    // Search Results Properties
    property real searchResultMaxHeight: 300
    property real searchResultItemHeight: 40
    property real searchResultFontSize: 16
    property real searchResultMargin: 10

    // Search Results
    property var filteredSongs: []

    function formatDuration(milliseconds) {
        if (!milliseconds || milliseconds < 0 || isNaN(milliseconds)) {
            return "0:00";
        }
        let seconds = Math.floor(milliseconds / 1000);
        let minutes = Math.floor(seconds / 60);
        let secs = Math.floor(seconds % 60);
        return minutes + ":" + (secs < 10 ? "0" : "") + secs;
    }

    // Debounce timer for search
    Timer {
        id: searchDebounceTimer
        interval: 200
        repeat: false
        onTriggered: {
            if (searchInput.text !== "Search" && searchInput.text !== "") {
                // Simulate search using AppState.currentMediaFiles or static data
                let query = searchInput.text.toLowerCase();
                let allSongs = AppState.currentMediaFiles.length > 0 ? AppState.currentMediaFiles : [
                    {
                        playlistName: "Playlist 1",
                        title: "Sample Song 1",
                        artist: "Artist 1",
                        index: 0
                    },
                    {
                        playlistName: "Playlist 1",
                        title: "Sample Song 2",
                        artist: "Artist 2",
                        index: 1
                    },
                    {
                        playlistName: "Playlist 2",
                        title: "Another Song",
                        artist: "Artist 3",
                        index: 0
                    }
                ];
                filteredSongs = allSongs.filter(song => song.title.toLowerCase().includes(query) || song.artist.toLowerCase().includes(query) || song.playlistName.toLowerCase().includes(query));
                searchResultsView.visible = searchInput.activeFocus && filteredSongs.length > 0;
                console.log("Search query:", searchInput.text, "Results:", filteredSongs.length);
            } else {
                filteredSongs = [];
                searchResultsView.visible = false;
                console.log("Reset search results");
            }
        }
    }

    // QML Logic
    FolderDialog {
        id: folderDialog
        title: "Select Media Files Directory"
        onAccepted: {
            let folderPath = folderDialog.currentFolder.toString().replace("file://", "");
            console.log("FolderDialog::folderDialog - Selected Folder:", folderPath);
            // Placeholder for loading folder (no controller)
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

            // 1. Top Controls
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 35 * scaleFactor
                spacing: topControlSpacing * scaleFactor

                // Folder Button
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

                // Playlist Button
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

                // Search Bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: topControlSearchHeight * scaleFactor
                    radius: topControlSearchRadius * scaleFactor
                    color: "#e0e0e0"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            searchInput.forceActiveFocus();
                            if (searchInput.text !== "Search" && filteredSongs.length > 0) {
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
                                if (activeFocus && text !== "" && filteredSongs.length > 0) {
                                    searchResultsView.visible = true;
                                    console.log("Search bar focused, showing results for:", text);
                                } else if (!activeFocus) {
                                    if (text === "") {
                                        text = "Search";
                                    }
                                    searchResultsView.visible = false;
                                    console.log("Search bar lost focus");
                                }
                            }
                            onTextChanged: {
                                searchDebounceTimer.restart();
                            }
                            onAccepted: {
                                if (filteredSongs.length > 0) {
                                    AppState.setState({
                                        playlistName: filteredSongs[0].playlistName,
                                        title: filteredSongs[0].title,
                                        artist: filteredSongs[0].artist
                                    });
                                    searchResultsView.visible = false;
                                    searchInput.focus = false;
                                    console.log("Selected first result, title:", filteredSongs[0].title);
                                }
                            }
                        }
                    }
                }

                // Profile Button
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

                // Profile Dropdown Menu
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

            // 2. Search Result
            ListView {
                id: searchResultsView
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(filteredSongs.length * searchResultItemHeight * scaleFactor, searchResultMaxHeight * scaleFactor)
                visible: false
                clip: true
                interactive: true
                model: filteredSongs
                z: 2

                delegate: Rectangle {
                    width: searchResultsView.width
                    height: searchResultItemHeight * scaleFactor
                    color: mouseArea.containsMouse ? "#f0f0f0" : "#ffffff"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Text {
                        anchors.fill: parent
                        anchors.margins: searchResultMargin * scaleFactor
                        text: modelData.playlistName + " - " + modelData.title + " - " + modelData.artist
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
                            AppState.setState({
                                playlistName: modelData.playlistName,
                                title: modelData.title,
                                artist: modelData.artist
                            });
                            searchResultsView.visible = false;
                            searchInput.focus = false;
                            console.log("Selected search result, title:", modelData.title, "artist:", modelData.artist);
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
                }

                onModelChanged: {
                    console.log("Search results updated, count:", count);
                }
            }
        }

        // 3. Song Info
        ColumnLayout {
            anchors.centerIn: parent
            spacing: songInfoSpacing * scaleFactor
            width: parent.width * 0.8
            z: 1

            Text {
                id: playlistText
                Layout.alignment: Qt.AlignHCenter
                text: playlistName
                font.pixelSize: songInfoArtistSize * scaleFactor
                color: "#666666"
                font.bold: true
            }

            Text {
                id: titleText
                Layout.alignment: Qt.AlignHCenter
                text: title
                font.pixelSize: songInfoTitleSize * scaleFactor
                color: "#000000"
                font.bold: true
            }

            Text {
                id: artistText
                Layout.alignment: Qt.AlignHCenter
                text: artist
                font.pixelSize: songInfoArtistSize * scaleFactor
                color: "#333333"
            }

            Text {
                id: timeText
                Layout.alignment: Qt.AlignHCenter
                text: playTime + " / 0:00"
                font.pixelSize: songInfoTimeSize * scaleFactor
                color: "#666666"
            }

            SliderComponent {
                id: progressSlider
                Layout.fillWidth: true
                Layout.preferredHeight: 30 * scaleFactor
                minValue: 0.0
                maxValue: 100
                step: 100
                value: 0
                backgroundColor: "#cccccc"
                fillColor: "#000000"
                handleColor: "#ffffff"
                handlePressedColor: "#000000"
                borderColor: "#000000"
                onValueChanged: {
                    console.log("Progress slider value:", value);
                }
            }
        }

        // 4. Control Buttons
        RowLayout {
            id: controlButtons
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: volumeControl.top
            anchors.bottomMargin: 40 * scaleFactor
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
                property string imageSource: isPlaying ? "qrc:/Assets/pause.png" : "qrc:/Assets/play.png"
                onClicked: {
                    isPlaying = !isPlaying;
                    console.log(isPlaying ? "Pause Button Clicked" : "Play Button Clicked");
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

        // 5. Volume Slider
        RowLayout {
            id: volumeControl
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * scaleFactor
            spacing: volumeSpacing * scaleFactor

            HoverButton {
                Layout.preferredWidth: volumeIconSize * scaleFactor
                Layout.preferredHeight: volumeIconSize * scaleFactor
                flat: true
                onClicked: {
                    muted = !muted;
                    if (muted) {
                        previousVolume = volume;
                        volume = 0;
                    } else {
                        volume = previousVolume;
                    }
                    console.log("Volume Button Clicked, muted:", muted, "volume:", volume);
                }
                Image {
                    anchors.centerIn: parent
                    source: muted || volume === 0 ? "qrc:/Assets/muted.png" : "qrc:/Assets/volume.png"
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
                value: volume
                backgroundColor: "#cccccc"
                fillColor: "#000000"
                handleColor: "#ffffff"
                handlePressedColor: "#000000"
                borderColor: "#000000"
                onValueChanged: {
                    volume = value;
                    muted = (volume === 0);
                    if (!muted) {
                        previousVolume = volume;
                    }
                    console.log("Volume slider value:", volume);
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            z: 0
            propagateComposedEvents: true
            onPressed: function (mouse) {
                if (!searchResultsView.contains(Qt.point(mouse.x - searchResultsView.x, mouse.y - searchResultsView.y)) && !searchInput.contains(Qt.point(mouse.x - searchInput.x, mouse.y - searchInput.y))) {
                    searchInput.focus = false;
                    searchResultsView.visible = false;
                    console.log("Focus removed from search bar, text:", searchInput.text);
                }
                mouse.accepted = false;
            }
        }
    }

    Component.onCompleted: {
        console.log("MediaPlayerView: Component completed");
    }
}
