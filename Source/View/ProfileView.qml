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
    property real formHeight: 550

    function formatDOB(dateStr) {
        if (!dateStr) {
            return {
                day: "01",
                month: "01",
                year: "2000"
            };
        }
        let date = new Date(dateStr);
        if (!isNaN(date)) {
            let day = ("0" + date.getDate()).slice(-2);
            let month = ("0" + (date.getMonth() + 1)).slice(-2);
            let year = date.getFullYear();
            return {
                day: day,
                month: month,
                year: year.toString()
            };
        }
        if (/\d{2}\/\d{2}\/\d{4}/.test(dateStr)) {
            let parts = dateStr.split("/");
            return {
                day: parts[0],
                month: parts[1],
                year: parts[2]
            };
        }
        console.log("Invalid date format in formatDOB:", dateStr);
        return {
            day: "01",
            month: "01",
            year: "2000"
        };
    }

    function parseDOBToSend(day, month, year) {
        if (!day || !month || !year) {
            console.log("Invalid DOB components for sending:", day, month, year);
            return AppState.dateOfBirth; // Keep original value if invalid
        }
        let dobStr = `${day}/${month}/${year}`;
        if (!/\d{2}\/\d{2}\/\d{4}/.test(dobStr)) {
            console.log("Invalid DOB format for sending:", dobStr);
            return AppState.dateOfBirth;
        }
        return `${year}-${month}-${day}`; // YYYY-MM-DD
    }

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
                        text: AppState.email
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
                        text: AppState.name
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

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8 * scaleFactor
                        spacing: 5 * scaleFactor

                        ComboBox {
                            id: dayComboBox
                            Layout.preferredWidth: (parent.width - 10 * scaleFactor) / 3
                            Layout.fillHeight: true
                            font.pixelSize: formFieldFontSize * scaleFactor
                            model: Array.from({
                                length: 31
                            }, (_, i) => ("0" + (i + 1)).slice(-2)) // 01 to 31
                            currentIndex: parseInt(formatDOB(AppState.dateOfBirth).day) - 1
                            background: Rectangle {
                                color: "transparent"
                            }
                            contentItem: Text {
                                text: dayComboBox.displayText
                                font: dayComboBox.font
                                color: "#333333"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                            onActivated: {
                                console.log("Day selected:", displayText);
                            }
                        }

                        ComboBox {
                            id: monthComboBox
                            Layout.preferredWidth: (parent.width - 10 * scaleFactor) / 3
                            Layout.fillHeight: true
                            font.pixelSize: formFieldFontSize * scaleFactor
                            model: Array.from({
                                length: 12
                            }, (_, i) => ("0" + (i + 1)).slice(-2)) // 01 to 12
                            currentIndex: parseInt(formatDOB(AppState.dateOfBirth).month) - 1
                            background: Rectangle {
                                color: "transparent"
                            }
                            contentItem: Text {
                                text: monthComboBox.displayText
                                font: monthComboBox.font
                                color: "#333333"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                            onActivated: {
                                console.log("Month selected:", displayText);
                            }
                        }

                        ComboBox {
                            id: yearComboBox
                            Layout.preferredWidth: (parent.width - 10 * scaleFactor) / 3
                            Layout.fillHeight: true
                            font.pixelSize: formFieldFontSize * scaleFactor
                            model: Array.from({
                                length: 100
                            }, (_, i) => (2025 - i).toString()) // From 2025 to 1926
                            currentIndex: 2025 - parseInt(formatDOB(AppState.dateOfBirth).year)
                            background: Rectangle {
                                color: "transparent"
                            }
                            contentItem: Text {
                                text: yearComboBox.displayText
                                font: yearComboBox.font
                                color: "#333333"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                            onActivated: {
                                console.log("Year selected:", displayText);
                            }
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
                        text: "••••••••"
                        enabled: false
                        placeholderText: "Password"
                        placeholderTextColor: "#666666"
                        verticalAlignment: Text.AlignVCenter
                        background: null
                    }
                }

                Text {
                    text: "Change Password"
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
                            changePasswordPopup.open();
                            console.log("Change Password clicked, opening popup");
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
                        let dobToSend = parseDOBToSend(dayComboBox.currentText, monthComboBox.currentText, yearComboBox.currentText);
                        console.log("Sending DOB to updateProfile:", dobToSend);
                        authViewModel.updateProfile(AppState.userId, nameField.text, dobToSend, "", "");
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
        id: changePasswordPopup
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 350 * scaleFactor
        height: 450 * scaleFactor
        modal: true
        focus: true

        background: Rectangle {
            color: "#ffffff"
            radius: 15 * scaleFactor
            border.color: "#e0e0e0"
            border.width: 2 * scaleFactor
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20 * scaleFactor
            spacing: formSpacing * scaleFactor

            Text {
                text: "Change Password"
                font.pixelSize: 24 * scaleFactor
                font.bold: true
                color: "#000000"
                Layout.alignment: Qt.AlignHCenter
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
                    placeholderText: "New Password"
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

            RowLayout {
                Layout.fillWidth: true
                spacing: 10 * scaleFactor

                HoverButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    text: "Cancel"
                    defaultColor: "#e0e0e0"
                    hoverColor: "#cccccc"
                    radius: 15 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    onClicked: {
                        currentPasswordField.text = "";
                        newPasswordField.text = "";
                        confirmPasswordField.text = "";
                        changePasswordPopup.close();
                        console.log("Cancel change password clicked");
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#333333"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                HoverButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    text: "Confirm"
                    defaultColor: "#212121"
                    hoverColor: "#424242"
                    radius: 15 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    onClicked: {
                        if (newPasswordField.text !== "" && newPasswordField.text !== confirmPasswordField.text) {
                            notificationPopup.message = "Passwords do not match";
                            notificationPopup.color = "#F44336";
                            notificationPopup.open();
                        } else if (currentPasswordField.text === "") {
                            notificationPopup.message = "Current Password is required";
                            notificationPopup.color = "#F44336";
                            notificationPopup.open();
                        } else {
                            // Only send password fields for password change
                            authViewModel.updateProfile(AppState.userId, "", "", currentPasswordField.text, newPasswordField.text);
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
                changePasswordPopup.close();
                AppState.setName(nameField.text);
                let dobToSave = parseDOBToSend(dayComboBox.currentText, monthComboBox.currentText, yearComboBox.currentText);
                console.log("Saving DOB to AppState:", dobToSave);
                AppState.setDateOfBirth(dobToSave);
            }
        }
    }

    Component.onCompleted: {
        console.log("ProfileView: Component completed, AppState.dateOfBirth:", AppState.dateOfBirth);
    }
}
