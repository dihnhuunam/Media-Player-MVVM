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

    // Properties for Media File Info
    property real mediaTitleFontSize: 24
    property real mediaItemHeight: 50
    property real mediaItemFontSize: 16
    property real mediaSpacing: 6
    property real mediaItemMargin: 30

    // Properties for Pagination
    property int itemsPerPage: 25
    property int currentPage: 0
    property string playlistName: AppState.currentPlaylistName
    property var mediaFiles: AppState.currentMediaFiles
    property int totalPages: Math.ceil(mediaFiles.length / itemsPerPage)

    FileDialog {
        id: fileDialog
        title: "Select Music Files"
        nameFilters: ["Media files (*.mp3 *.wav *.m4a)"]
        fileMode: FileDialog.OpenFiles
        onAccepted: {
            console.log("Selected files:", fileDialog.selectedFiles);
        }
        onRejected: {
            console.log("File selection canceled");
        }
    }

    function getCurrentPageItems() {
        let startIndex = currentPage * itemsPerPage;
        let endIndex = Math.min(startIndex + itemsPerPage, mediaFiles.length);
        return mediaFiles.slice(startIndex, endIndex);
    }

    function formatDuration(milliseconds) {
        if (!milliseconds || milliseconds < 0 || isNaN(milliseconds)) {
            return "0:00";
        }
        let seconds = Math.floor(milliseconds / 1000);
        let minutes = Math.floor(seconds / 60);
        let secs = Math.floor(seconds % 60);
        return minutes + ":" + (secs < 10 ? "0" : "") + secs;
    }

    Timer {
        id: searchDebounceTimer
        interval: 200
        repeat: false
        onTriggered: {
            console.log("Search query:", searchInput.text);
        }
    }

    // Notification Popup
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
            font.pixelSize: mediaItemFontSize * scaleFactor
            color: "#FFFFFF"
        }

        Timer {
            interval: 2000
            running: notificationPopup.visible
            onTriggered: notificationPopup.close()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"

        ColumnLayout {
            anchors.fill: parent
            spacing: mediaSpacing * scaleFactor

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
                        console.log("Back button clicked, navigating back");
                        NavigationManager.goBack();
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
                            text: "Search Songs"
                            color: "#666666"
                            font.pixelSize: topControlSearchFontSize * scaleFactor
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

                // Add Button
                HoverButton {
                    Layout.preferredWidth: topControlButtonSize * scaleFactor
                    Layout.preferredHeight: topControlButtonSize * scaleFactor
                    flat: true
                    onClicked: {
                        fileDialog.open();
                        console.log("Add media clicked");
                    }
                    Image {
                        source: "qrc:/Assets/add.png"
                        width: topControlIconSize * scaleFactor
                        height: topControlIconSize * scaleFactor
                        anchors.centerIn: parent
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

                // Playlist Name
                Text {
                    id: mediaTitle
                    text: playlistName
                    font.pixelSize: mediaTitleFontSize * scaleFactor
                    font.bold: true
                    color: "#000000"
                    Layout.fillWidth: true
                    Layout.leftMargin: mediaItemMargin * scaleFactor
                    Layout.rightMargin: mediaItemMargin * scaleFactor
                }

                // List of Media Files
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
                        color: index % 2 === 0 ? "#f0f0f0" : "#ffffff"

                        RowLayout {
                            anchors.fill: parent
                            spacing: mediaSpacing * scaleFactor

                            // Index
                            Text {
                                text: (currentPage * itemsPerPage + index + 1).toString()
                                font.pixelSize: mediaItemFontSize * scaleFactor
                                color: "#666666"
                                Layout.leftMargin: mediaItemMargin * scaleFactor
                                Layout.alignment: Qt.AlignVCenter
                            }

                            // Title - Artist
                            Text {
                                text: modelData.title + " - " + modelData.artist
                                font.pixelSize: mediaItemFontSize * scaleFactor
                                color: "#333333"
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        NavigationManager.navigateTo("qrc:/Source/View/MediaPlayerView.qml", {
                                            title: modelData.title,
                                            artist: modelData.artist,
                                            playlistName: playlistName
                                        });
                                        console.log("Selected media:", modelData.title, "Navigated to MediaPlayerView");
                                    }
                                }
                            }

                            // Duration
                            Text {
                                text: formatDuration(modelData.duration)
                                font.pixelSize: mediaItemFontSize * scaleFactor
                                color: "#666666"
                                Layout.rightMargin: mediaItemMargin * scaleFactor
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }

                    // Placeholder for empty list
                    Text {
                        anchors.centerIn: parent
                        text: "No songs in this playlist"
                        font.pixelSize: mediaItemFontSize * scaleFactor
                        color: "#666666"
                        visible: mediaFiles.length === 0
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
                    visible: mediaFiles.length > 0

                    HoverButton {
                        text: "Previous"
                        enabled: currentPage > 0
                        Layout.preferredWidth: 100 * scaleFactor
                        Layout.preferredHeight: 40 * scaleFactor
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "#0078D7" : "#666666"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: mediaItemFontSize * scaleFactor
                        }
                        onClicked: {
                            currentPage--;
                            mediaFileView.model = getCurrentPageItems();
                            console.log("Previous page, now:", currentPage + 1);
                        }
                    }

                    Text {
                        text: totalPages > 0 ? ("Page " + (currentPage + 1) + " of " + totalPages) : "No Pages"
                        font.pixelSize: mediaItemFontSize * scaleFactor
                        color: "#333333"
                    }

                    HoverButton {
                        text: "Next"
                        enabled: currentPage < totalPages - 1
                        Layout.preferredWidth: 100 * scaleFactor
                        Layout.preferredHeight: 40 * scaleFactor
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "#0078D7" : "#666666"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: mediaItemFontSize * scaleFactor
                        }
                        onClicked: {
                            currentPage++;
                            mediaFileView.model = getCurrentPageItems();
                            console.log("Next page, now:", currentPage + 1);
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("MediaFileView: Component completed");
    }
}
