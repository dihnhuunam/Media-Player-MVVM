import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "./Components"
import AppState 1.0

Item {
    property real scaleFactor: parent ? Math.min(parent.width / 1024, parent.height / 600) : 1.0
    property real formFieldHeight: 55
    property real formFieldFontSize: 22
    property real formSpacing: 18
    property real formWidth: 385
    property real formHeight: 650 // Tăng chiều cao để chứa ListView
    property var selectedFilePaths: []

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

        Rectangle {
            anchors.centerIn: parent
            width: formWidth * scaleFactor
            height: formHeight * scaleFactor
            radius: 20 * scaleFactor
            border.color: "#d0d7de"
            border.width: 1 * scaleFactor
            color: "#ffffff"

            ColumnLayout {
                anchors.centerIn: parent
                width: formWidth * scaleFactor - 20 * scaleFactor
                spacing: formSpacing * scaleFactor

                Text {
                    text: "Upload Music Files"
                    font.pixelSize: 34 * scaleFactor
                    font.family: "Arial"
                    font.weight: Font.Medium
                    color: "#1a202c"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 15 * scaleFactor
                }

                Rectangle {
                    id: notificationRect
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    color: notificationRect.notificationColor
                    radius: 8 * scaleFactor
                    visible: notificationRect.isVisible

                    property bool isVisible: false
                    property bool isPersistent: false
                    property string message: ""
                    property color notificationColor: "#48bb78"

                    Text {
                        anchors.centerIn: parent
                        text: notificationRect.message
                        font.pixelSize: formFieldFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#ffffff"
                        wrapMode: Text.Wrap
                    }

                    Timer {
                        interval: 2000
                        running: notificationRect.isVisible && !notificationRect.isPersistent
                        onTriggered: {
                            notificationRect.isVisible = false;
                        }
                    }
                }

                Rectangle {
                    id: titleField
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    radius: 12 * scaleFactor
                    color: "#f6f8fa"
                    border.color: titleInput.activeFocus ? "#3182ce" : "#d0d7de"
                    border.width: titleInput.activeFocus ? 2 * scaleFactor : 1 * scaleFactor

                    TextField {
                        id: titleInput
                        anchors.fill: parent
                        anchors.margins: 8 * scaleFactor
                        font.pixelSize: formFieldFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#2d3748"
                        placeholderText: "Song Title"
                        placeholderTextColor: "#a0aec0"
                        verticalAlignment: Text.AlignVCenter
                        background: null
                    }
                }

                Rectangle {
                    id: genresField
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    radius: 12 * scaleFactor
                    color: "#f6f8fa"
                    border.color: genresInput.activeFocus ? "#3182ce" : "#d0d7de"
                    border.width: genresInput.activeFocus ? 2 * scaleFactor : 1 * scaleFactor

                    TextField {
                        id: genresInput
                        anchors.fill: parent
                        anchors.margins: 8 * scaleFactor
                        font.pixelSize: formFieldFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#2d3748"
                        placeholderText: "Genres (comma-separated)"
                        placeholderTextColor: "#a0aec0"
                        verticalAlignment: Text.AlignVCenter
                        background: null
                    }
                }

                Rectangle {
                    id: artistsField
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    radius: 12 * scaleFactor
                    color: "#f6f8fa"
                    border.color: artistsInput.activeFocus ? "#3182ce" : "#d0d7de"
                    border.width: artistsInput.activeFocus ? 2 * scaleFactor : 1 * scaleFactor

                    TextField {
                        id: artistsInput
                        anchors.fill: parent
                        anchors.margins: 8 * scaleFactor
                        font.pixelSize: formFieldFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#2d3748"
                        placeholderText: "Artists (comma-separated)"
                        placeholderTextColor: "#a0aec0"
                        verticalAlignment: Text.AlignVCenter
                        background: null
                    }
                }

                HoverButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    text: "Select Music Files"
                    defaultColor: "#2b6cb0"
                    hoverColor: "#3182ce"
                    radius: 12 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    font.family: "Arial"
                    onClicked: {
                        fileDialog.open();
                        console.log("AdminUploadFile: Select Files button clicked");
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

                // Thêm ListView để hiển thị các file đã chọn
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100 * scaleFactor
                    radius: 12 * scaleFactor
                    color: "#f6f8fa"
                    border.color: "#d0d7de"
                    border.width: 1 * scaleFactor
                    clip: true

                    ListView {
                        id: selectedFilesView
                        anchors.fill: parent
                        anchors.margins: 8 * scaleFactor
                        model: selectedFilePaths
                        interactive: true
                        spacing: 4 * scaleFactor

                        delegate: Text {
                            text: modelData.split("/").pop() // Hiển thị tên file thay vì toàn bộ đường dẫn
                            font.pixelSize: 16 * scaleFactor
                            font.family: "Arial"
                            color: "#2d3748"
                            width: parent.width
                            elide: Text.ElideMiddle
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "No files selected"
                            font.pixelSize: 16 * scaleFactor
                            font.family: "Arial"
                            color: "#2d3748"
                            visible: selectedFilesView.count === 0
                        }
                    }
                }

                HoverButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    text: "Upload"
                    defaultColor: "#2b6cb0"
                    hoverColor: "#3182ce"
                    radius: 12 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    font.family: "Arial"
                    onClicked: {
                        if (titleInput.text === "" || genresInput.text === "" || artistsInput.text === "" || selectedFilePaths.length === 0) {
                            notificationRect.message = "Please fill in all fields and select at least one file";
                            notificationRect.notificationColor = "#e53e3e";
                            notificationRect.isPersistent = true;
                            notificationRect.isVisible = true;
                            console.log("AdminUploadFile: Missing required fields or files");
                        } else {
                            for (let i = 0; i < selectedFilePaths.length; i++) {
                                adminViewModel.uploadSong(titleInput.text, genresInput.text, artistsInput.text, selectedFilePaths[i]);
                                console.log("AdminUploadFile: Upload initiated for", selectedFilePaths[i]);
                            }
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

                HoverButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    text: "Back"
                    defaultColor: "#2b6cb0"
                    hoverColor: "#3182ce"
                    radius: 12 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    font.family: "Arial"
                    onClicked: {
                        NavigationManager.navigateTo("qrc:/Source/View/AdminDashboard.qml");
                        console.log("AdminUploadFile: Back to AdminDashboardView");
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

        FileDialog {
            id: fileDialog
            title: "Select Music Files"
            nameFilters: ["Music files (*.mp3 *.wav *.m4a)"]
            fileMode: FileDialog.OpenFiles
            onAccepted: {
                if (fileDialog.selectedFiles && fileDialog.selectedFiles.length > 0) {
                    selectedFilePaths = fileDialog.selectedFiles.map(file => file.toString().replace(/^file:\/\//, "").replace(/^file:/, ""));
                    console.log("AdminUploadFile: Selected files:", selectedFilePaths);
                } else {
                    selectedFilePaths = [];
                    console.log("AdminUploadFile: No files selected");
                }
            }
            onRejected: {
                selectedFilePaths = [];
                console.log("AdminUploadFile: File selection canceled");
            }
        }

        Connections {
            target: adminViewModel
            function onUploadFinished(success, message) {
                notificationRect.message = message;
                notificationRect.notificationColor = success ? "#48bb78" : "#e53e3e";
                notificationRect.isPersistent = !success;
                notificationRect.isVisible = true;
                console.log("AdminUploadFile: Upload finished, success:", success, "message:", message);
                if (success) {
                    selectedFilePaths = [];
                    titleInput.text = "";
                    genresInput.text = "";
                    artistsInput.text = "";
                }
            }
        }

        Component.onCompleted: {
            console.log("AdminUploadFileView: Component completed");
        }
    }
}
