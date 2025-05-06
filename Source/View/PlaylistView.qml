import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Components"

Item {
    property real scaleFactor: parent ? Math.min(parent.width / 1024, parent.height / 600) : 1.0

    // Properties for Top Controls
    property real topControlButtonSize: 90
    property real topControlIconSize: 45
    property real topControlSearchHeight: 60
    property real topControlSearchRadius: 30
    property real topControlSearchIconSize: 30
    property real topControlSearchFontSize: 24
    property real topControlSpacing: 30
    property real topControlMargin: 18
    property real topControlTopMargin: 20

    // Properties for Playlist Info
    property real playlistItemHeight: 50
    property real playlistItemFontSize: 16
    property real playlistItemMargin: 30
    property real playlistSpacing: 6

    // Sample playlist data (replace with controller later)
    property var playlistNames: ["Playlist 1", "Playlist 2", "Playlist 3"]

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

            // Top Controls
            RowLayout {
                id: topControl
                Layout.topMargin: topControlTopMargin * scaleFactor
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width * 0.8
                Layout.preferredHeight: topControlSearchHeight * scaleFactor
                Layout.alignment: Qt.AlignHCenter
                spacing: topControlSpacing * scaleFactor

                // Back Button
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

                // Search Bar
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

                // Add Button
                HoverButton {
                    Layout.preferredWidth: topControlButtonSize * scaleFactor
                    Layout.preferredHeight: topControlButtonSize * scaleFactor
                    flat: true
                    onClicked: {
                        addPlaylistPopup.open();
                    }
                    Image {
                        source: "qrc:/Assets/add.png"
                        width: topControlIconSize * scaleFactor
                        height: topControlIconSize * scaleFactor
                        anchors.centerIn: parent
                    }
                }
            }

            // List of Playlists
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
                model: playlistNames
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

                        // Index
                        Text {
                            text: (index + 1).toString()
                            font.pixelSize: playlistItemFontSize * scaleFactor
                            color: "#666666"
                            Layout.leftMargin: playlistItemMargin * scaleFactor
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // Playlist Name
                        Text {
                            text: modelData
                            font.pixelSize: playlistItemFontSize * scaleFactor
                            color: "#333333"
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    NavigationManager.navigateTo("qrc:/Source/View/MediaFileView.qml", {
                                        playlistName: modelData,
                                        mediaFiles: [
                                            {
                                                title: "Sample Song 1",
                                                artist: "Artist 1",
                                                duration: 180000
                                            },
                                            {
                                                title: "Sample Song 2",
                                                artist: "Artist 2",
                                                duration: 240000
                                            }
                                        ]
                                    });
                                    console.log("Clicked playlist:", modelData);
                                }
                            }
                        }

                        // More Info Button
                        HoverButton {
                            Layout.preferredWidth: topControlIconSize * scaleFactor
                            Layout.preferredHeight: topControlIconSize * scaleFactor
                            Layout.rightMargin: playlistItemMargin * scaleFactor
                            flat: true
                            onClicked: {
                                popup.playlistName = modelData;
                                renameField.text = modelData;
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
            }
        }

        // Add Playlist Popup
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
                    onAccepted: addButton.clicked()
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
                        if (name !== "") {
                            console.log("Add playlist:", name);
                            addPlaylistPopup.close();
                            newPlaylistNameField.text = "";
                        }
                    }
                }
            }
        }

        // More Info Popup
        Popup {
            id: popup
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: 300 * scaleFactor
            height: 200 * scaleFactor
            modal: true
            focus: true
            background: Rectangle {
                color: "#ffffff"
                border.color: "#cccccc"
                radius: 5
            }

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
                        var newName = renameField.text.trim();
                        if (newName !== "" && newName !== popup.playlistName) {
                            console.log("Rename playlist from", popup.playlistName, "to", newName);
                            popup.close();
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
                        console.log("Delete playlist:", popup.playlistName);
                        popup.close();
                    }
                }
            }
        }
    }
}
