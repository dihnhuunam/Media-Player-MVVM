import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import QtQuick.Dialogs 6.8
import "./Components"
import AppState 1.0

Item {
    property real scaleFactor: parent ? Math.min(parent.width / 1024, parent.height / 600) : 1.0
    property real topControlButtonSize: 80
    property real topControlIconSize: 40
    property real topControlSpacing: 25
    property real topControlMargin: 15
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
                        text: "Profile"
                        font.pixelSize: 34 * scaleFactor
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
                        text: authViewModel.userEmail
                        enabled: false
                        placeholderText: "Email"
                        placeholderTextColor: "#666666"
                        verticalAlignment: Text.AlignVCenter
                        background: null
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
                        text: authViewModel.userName
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
                        text: authViewModel.userDOB
                        placeholderText: "Date of Birth (YYYY-MM-DD)"
                        placeholderTextColor: "#666666"
                        verticalAlignment: Text.AlignVCenter
                        background: null
                        validator: RegularExpressionValidator {
                            regularExpression: /\d{4}-\d{2}-\d{2}/
                        }
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
                        id: currentPasswordField
                        anchors.fill: parent
                        anchors.margins: 8 * scaleFactor
                        font.pixelSize: formFieldFontSize * scaleFactor
                        color: "#333333"
                        placeholderText: "Current Password"
                        placeholderTextColor: "#666666"
                        verticalAlignment: Text.AlignVCenter
                        echoMode: TextInput.Password
                        background: null
                        onFocusChanged: {
                            console.log("Current Password field focus:", focus);
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    radius: 25 * scaleFactor
                    color: "#e0e0e0"

                    TextField {
                        id: newPasswordField
                        anchors.fill: parent
                        anchors.margins: 8 * scaleFactor
                        font.pixelSize: formFieldFontSize * scaleFactor
                        color: "#333333"
                        placeholderText: "New Password (optional)"
                        placeholderTextColor: "#666666"
                        verticalAlignment: Text.AlignVCenter
                        echoMode: TextInput.Password
                        background: null
                        onFocusChanged: {
                            console.log("New Password field focus:", focus);
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
                        placeholderText: "Confirm New Password"
                        placeholderTextColor: "#666666"
                        verticalAlignment: Text.AlignVCenter
                        echoMode: TextInput.Password
                        background: null
                        enabled: newPasswordField.text !== ""
                        onFocusChanged: {
                            console.log("Confirm Password field focus:", focus);
                        }
                    }
                }

                HoverButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    text: "Update Profile"
                    defaultColor: "#212121"
                    hoverColor: "#424242"
                    radius: 30 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    onClicked: {
                        if (newPasswordField.text !== "" && newPasswordField.text !== confirmPasswordField.text) {
                            notificationPopup.message = "Passwords do not match";
                            notificationPopup.color = "#F44336";
                            notificationPopup.open();
                        } else {
                            authViewModel.updateProfile(nameField.text, dobField.text, currentPasswordField.text, newPasswordField.text);
                            console.log("Update profile clicked");
                        }
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
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
        function onProfileUpdateFinished(success, message) {
            notificationPopup.message = message;
            notificationPopup.color = success ? "#4CAF50" : "#F44336";
            notificationPopup.open();
            if (success) {
                currentPasswordField.text = "";
                newPasswordField.text = "";
                confirmPasswordField.text = "";
            }
        }
    }

    Component.onCompleted: {
        console.log("ProfileView: Component completed");
    }
}
