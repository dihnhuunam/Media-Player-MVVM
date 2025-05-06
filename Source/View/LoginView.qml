import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Components"

Item {
    property real scaleFactor: parent ? Math.min(parent.width / 1024, parent.height / 600) : 1.0

    // Properties for Form
    property real formFieldHeight: 60
    property real formFieldFontSize: 24
    property real formSpacing: 20
    property real formMargin: 30
    property real formWidth: 400

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"

        ColumnLayout {
            anchors.centerIn: parent
            width: formWidth * scaleFactor
            spacing: formSpacing * scaleFactor

            // Title
            Text {
                text: "Login"
                font.pixelSize: 36 * scaleFactor
                font.bold: true
                color: "#000000"
                Layout.alignment: Qt.AlignHCenter
            }

            // Username Field
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                radius: 30 * scaleFactor
                color: "#e0e0e0"

                TextField {
                    id: usernameField
                    anchors.fill: parent
                    anchors.margins: 8 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    color: "#333333"
                    placeholderText: "Username"
                    placeholderTextColor: "#666666"
                    verticalAlignment: Text.AlignVCenter
                    background: null
                    onFocusChanged: {
                        console.log("Username field focus:", focus);
                    }
                }
            }

            // Password Field
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                radius: 30 * scaleFactor
                color: "#e0e0e0"

                TextField {
                    id: passwordField
                    anchors.fill: parent
                    anchors.margins: 8 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    color: "#333333"
                    placeholderText: "Password"
                    placeholderTextColor: "#666666"
                    verticalAlignment: Text.AlignVCenter
                    echoMode: TextInput.Password
                    background: null
                    onFocusChanged: {
                        console.log("Password field focus:", focus);
                    }
                }
            }

            // Submit Button
            HoverButton {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                text: "Login"
                flat: false
                background: Rectangle {
                    radius: 30 * scaleFactor
                    color: "#e0e0e0"
                }
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: formFieldFontSize * scaleFactor
                    color: "#000000"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    console.log("Login button clicked, username:", usernameField.text);
                    NavigationManager.navigateTo("qrc:/Source/View/PlaylistView.qml");
                }
            }

            // Play Local Music Link
            Text {
                text: "Play local music"
                font.pixelSize: 16 * scaleFactor
                color: "#0078D7"
                Layout.alignment: Qt.AlignHCenter
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#005BB5"
                    onExited: parent.color = "#0078D7"
                    onClicked: {
                        NavigationManager.navigateTo("qrc:/Source/View/MediaPlayerView.qml");
                        console.log("Play local music clicked, navigated to MediaPlayerView");
                    }
                }
            }

            // Register Link
            Text {
                text: "Don't have an account? Register"
                font.pixelSize: 16 * scaleFactor
                color: "#0078D7"
                Layout.alignment: Qt.AlignHCenter
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#005BB5"
                    onExited: parent.color = "#0078D7"
                    onClicked: {
                        NavigationManager.navigateTo("qrc:/Source/View/RegisterView.qml");
                        console.log("Navigate to RegisterView");
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("LoginView: Component completed");
    }
}
