import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import "../Components"
import "../Helper"
import AppState 1.0

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
                    text: "Login"
                    font.pixelSize: 34 * scaleFactor
                    font.family: "Arial"
                    font.weight: Font.Medium
                    color: "#1a202c"
                    Layout.alignment: Qt.AlignHCenter
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
                    radius: 12 * scaleFactor
                    color: "#f6f8fa"
                    border.color: emailField.activeFocus ? "#3182ce" : "#d0d7de"
                    border.width: emailField.activeFocus ? 2 * scaleFactor : 1 * scaleFactor

                    TextField {
                        id: emailField
                        anchors.fill: parent
                        anchors.margins: 8 * scaleFactor
                        font.pixelSize: formFieldFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#2d3748"
                        placeholderText: "Email"
                        placeholderTextColor: "#a0aec0"
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
                    radius: 12 * scaleFactor
                    color: "#f6f8fa"
                    border.color: passwordField.activeFocus ? "#3182ce" : "#d0d7de"
                    border.width: passwordField.activeFocus ? 2 * scaleFactor : 1 * scaleFactor

                    TextField {
                        id: passwordField
                        anchors.fill: parent
                        anchors.margins: 8 * scaleFactor
                        font.pixelSize: formFieldFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#2d3748"
                        placeholderText: "Password"
                        placeholderTextColor: "#a0aec0"
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
                    defaultColor: "#2b6cb0"
                    hoverColor: "#3182ce"
                    radius: 12 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    font.family: "Arial"
                    onClicked: {
                        authViewModel.loginUser(emailField.text, passwordField.text);
                        console.log("Login button clicked, email:", emailField.text);
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

                Text {
                    text: "Don't have an account? Register"
                    font.pixelSize: 15 * scaleFactor
                    font.family: "Arial"
                    color: "#2b6cb0"
                    Layout.alignment: Qt.AlignHCenter
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            parent.color = "#3182ce";
                            parent.font.underline = true;
                        }
                        onExited: {
                            parent.color = "#2b6cb0";
                            parent.font.underline = false;
                        }
                        onClicked: {
                            NavigationManager.navigateTo("qrc:/Source/View/Authentication/RegisterView.qml");
                            console.log("Navigate to RegisterView");
                        }
                    }
                }

                Text {
                    text: "Skip"
                    font.pixelSize: 15 * scaleFactor
                    font.family: "Arial"
                    color: "#2b6cb0"
                    Layout.alignment: Qt.AlignHCenter
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            parent.color = "#3182ce";
                            parent.font.underline = true;
                        }
                        onExited: {
                            parent.color = "#2b6cb0";
                            parent.font.underline = false;
                        }
                        onClicked: {
                            NavigationManager.navigateTo("qrc:/Source/View/Client/MediaPlayerView.qml");
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
            notificationRect.message = success ? "Login successful" : message || "Login failed. Please try again";
            notificationRect.notificationColor = success ? "#48bb78" : "#e53e3e";
            notificationRect.isPersistent = !success;
            notificationRect.isVisible = true;
            if (success) {
                // Check role from AppState
                let userRole = AppState.role;
                console.log("User role:", userRole);
                if (userRole === "admin") {
                    NavigationManager.navigateTo("qrc:/Source/View/Admin/AdminDashboard.qml");
                    console.log("Navigate to AdminView");
                } else {
                    NavigationManager.navigateTo("qrc:/Source/View/Client/MediaPlayerView.qml");
                    console.log("Navigate to MediaPlayerView");
                }
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
            NavigationManager.navigateTo(AppState.role === "admin" ? "qrc:/Source/View/Admin.qml" : "qrc:/Source/View/MediaPlayerView.qml");
        }
    }

    Component.onCompleted: {
        console.log("LoginView: Component completed");
    }
}
