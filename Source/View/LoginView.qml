import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import "./Components"

Item {
    property real scaleFactor: parent ? Math.min(parent.width / 1024, parent.height / 600) : 1.0
    property real formFieldHeight: 55
    property real formFieldFontSize: 22
    property real formSpacing: 18
    property real formMargin: 28
    property real formWidth: 385
    property real formHeight: 586

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"

        Rectangle {
            anchors.centerIn: parent
            width: formWidth * scaleFactor
            height: formHeight * scaleFactor 
            radius: 30 * scaleFactor
            border.color: "#e0e0e0"
            border.width: 2 * scaleFactor
            color: "#ffffff"

            ColumnLayout {
                anchors.centerIn: parent
                width: formWidth * scaleFactor - 20 * scaleFactor
                spacing: formSpacing * scaleFactor

                Text {
                    text: "Login"
                    font.pixelSize: 34 * scaleFactor
                    font.bold: true
                    color: "#000000"
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    id: notificationRect
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    color: notificationRect.notificationColor
                    radius: 15 * scaleFactor
                    visible: notificationRect.isVisible

                    property bool isVisible: false
                    property bool isPersistent: false
                    property string message: ""
                    property color notificationColor: "#CC4CAF50"

                    Text {
                        anchors.centerIn: parent
                        text: notificationRect.message
                        font.pixelSize: formFieldFontSize * scaleFactor
                        color: "#FFFFFF"
                        wrapMode: Text.Wrap
                    }

                    Timer {
                        id: notificationTimer
                        interval: 2000
                        running: notificationRect.isVisible && !notificationRect.isPersistent
                        onTriggered: {
                            notificationRect.isVisible = false;
                        }
                    }
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
                    defaultColor: "#212121"
                    hoverColor: "#424242"
                    radius: 30 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    onClicked: {
                        authViewModel.loginUser(emailField.text, passwordField.text);
                        console.log("Login button clicked, email:", emailField.text);
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    text: "Don't have an account? Register"
                    font.pixelSize: 15 * scaleFactor
                    color: "#212121"
                    Layout.alignment: Qt.AlignHCenter
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            parent.color = "#757575";
                            parent.font.underline = true;
                        }
                        onExited: {
                            parent.color = "#212121";
                            parent.font.underline = false;
                        }
                        onClicked: {
                            NavigationManager.navigateTo("qrc:/Source/View/RegisterView.qml");
                            console.log("Navigate to RegisterView");
                        }
                    }
                }

                Text {
                    text: "Skip"
                    font.pixelSize: 15 * scaleFactor
                    color: "#212121"
                    Layout.alignment: Qt.AlignHCenter
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            parent.color = "#757575";
                            parent.font.underline = true;
                        }
                        onExited: {
                            parent.color = "#212121";
                            parent.font.underline = false;
                        }
                        onClicked: {
                            NavigationManager.navigateTo("qrc:/Source/View/MediaPlayerView.qml");
                            console.log("Skip clicked");
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: authViewModel
        function onLoginFinished(success, message) {
            console.log("Login message:", message);
            notificationRect.message = success ? "Login Success" : "Login Failed. Please Try Again";
            notificationRect.notificationColor = success ? "#CC4CAF50" : "#CCF44336";
            notificationRect.isPersistent = !success;
            notificationRect.isVisible = true;
            if (success) {
                navigationTimer.start();
            }
        }
    }

    Timer {
        id: navigationTimer
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            NavigationManager.navigateTo("qrc:/Source/View/MediaPlayerView.qml");
        }
    }

    Component.onCompleted: {
        console.log("LoginView: Component completed");
    }
}
