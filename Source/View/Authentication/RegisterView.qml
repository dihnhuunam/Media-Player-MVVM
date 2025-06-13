import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import Qt5Compat.GraphicalEffects
import "../Components"
import "../Helper"

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
            return "2000-01-01";
        }
        let dobStr = `${day}/${month}/${year}`;
        if (!/\d{2}\/\d{2}\/\d{4}/.test(dobStr)) {
            console.log("Invalid DOB format for sending:", dobStr);
            return "2000-01-01";
        }
        return `${year}-${month}-${day}`;
    }

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
                    text: "Register"
                    font.pixelSize: 34 * scaleFactor
                    font.family: "Arial"
                    font.weight: Font.Medium
                    color: "#1a202c"
                    Layout.alignment: Qt.AlignHCenter
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
                    border.color: nameField.activeFocus ? "#3182ce" : "#d0d7de"
                    border.width: nameField.activeFocus ? 2 * scaleFactor : 1 * scaleFactor

                    TextField {
                        id: nameField
                        anchors.fill: parent
                        anchors.margins: 8 * scaleFactor
                        font.pixelSize: formFieldFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#2d3748"
                        placeholderText: "Full Name"
                        placeholderTextColor: "#a0aec0"
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
                    radius: 12 * scaleFactor
                    color: "#ffffff"
                    border.color: dayComboBox.activeFocus || monthComboBox.activeFocus || yearComboBox.activeFocus ? "#3182ce" : "#d0d7de"
                    border.width: (dayComboBox.activeFocus || monthComboBox.activeFocus || yearComboBox.activeFocus) ? 2 * scaleFactor : 1 * scaleFactor

                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        color: "#20000000"
                        radius: 8 * scaleFactor
                        samples: 16
                        horizontalOffset: 0
                        verticalOffset: 2 * scaleFactor
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8 * scaleFactor
                        spacing: 5 * scaleFactor

                        ComboBox {
                            id: dayComboBox
                            Layout.preferredWidth: (parent.width - 10 * scaleFactor) / 3
                            Layout.fillHeight: true
                            font.pixelSize: formFieldFontSize * scaleFactor
                            font.family: "Arial"
                            model: Array.from({
                                length: 31
                            }, (_, i) => ("0" + (i + 1)).slice(-2))
                            currentIndex: 0

                            background: Rectangle {
                                color: dayComboBox.hovered || dayComboBox.activeFocus ? "#f6f8fa" : "#ffffff"
                                radius: 8 * scaleFactor
                                border.color: dayComboBox.activeFocus ? "#3182ce" : "#e2e8f0"
                                border.width: dayComboBox.activeFocus ? 2 * scaleFactor : 1 * scaleFactor
                            }

                            contentItem: Text {
                                text: dayComboBox.displayText
                                font: dayComboBox.font
                                color: dayComboBox.activeFocus ? "#3182ce" : "#2d3748"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                leftPadding: 10 * scaleFactor
                            }

                            popup: Popup {
                                y: dayComboBox.height
                                width: dayComboBox.width
                                height: Math.min(10 * (formFieldFontSize + 10) * scaleFactor, dayComboBox.model.length * (formFieldFontSize + 10) * scaleFactor)
                                padding: 1 * scaleFactor

                                contentItem: ListView {
                                    id: dayListView
                                    clip: true
                                    model: dayComboBox.delegateModel
                                    currentIndex: dayComboBox.highlightedIndex
                                    implicitHeight: Math.min(10 * (formFieldFontSize + 10) * scaleFactor, contentHeight)
                                    boundsBehavior: Flickable.StopAtBounds
                                    ScrollBar.vertical: ScrollBar {
                                        active: true
                                        visible: dayListView.contentHeight > dayListView.height
                                    }
                                }

                                background: Rectangle {
                                    color: "#ffffff"
                                    radius: 8 * scaleFactor
                                    border.color: "#d0d7de"
                                    border.width: 1 * scaleFactor
                                    layer.enabled: true
                                    layer.effect: DropShadow {
                                        transparentBorder: true
                                        color: "#20000000"
                                        radius: 8 * scaleFactor
                                        samples: 16
                                    }
                                }
                            }

                            delegate: ItemDelegate {
                                width: dayComboBox.width
                                contentItem: Text {
                                    text: modelData
                                    color: dayComboBox.currentIndex === index ? "#3182ce" : "#2d3748"
                                    font: dayComboBox.font
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                highlighted: dayComboBox.highlightedIndex === index
                                background: Rectangle {
                                    color: highlighted ? "#edf2f7" : "#ffffff"
                                }
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
                            font.family: "Arial"
                            model: Array.from({
                                length: 12
                            }, (_, i) => ("0" + (i + 1)).slice(-2))
                            currentIndex: 0

                            background: Rectangle {
                                color: monthComboBox.hovered || monthComboBox.activeFocus ? "#f6f8fa" : "#ffffff"
                                radius: 8 * scaleFactor
                                border.color: monthComboBox.activeFocus ? "#3182ce" : "#e2e8f0"
                                border.width: monthComboBox.activeFocus ? 2 * scaleFactor : 1 * scaleFactor
                            }

                            contentItem: Text {
                                text: monthComboBox.displayText
                                font: monthComboBox.font
                                color: monthComboBox.activeFocus ? "#3182ce" : "#2d3748"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                leftPadding: 10 * scaleFactor
                            }

                            popup: Popup {
                                y: monthComboBox.height
                                width: monthComboBox.width
                                height: Math.min(10 * (formFieldFontSize + 10) * scaleFactor, monthComboBox.model.length * (formFieldFontSize + 10) * scaleFactor)
                                padding: 1 * scaleFactor

                                contentItem: ListView {
                                    id: monthListView
                                    clip: true
                                    model: monthComboBox.delegateModel
                                    currentIndex: monthComboBox.highlightedIndex
                                    implicitHeight: Math.min(10 * (formFieldFontSize + 10) * scaleFactor, contentHeight)
                                    boundsBehavior: Flickable.StopAtBounds
                                    ScrollBar.vertical: ScrollBar {
                                        active: true
                                        visible: monthListView.contentHeight > monthListView.height
                                    }
                                }

                                background: Rectangle {
                                    color: "#ffffff"
                                    radius: 8 * scaleFactor
                                    border.color: "#d0d7de"
                                    border.width: 1 * scaleFactor
                                    layer.enabled: true
                                    layer.effect: DropShadow {
                                        transparentBorder: true
                                        color: "#20000000"
                                        radius: 8 * scaleFactor
                                        samples: 16
                                    }
                                }
                            }

                            delegate: ItemDelegate {
                                width: monthComboBox.width
                                contentItem: Text {
                                    text: modelData
                                    color: monthComboBox.currentIndex === index ? "#3182ce" : "#2d3748"
                                    font: monthComboBox.font
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                highlighted: monthComboBox.highlightedIndex === index
                                background: Rectangle {
                                    color: highlighted ? "#edf2f7" : "#ffffff"
                                }
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
                            font.family: "Arial"
                            model: Array.from({
                                length: 100
                            }, (_, i) => (2025 - i).toString())
                            currentIndex: 25

                            background: Rectangle {
                                color: yearComboBox.hovered || yearComboBox.activeFocus ? "#f6f8fa" : "#ffffff"
                                radius: 8 * scaleFactor
                                border.color: yearComboBox.activeFocus ? "#3182ce" : "#e2e8f0"
                                border.width: yearComboBox.activeFocus ? 2 * scaleFactor : 1 * scaleFactor
                            }

                            contentItem: Text {
                                text: yearComboBox.displayText
                                font: yearComboBox.font
                                color: yearComboBox.activeFocus ? "#3182ce" : "#2d3748"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                leftPadding: 10 * scaleFactor
                            }

                            popup: Popup {
                                y: yearComboBox.height
                                width: yearComboBox.width
                                height: Math.min(10 * (formFieldFontSize + 10) * scaleFactor, yearComboBox.model.length * (formFieldFontSize + 10) * scaleFactor)
                                padding: 1 * scaleFactor

                                contentItem: ListView {
                                    id: yearListView
                                    clip: true
                                    model: yearComboBox.delegateModel
                                    currentIndex: yearComboBox.highlightedIndex
                                    implicitHeight: Math.min(10 * (formFieldFontSize + 10) * scaleFactor, contentHeight)
                                    boundsBehavior: Flickable.StopAtBounds
                                    ScrollBar.vertical: ScrollBar {
                                        active: true
                                        visible: yearListView.contentHeight > yearListView.height
                                    }
                                }

                                background: Rectangle {
                                    color: "#ffffff"
                                    radius: 8 * scaleFactor
                                    border.color: "#d0d7de"
                                    border.width: 1 * scaleFactor
                                    layer.enabled: true
                                    layer.effect: DropShadow {
                                        transparentBorder: true
                                        color: "#20000000"
                                        radius: 8 * scaleFactor
                                        samples: 16
                                    }
                                }
                            }

                            delegate: ItemDelegate {
                                width: yearComboBox.width
                                contentItem: Text {
                                    text: modelData
                                    color: yearComboBox.currentIndex === index ? "#3182ce" : "#2d3748"
                                    font: yearComboBox.font
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                highlighted: yearComboBox.highlightedIndex === index
                                background: Rectangle {
                                    color: highlighted ? "#edf2f7" : "#ffffff"
                                }
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

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    radius: 12 * scaleFactor
                    color: "#f6f8fa"
                    border.color: confirmPasswordField.activeFocus ? "#3182ce" : "#d0d7de"
                    border.width: confirmPasswordField.activeFocus ? 2 * scaleFactor : 1 * scaleFactor

                    TextField {
                        id: confirmPasswordField
                        anchors.fill: parent
                        anchors.margins: 8 * scaleFactor
                        font.pixelSize: formFieldFontSize * scaleFactor
                        font.family: "Arial"
                        color: "#2d3748"
                        placeholderText: "Confirm Password"
                        placeholderTextColor: "#a0aec0"
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
                    defaultColor: "#2b6cb0"
                    hoverColor: "#3182ce"
                    radius: 12 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    font.family: "Arial"
                    onClicked: {
                        if (passwordField.text === confirmPasswordField.text) {
                            let dobToSend = parseDOBToSend(dayComboBox.currentText, monthComboBox.currentText, yearComboBox.currentText);
                            authViewModel.registerUser(emailField.text, passwordField.text, nameField.text, dobToSend);
                            console.log("Register button clicked, email:", emailField.text, "DOB:", dobToSend);
                        } else {
                            notificationPopup.message = "Passwords do not match";
                            notificationPopup.color = "#e53e3e";
                            notificationPopup.open();
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

                Text {
                    text: "Already have an account? Login"
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
                            NavigationManager.navigateTo("qrc:/Source/View/Authentication/LoginView.qml");
                            console.log("Navigate to LoginView");
                        }
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
        property color color: "#48bb78"

        background: Rectangle {
            color: notificationPopup.color
            radius: 8 * scaleFactor
        }

        Text {
            anchors.centerIn: parent
            text: notificationPopup.message
            font.pixelSize: formFieldFontSize * scaleFactor
            font.family: "Arial"
            color: "#ffffff"
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
            notificationPopup.color = success ? "#48bb78" : "#e53e3e";
            notificationPopup.open();
            if (success) {
                NavigationManager.navigateTo("qrc:/Source/View/Authentication/LoginView.qml");
            }
        }
    }

    Component.onCompleted: {
        console.log("RegisterView: Component completed");
    }
}
