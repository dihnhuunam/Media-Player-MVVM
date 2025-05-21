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
    property real topControlSearchRadius: 30
    property real topControlSearchIconSize: 30
    property real topControlSearchFontSize: 24
    property real topControlSpacing: 30
    property real topControlMargin: 18
    property real topControlTopMargin: 20

    property real playlistItemHeight: 50
    property real playlistItemFontSize: 16
    property real playlistItemMargin: 30
    property real playlistSpacing: 6

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"

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
                    Image {
                        source: "qrc:/Assets/back.png"
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
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            text: "Search Playlists"
                            color: "#666666"
                            font.pixelSize: topControlSearchFontSize * scaleFactor
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
                                console.log("Search query:", text);
                            }
                        }
                    }
                }

                HoverButton {
                    Layout.preferredWidth: topControlButtonSize * scaleFactor
                    Layout.preferredHeight: topControlButtonSize * scaleFactor
                    flat: true
                    onClicked: {
                        if (playlistViewModel.isAuthenticated) {
                            addPlaylistPopup.open();
                        } else {
                            notificationPopup.text = "Please login to create a playlist";
                            notificationPopup.color = "#F44336";
                            notificationPopup.open();
                        }
                    }
                    Image {
                        source: "qrc:/Assets/add.png"
                        width: topControlIconSize * scaleFactor
                        height: topControlIconSize * scaleFactor
                        anchors.centerIn: parent
                    }
                }
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
                model: playlistViewModel.playlistModel
                cacheBuffer: 2000
                maximumFlickVelocity: 4000
                flickDeceleration: 1500

                delegate: Rectangle {
                    width: playlistView.width
                    height: playlistItemHeight * scaleFactor
                    color: index % 2 === 0 ? "#f0f0f0" : "#ffffff"

                    RowLayout {
                        anchors.fill: parent
                        spacing: playlistSpacing * scaleFactor

                        Text {
                            text: (index + 1).toString()
                            font.pixelSize: playlistItemFontSize * scaleFactor
                            color: "#666666"
                            Layout.leftMargin: playlistItemMargin * scaleFactor
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: model.name
                            font.pixelSize: playlistItemFontSize * scaleFactor
                            color: "#333333"
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    playlistViewModel.loadSongsInPlaylist(model.id);
                                    AppState.setState({
                                        playlistName: model.name,
                                        mediaFiles: model.songs
                                    });
                                    NavigationManager.navigateTo("qrc:/Source/View/MediaFileView.qml");
                                    console.log("Clicked playlist:", model.name, "ID:", model.id);
                                }
                            }
                        }

                        HoverButton {
                            Layout.preferredWidth: topControlIconSize * scaleFactor
                            Layout.preferredHeight: topControlIconSize * scaleFactor
                            Layout.rightMargin: playlistItemMargin * scaleFactor
                            flat: true
                            onClicked: {
                                popup.playlistId = model.id;
                                popup.playlistName = model.name;
                                renameField.text = model.name;
                                descriptionField.text = model.description;
                                popup.open();
                            }
                            Image {
                                source: "qrc:/Assets/more.png"
                                width: topControlIconSize * scaleFactor * 0.6
                                height: topControlIconSize * scaleFactor * 0.6
                                anchors.centerIn: parent
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "No playlists available"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    color: "#666666"
                    visible: playlistView.count === 0
                }
            }
        }

        Popup {
            id: addPlaylistPopup
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: 300 * scaleFactor
            height: 250 * scaleFactor
            modal: true
            focus: true
            background: Rectangle {
                color: "#ffffff"
                border.color: "#cccccc"
                radius: 5
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: playlistSpacing * scaleFactor

                Text {
                    text: "Enter Playlist Name"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    color: "#000000"
                    Layout.alignment: Qt.AlignHCenter
                }

                TextField {
                    id: newPlaylistNameField
                    placeholderText: "Playlist name"
                    placeholderTextColor: "#666666"
                    color: "#000000"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    Layout.fillWidth: true
                    Layout.leftMargin: playlistItemMargin * scaleFactor
                    Layout.rightMargin: playlistItemMargin * scaleFactor
                    background: Rectangle {
                        color: "#e0e0e0"
                        radius: 5
                    }
                }

                Text {
                    text: "Enter Playlist Description (Optional)"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    color: "#000000"
                    Layout.alignment: Qt.AlignHCenter
                }

                TextField {
                    id: newPlaylistDescriptionField
                    placeholderText: "Description"
                    placeholderTextColor: "#666666"
                    color: "#000000"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    Layout.fillWidth: true
                    Layout.leftMargin: playlistItemMargin * scaleFactor
                    Layout.rightMargin: playlistItemMargin * scaleFactor
                    background: Rectangle {
                        color: "#e0e0e0"
                        radius: 5
                    }
                }

                Button {
                    id: addButton
                    text: "Add"
                    Layout.fillWidth: true
                    Layout.leftMargin: playlistItemMargin * scaleFactor
                    Layout.rightMargin: playlistItemMargin * scaleFactor
                    background: Rectangle {
                        color: "#e0e0e0"
                        radius: 5
                    }
                    contentItem: Text {
                        text: addButton.text
                        font.pixelSize: playlistItemFontSize * scaleFactor
                        color: "#000000"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        var name = newPlaylistNameField.text.trim();
                        var description = newPlaylistDescriptionField.text.trim();
                        if (name !== "") {
                            playlistViewModel.createNewPlaylist(name, description);
                            addPlaylistPopup.close();
                            newPlaylistNameField.text = "";
                            newPlaylistDescriptionField.text = "";
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
            property color color: "#4CAF50"

            background: Rectangle {
                color: notificationPopup.color
                radius: 5
            }

            Text {
                anchors.centerIn: parent
                text: notificationPopup.text
                font.pixelSize: playlistItemFontSize * scaleFactor
                color: "#FFFFFF"
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
            width: 300 * scaleFactor
            height: 250 * scaleFactor
            modal: true
            focus: true
            background: Rectangle {
                color: "#ffffff"
                border.color: "#cccccc"
                radius: 5
            }

            property int playlistId: 0
            property string playlistName: ""

            ColumnLayout {
                anchors.fill: parent
                spacing: playlistSpacing * scaleFactor

                Text {
                    text: "Playlist: " + (popup.playlistName || "Unknown Playlist")
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    color: "#000000"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "New Name"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    color: "#000000"
                    Layout.alignment: Qt.AlignHCenter
                }

                TextField {
                    id: renameField
                    placeholderText: "New playlist name"
                    placeholderTextColor: "#666666"
                    color: "#000000"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    Layout.fillWidth: true
                    Layout.leftMargin: playlistItemMargin * scaleFactor
                    Layout.rightMargin: playlistItemMargin * scaleFactor
                    background: Rectangle {
                        color: "#e0e0e0"
                        radius: 5
                    }
                }

                Text {
                    text: "New Description (Optional)"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    color: "#000000"
                    Layout.alignment: Qt.AlignHCenter
                }

                TextField {
                    id: descriptionField
                    placeholderText: "Description"
                    placeholderTextColor: "#666666"
                    color: "#000000"
                    font.pixelSize: playlistItemFontSize * scaleFactor
                    Layout.fillWidth: true
                    Layout.leftMargin: playlistItemMargin * scaleFactor
                    Layout.rightMargin: playlistItemMargin * scaleFactor
                    background: Rectangle {
                        color: "#e0e0e0"
                        radius: 5
                    }
                }

                Button {
                    text: "Rename"
                    Layout.fillWidth: true
                    Layout.leftMargin: playlistItemMargin * scaleFactor
                    Layout.rightMargin: playlistItemMargin * scaleFactor
                    background: Rectangle {
                        color: "#e0e0e0"
                        radius: 5
                    }
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: playlistItemFontSize * scaleFactor
                        color: "#000000"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (playlistViewModel.isAuthenticated) {
                            var newName = renameField.text.trim();
                            var newDescription = descriptionField.text.trim();
                            if (newName !== "" && newName !== popup.playlistName) {
                                playlistViewModel.updatePlaylist(popup.playlistId, newName, newDescription);
                                popup.close();
                            }
                        } else {
                            notificationPopup.text = "Please login to rename a playlist";
                            notificationPopup.color = "#F44336";
                            notificationPopup.open();
                        }
                    }
                }

                Button {
                    text: "Delete"
                    Layout.fillWidth: true
                    Layout.leftMargin: playlistItemMargin * scaleFactor
                    Layout.rightMargin: playlistItemMargin * scaleFactor
                    background: Rectangle {
                        color: "#e0e0e0"
                        radius: 5
                    }
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: playlistItemFontSize * scaleFactor
                        color: "#000000"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (playlistViewModel.isAuthenticated) {
                            playlistViewModel.deletePlaylist(popup.playlistId);
                            popup.close();
                        } else {
                            notificationPopup.text = "Please login to delete a playlist";
                            notificationPopup.color = "#F44336";
                            notificationPopup.open();
                        }
                    }
                }
            }
        }

        Connections {
            target: playlistViewModel
            function onErrorOccurred(error) {
                notificationPopup.text = error;
                notificationPopup.color = "#F44336";
                notificationPopup.open();
            }

            function onPlaylistCreated(playlistId) {
                notificationPopup.text = "Playlist created successfully (ID: " + playlistId + ")";
                notificationPopup.color = "#4CAF50";
                notificationPopup.open();
            }

            function onPlaylistUpdated(playlistId) {
                notificationPopup.text = "Playlist updated successfully (ID: " + playlistId + ")";
                notificationPopup.color = "#4CAF50";
                notificationPopup.open();
            }

            function onPlaylistDeleted(playlistId) {
                notificationPopup.text = "Playlist deleted successfully (ID: " + playlistId + ")";
                notificationPopup.color = "#4CAF50";
                notificationPopup.open();
            }

            function onSongsLoaded(playlistId, songs, message) {
                AppState.setState({
                    mediaFiles: songs
                });
                console.log("Songs loaded for playlist ID:", playlistId, "Count:", songs.length);
            }
        }
    }

    Component.onCompleted: {
        if (playlistViewModel.isAuthenticated) {
            playlistViewModel.loadPlaylists();
        } else {
            notificationPopup.text = "Please login to load playlists";
            notificationPopup.color = "#F44336";
            notificationPopup.open();
        }
        console.log("PlaylistView: Component completed at", new Date().toLocaleString(Qt.locale(), "hh:mm AP"));
    }
}
