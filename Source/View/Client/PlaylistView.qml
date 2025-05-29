import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
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
                        NavigationManager.goBack();
                        console.log("Back clicked");
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
                            text: "Search Playlists"
                            color: "#2d3748"
                            font.pixelSize: topControlSearchFontSize * scaleFactor
                            font.family: "Arial"
                            onActiveFocusChanged: {
                                if (activeFocus && text === "Search Playlists") {
                                    text = "";
                                }
                            }
                            onFocusChanged: {
                                if (!focus && text === "") {
                                    text = "Search Playlists";
                                }
                            }
                            onTextChanged: {
                                if (text !== "Search Playlists" && text !== "") {
                                    console.log("Search query:", text);
                                    playlistViewModel.search(text);
                                } else {
                                    searchResultsModel.clear();
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
                        if (AppState.isAuthenticated) {
                            addPlaylistPopup.open();
                        } else {
                            notificationPopup.text = "Please login to create a playlist";
                            notificationPopup.color = "#e53e3e";
                            notificationPopup.open();
                        }
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

            ListModel {
                id: searchResultsModel
            }

            ListView {
                id: playlistView
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
                model: searchInput.text !== "" && searchInput.text !== "Search Playlists" ? searchResultsModel : playlistViewModel.playlistModel
                cacheBuffer: 2000
                maximumFlickVelocity: 4000
                flickDeceleration: 1500

                delegate: Rectangle {
                    width: playlistView.width
                    height: playlistItemHeight * scaleFactor
                    color: mouseArea.containsMouse ? "#f0f0f0" : "#ffffff"
                    border.color: "#d0d7de"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10 * scaleFactor
                        anchors.rightMargin: 10 * scaleFactor
                        spacing: 8 * scaleFactor

                        Text {
                            text: (index + 1) + ". " + model.name
                            font.pixelSize: playlistItemFontSize * scaleFactor
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
                                    console.log("PlaylistView: Clicking playlist, ID:", model.id, "Name:", model.name);
                                    AppState.setState({
                                        playlistId: model.id,
                                        playlistName: model.name
                                    });
                                    playlistViewModel.loadSongsInPlaylist(model.id);
                                    console.log("PlaylistView: Set AppState.currentPlaylistId to", model.id, "Navigating to MediaFileView");
                                }
                            }
                        }

                        HoverButton {
                            Layout.preferredWidth: topControlIconSize * scaleFactor
                            Layout.preferredHeight: topControlIconSize * scaleFactor
                            flat: true
                            onClicked: {
                                popup.playlistId = model.id;
                                popup.playlistName = model.name;
                                popup.open();
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

                Text {
                    anchors.centerIn: parent
                    text: searchInput.text !== "" && searchInput.text !== "Search Playlists" ? "No search results" : "No playlists available"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    font.family: "Arial"
                    color: "#2d3748"
                    visible: playlistView.count === 0
                }
            }
        }

        Popup {
            id: addPlaylistPopup
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: 300 * scaleFactor
            height: 150 * scaleFactor
            modal: true
            focus: true
            background: Rectangle {
                color: "#ffffff"
                border.color: "#d0d7de"
                radius: 8
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: playlistSpacing * scaleFactor

                Text {
                    text: "Enter Playlist Name"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    font.family: "Arial"
                    color: "#1a202c"
                    Layout.alignment: Qt.AlignHCenter
                }

                TextField {
                    id: newPlaylistNameField
                    placeholderText: "Playlist name"
                    placeholderTextColor: "#a0aec0"
                    color: "#2d3748"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    font.family: "Arial"
                    Layout.fillWidth: true
                    Layout.leftMargin: playlistItemMargin * scaleFactor
                    Layout.rightMargin: playlistItemMargin * scaleFactor
                    background: Rectangle {
                        color: "#f6f8fa"
                        radius: 12
                        border.color: parent.activeFocus ? "#3182ce" : "#d0d7de"
                        border.width: parent.activeFocus ? 2 : 1
                    }
                }

                HoverButton {
                    id: addButton
                    text: "Add"
                    Layout.fillWidth: true
                    Layout.leftMargin: playlistItemMargin * scaleFactor
                    Layout.rightMargin: playlistItemMargin * scaleFactor
                    defaultColor: "#2b6cb0"
                    hoverColor: "#3182ce"
                    radius: 12 * scaleFactor
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    font.family: "Arial"
                    onClicked: {
                        var name = newPlaylistNameField.text.trim();
                        if (name !== "") {
                            playlistViewModel.createNewPlaylist(name);
                            addPlaylistPopup.close();
                            newPlaylistNameField.text = "";
                        }
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
            property string text: ""
            property color color: "#48bb78"

            background: Rectangle {
                color: notificationPopup.color
                radius: 8
            }

            Text {
                anchors.centerIn: parent
                text: notificationPopup.text
                font.pixelSize: playlistItemFontSize * scaleFactor
                font.family: "Arial"
                color: "#ffffff"
            }

            Timer {
                interval: 2000
                running: notificationPopup.visible
                onTriggered: notificationPopup.close()
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
                radius: 8
            }

            property int playlistId: 0
            property string playlistName: ""

            ColumnLayout {
                anchors.fill: parent
                spacing: playlistSpacing * scaleFactor

                HoverButton {
                    text: "Delete"
                    Layout.fillWidth: true
                    Layout.leftMargin: playlistItemMargin * scaleFactor
                    Layout.rightMargin: playlistItemMargin * scaleFactor
                    defaultColor: "#2b6cb0"
                    hoverColor: "#3182ce"
                    radius: 12 * scaleFactor
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    font.family: "Arial"
                    onClicked: {
                        if (AppState.isAuthenticated) {
                            playlistViewModel.deletePlaylist(popup.playlistId);
                            popup.close();
                        } else {
                            notificationPopup.text = "Please login to delete a playlist";
                            notificationPopup.color = "#e53e3e";
                            notificationPopup.open();
                        }
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

        Connections {
            target: playlistViewModel
            function onErrorOccurred(error) {
                notificationPopup.text = error;
                notificationPopup.color = "#e53e3e";
                notificationPopup.open();
            }

            function onPlaylistCreated(playlistId) {
                notificationPopup.text = "Playlist created successfully (ID: " + playlistId + ")";
                notificationPopup.color = "#48bb78";
                notificationPopup.open();
            }

            function onPlaylistUpdated(playlistId) {
                notificationPopup.text = "Playlist updated successfully (ID: " + playlistId + ")";
                notificationPopup.color = "#48bb78";
                notificationPopup.open();
            }

            function onPlaylistDeleted(playlistId) {
                notificationPopup.text = "Playlist deleted successfully (ID: " + playlistId + ")";
                notificationPopup.color = "#48bb78";
                notificationPopup.open();
            }

            function onSongsLoaded(playlistId, songs, message) {
                console.log("PlaylistView: Songs loaded for playlist ID:", playlistId, "Count:", songs.length);
                AppState.setState({
                    mediaFiles: songs
                });
                NavigationManager.navigateTo("qrc:/Source/View/Client/MediaFileView.qml");
                console.log("PlaylistView: Navigated to MediaFileView for playlist ID:", playlistId);
            }

            function onSearchResultsLoaded(playlists, message) {
                console.log("PlaylistView: Search results loaded, count:", playlists.length, "Message:", message);
                searchResultsModel.clear();
                for (var i = 0; i < playlists.length; i++) {
                    searchResultsModel.append({
                        id: playlists[i].id,
                        name: playlists[i].name,
                        imageUrl: playlists[i].imageUrl || "",
                        userId: playlists[i].userId
                    });
                }
            }
        }
    }

    Component.onCompleted: {
        if (AppState.isAuthenticated) {
            playlistViewModel.loadPlaylists();
        } else {
            notificationPopup.text = "Please login to load playlists";
            notificationPopup.color = "#e53e3e";
            notificationPopup.open();
        }
        console.log("PlaylistView: Component completed at", new Date().toLocaleString(Qt.locale(), "hh:mm AP"), "Current Playlist ID:", AppState.currentPlaylistId);
    }
}
