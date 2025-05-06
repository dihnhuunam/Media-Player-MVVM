import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Components"

Item {
    property real scaleFactor: parent ? Math.min(parent.width / 1280, parent.height / 720) : 1.0

    // Properties for Top Controls
    property real topControlButtonSize: 80
    property real topControlIconSize: 40
    property real topControlSpacing: 25
    property real topControlMargin: 15

    // Properties for Form
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

            // Back Button and Title
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

            // Username Field
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                radius: 25 * scaleFactor
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

            // Full Name Field
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                radius: 25 * scaleFactor
                color: "#e0e0e0"

                TextField {
                    id: fullNameField
                    anchors.fill: parent
                    anchors.margins: 8 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    color: "#333333"
                    placeholderText: "Full Name"
                    placeholderTextColor: "#666666"
                    verticalAlignment: Text.AlignVCenter
                    background: null
                    onFocusChanged: {
                        console.log("Full Name field focus:", focus);
                    }
                }
            }

            // Date of Birth Field
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                radius: 25 * scaleFactor
                color: "#e0e0e0"

                TextField {
                    id: dateOfBirthField
                    anchors.fill: parent
                    anchors.margins: 8 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    color: "#333333"
                    placeholderText: "Date of Birth (DD/MM/YYYY)"
                    placeholderTextColor: "#666666"
                    verticalAlignment: Text.AlignVCenter
                    background: null
                    onFocusChanged: {
                        console.log("Date of Birth field focus:", focus);
                    }
                }
            }

            // Password Field
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

            // Confirm Password Field
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

            // Submit Button
            HoverButton {
                Layout.fillWidth: true
                Layout.preferredHeight: formFieldHeight * scaleFactor
                text: "Register"
                flat: false
                background: Rectangle {
                    radius: 25 * scaleFactor
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
                    console.log("Register button clicked, username:", usernameField.text, "full name:", fullNameField.text, "date of birth:", dateOfBirthField.text);
                    NavigationManager.navigateTo("qrc:/Source/View/LoginView.qml");
                }
            }

            // Login Link
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

    Component.onCompleted: {
        console.log("RegisterView: Component completed");
    }
}
