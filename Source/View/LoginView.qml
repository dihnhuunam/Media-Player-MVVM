import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import "./Components"

Item {
    property real scaleFactor: parent ? Math.min(parent.width / 1024, parent.height / 600) : 1.0
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

            Text {
                text: "Login"
                font.pixelSize: 36 * scaleFactor
                font.bold: true
                color: "#000000"
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                radius: 30 * scaleFactor
                color: "#e0e0e0"

                TextField {
                    id: emailField
                    anchors.fill: parent
                    anchors.margins: 8 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    color: "#333333"
                    placeholderText: "Email"
                    placeholderTextColor: "#666666"
                    verticalAlignment: Text.AlignVCenter
                    background: null
                    onFocusChanged: {
                        console.log("Email field focus:", focus);
                    }
                }
            }

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

            HoverButton {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                text: "Login"
                onClicked: {
                    authViewModel.loginUser(emailField.text, passwordField.text);
                    console.log("Login button clicked, email:", emailField.text);
                }
                background: Rectangle {
                    color: parent.hovered ? "#005BB5" : "#0078D7" // Xanh đậm khi hover, xanh dương khi bình thường
                    radius: 30 * scaleFactor
                }
                contentItem: Text {
                    text: parent.text
                    color: "#FFFFFF" // Chữ trắng
                    font.pixelSize: formFieldFontSize * scaleFactor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

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
                        console.log("Play local music clicked");
                    }
                }
            }

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

    Popup {
        id: notificationPopup
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 300 * scaleFactor
        height: 100 * scaleFactor
        modal: true
        focus: true
        property string message: ""
        property color color: "#4CAF50"

        background: Rectangle {
            color: notificationPopup.color
            radius: 5
        }

        Text {
            anchors.centerIn: parent
            text: notificationPopup.message
            font.pixelSize: formFieldFontSize * scaleFactor
            color: "#FFFFFF"
        }

        Timer {
            interval: 2000
            running: notificationPopup.visible
            onTriggered: notificationPopup.close()
        }
    }

    Connections {
        target: authViewModel
        function onLoginFinished(success, message) {
            notificationPopup.message = message;
            notificationPopup.color = success ? "#4CAF50" : "#F44336";
            notificationPopup.open();
            if (success) {
                NavigationManager.navigateTo("qrc:/Source/View/PlaylistView.qml");
            }
        }
    }

    Component.onCompleted: {
        console.log("LoginView: Component completed");
    }
}
