import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import "./Components"

Item {
    property real scaleFactor: parent ? Math.min(parent.width / 1280, parent.height / 720) : 1.0
    property real topControlButtonSize: 80
    property real topControlIconSize: 40
    property real topControlSpacing: 25
    property real topControlMargin: 15
    property real formFieldHeight: 50
    property real formFieldFontSize: 20
    property real formSpacing: 15
    property real formMargin: 25
    property real formWidth: 350

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"

        ColumnLayout {
            anchors.centerIn: parent
            width: formWidth * scaleFactor
            spacing: formSpacing * scaleFactor

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: topControlMargin * scaleFactor
                spacing: topControlSpacing * scaleFactor

                HoverButton {
                    Layout.preferredWidth: topControlButtonSize * scaleFactor
                    Layout.preferredHeight: topControlButtonSize * scaleFactor
                    flat: true
                    onClicked: {
                        NavigationManager.goBack();
                        console.log("Back button clicked");
                    }
                    Image {
                        source: "qrc:/Assets/back.png"
                        width: topControlIconSize * scaleFactor
                        height: topControlIconSize * scaleFactor
                        anchors.centerIn: parent
                    }
                }

                Text {
                    text: "Register"
                    font.pixelSize: 36 * scaleFactor
                    font.bold: true
                    color: "#000000"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                radius: 25 * scaleFactor
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
                radius: 25 * scaleFactor
                color: "#e0e0e0"

                TextField {
                    id: nameField
                    anchors.fill: parent
                    anchors.margins: 8 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    color: "#333333"
                    placeholderText: "Full Name"
                    placeholderTextColor: "#666666"
                    verticalAlignment: Text.AlignVCenter
                    background: null
                    onFocusChanged: {
                        console.log("Name field focus:", focus);
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                radius: 25 * scaleFactor
                color: "#e0e0e0"

                TextField {
                    id: dobField
                    anchors.fill: parent
                    anchors.margins: 8 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    color: "#333333"
                    placeholderText: "Date of Birth (YYYY-MM-DD)"
                    placeholderTextColor: "#666666"
                    verticalAlignment: Text.AlignVCenter
                    background: null
                    validator: RegularExpressionValidator {
                        regularExpression: /\d{4}-\d{2}-\d{2}/
                    } // Validate YYYY-MM-DD format
                    onFocusChanged: {
                        console.log("Date of Birth field focus:", focus);
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                radius: 25 * scaleFactor
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

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                radius: 25 * scaleFactor
                color: "#e0e0e0"

                TextField {
                    id: confirmPasswordField
                    anchors.fill: parent
                    anchors.margins: 8 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    color: "#333333"
                    placeholderText: "Confirm Password"
                    placeholderTextColor: "#666666"
                    verticalAlignment: Text.AlignVCenter
                    echoMode: TextInput.Password
                    background: null
                    onFocusChanged: {
                        console.log("Confirm Password field focus:", focus);
                    }
                }
            }

            HoverButton {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                text: "Register"
                onClicked: {
                    if (passwordField.text === confirmPasswordField.text) {
                        authViewModel.registerUser(emailField.text, passwordField.text, nameField.text, dobField.text);
                        console.log("Register button clicked, email:", emailField.text);
                    } else {
                        notificationPopup.message = "Passwords do not match";
                        notificationPopup.color = "#F44336";
                        notificationPopup.open();
                    }
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
                text: "Already have an account? Login"
                font.pixelSize: 14 * scaleFactor
                color: "#0078D7"
                Layout.alignment: Qt.AlignHCenter
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#005BB5"
                    onExited: parent.color = "#0078D7"
                    onClicked: {
                        NavigationManager.navigateTo("qrc:/Source/View/LoginView.qml");
                        console.log("Navigate to LoginView");
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
        function onRegisterFinished(success, message) {
            notificationPopup.message = message;
            notificationPopup.color = success ? "#4CAF50" : "#F44336";
            notificationPopup.open();
            if (success) {
                NavigationManager.navigateTo("qrc:/Source/View/LoginView.qml");
            }
        }
    }

    Component.onCompleted: {
        console.log("RegisterView: Component completed");
    }
}
