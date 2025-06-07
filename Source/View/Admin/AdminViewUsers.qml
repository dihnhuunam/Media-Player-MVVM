import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Components"
import "../Helper"
import AppState 1.0

Item {
    property real scaleFactor: parent ? Math.min(parent.width / 1024, parent.height / 600) : 1.0

    property real topControlButtonSize: 90
    property real topControlIconSize: 45
    property real topControlSearchHeight: 60
    property real topControlSearchRadius: 12
    property real topControlSearchIconSize: 30
    property real topControlSearchFontSize: 22
    property real topControlSpacing: 30
    property real topControlMargin: 18
    property real topControlTopMargin: 20

    property real userItemHeight: 50
    property real userItemFontSize: 16
    property real userItemHeightMargin: 30
    property real userSpacing: 6

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

        MouseArea {
            anchors.fill: parent
            onClicked: function (mouse) {
                searchInput.focus = false;
                mouse.accepted = false;
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: userSpacing * scaleFactor

            RowLayout {
                id: topControl
                Layout.topMargin: topControlTopMargin * scaleFactor
                Layout.preferredWidth: 800 * scaleFactor
                Layout.preferredHeight: topControlSearchHeight * scaleFactor
                Layout.alignment: Qt.AlignHCenter
                Layout.leftMargin: (parent.width - 800 * scaleFactor) / 2
                Layout.rightMargin: (parent.width - 800 * scaleFactor) / 2
                spacing: topControlSpacing * scaleFactor

                HoverButton {
                    Layout.preferredWidth: topControlButtonSize * scaleFactor
                    Layout.preferredHeight: topControlButtonSize * scaleFactor
                    flat: true
                    onClicked: {
                        NavigationManager.navigateTo("qrc:/Source/View/Admin/AdminDashboard.qml");
                        console.log("AdminViewUsers: Back to AdminDashboardView");
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#e6e9ec" : "transparent"
                        radius: 10 * scaleFactor
                    }
                    Image {
                        source: "qrc:/Assets/back.png"
                        width: topControlIconSize * scaleFactor
                        height: topControlIconSize * scaleFactor
                        anchors.centerIn: parent
                        opacity: parent.hovered ? 1.0 : 0.8
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: topControlSearchHeight * scaleFactor
                    radius: topControlSearchRadius * scaleFactor
                    color: "#ffffff"
                    border.color: searchInput.activeFocus ? "#3182ce" : "#d0d7de"
                    border.width: searchInput.activeFocus ? 2 * scaleFactor : 1 * scaleFactor

                    MouseArea {
                        anchors.fill: parent
                        onClicked: function (mouse) {
                            searchInput.forceActiveFocus();
                            mouse.accepted = true;
                        }
                    }

                    RowLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: topControlMargin * scaleFactor
                        spacing: topControlSpacing * scaleFactor

                        Image {
                            source: "qrc:/Assets/search.png"
                            Layout.preferredWidth: topControlSearchIconSize * scaleFactor
                            Layout.preferredHeight: topControlSearchIconSize * scaleFactor
                            opacity: 0.8
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            text: "Search Users by Name"
                            color: "#1a202c"
                            font.pixelSize: topControlSearchFontSize * scaleFactor
                            font.family: "Arial"
                            onActiveFocusChanged: {
                                if (activeFocus && text === "Search Users by Name") {
                                    text = "";
                                }
                            }
                            onFocusChanged: {
                                if (!focus && text === "") {
                                    text = "Search Users by Name";
                                }
                            }
                            onTextChanged: {
                                if (text !== "Search Users by Name" && text) {
                                    console.log("AdminViewUsers: Searching users with name:", text);
                                    adminViewModel.searchUsersByName(text);
                                } else {
                                    adminViewModel.fetchAllUsers();
                                    console.log("AdminViewUsers: Search cleared, fetching all users");
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width
                Layout.topMargin: userSpacing * scaleFactor
                Layout.bottomMargin: userSpacing * scaleFactor
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    id: tableContainer
                    width: 800 * scaleFactor
                    height: parent.height
                    color: "transparent"
                    radius: 10 * scaleFactor
                    border.color: "#d0d7de"
                    border.width: 1
                    anchors.horizontalCenter: parent.horizontalCenter

                    Row {
                        id: headerRow
                        width: parent.width
                        height: userItemHeight * scaleFactor
                        z: 2
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Rectangle {
                            width: 60 * scaleFactor
                            height: parent.height
                            color: "#e6e9ec"
                            border.color: "#d0d7de"
                            border.width: 1
                            Text {
                                text: "No."
                                font.pixelSize: userItemFontSize * scaleFactor
                                font.family: "Arial"
                                font.bold: true
                                color: "#1a202c"
                                anchors.centerIn: parent
                            }
                        }

                        Rectangle {
                            width: 250 * scaleFactor
                            height: parent.height
                            color: "#e6e9ec"
                            border.color: "#d0d7de"
                            border.width: 1
                            Text {
                                text: "Email"
                                font.pixelSize: userItemFontSize * scaleFactor
                                font.family: "Arial"
                                font.bold: true
                                color: "#1a202c"
                                anchors.centerIn: parent
                            }
                        }

                        Rectangle {
                            width: 100 * scaleFactor
                            height: parent.height
                            color: "#e6e9ec"
                            border.color: "#d0d7de"
                            border.width: 1
                            Text {
                                text: "Role"
                                font.pixelSize: userItemFontSize * scaleFactor
                                font.family: "Arial"
                                font.bold: true
                                color: "#1a202c"
                                anchors.centerIn: parent
                            }
                        }

                        Rectangle {
                            width: 200 * scaleFactor
                            height: parent.height
                            color: "#e6e9ec"
                            border.color: "#d0d7de"
                            border.width: 1
                            Text {
                                text: "Name"
                                font.pixelSize: userItemFontSize * scaleFactor
                                font.family: "Arial"
                                font.bold: true
                                color: "#1a202c"
                                anchors.centerIn: parent
                            }
                        }

                        Rectangle {
                            width: 190 * scaleFactor
                            height: parent.height
                            color: "#e6e9ec"
                            border.color: "#d0d7de"
                            border.width: 1
                            Text {
                                text: "Date of Birth"
                                font.pixelSize: userItemFontSize * scaleFactor
                                font.family: "Arial"
                                font.bold: true
                                color: "#1a202c"
                                anchors.centerIn: parent
                            }
                        }
                    }

                    ListView {
                        id: usersListView
                        anchors.top: headerRow.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        clip: true
                        model: adminViewModel

                        delegate: Rectangle {
                            width: usersListView.width
                            height: userItemHeight * scaleFactor
                            color: "#ffffff"
                            border.color: "#d0d7de"
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                spacing: 0

                                Text {
                                    width: 60 * scaleFactor
                                    height: parent.height
                                    text: index + 1
                                    font.pixelSize: userItemFontSize * scaleFactor
                                    font.family: "Arial"
                                    color: "#1a202c"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: 250 * scaleFactor
                                    height: parent.height
                                    text: model.email || "Unknown Email"
                                    font.pixelSize: userItemFontSize * scaleFactor
                                    font.family: "Arial"
                                    color: "#1a202c"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: 100 * scaleFactor
                                    height: parent.height
                                    text: model.role ? model.role.charAt(0).toUpperCase() + model.role.slice(1) : "Unknown Role"
                                    font.pixelSize: userItemFontSize * scaleFactor
                                    font.family: "Arial"
                                    color: model.role === "admin" ? "#3182ce" : "#1a202c"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: 200 * scaleFactor
                                    height: parent.height
                                    text: model.name || "Unknown Name"
                                    font.pixelSize: userItemFontSize * scaleFactor
                                    font.family: "Arial"
                                    color: "#1a202c"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: 190 * scaleFactor
                                    height: parent.height
                                    text: model.date_of_birth ? Qt.formatDateTime(new Date(model.date_of_birth), "dd/MM/yyyy") : "Unknown DOB"
                                    font.pixelSize: userItemFontSize * scaleFactor
                                    font.family: "Arial"
                                    color: "#1a202c"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: function (mouse) {
                                    mouse.accepted = false;
                                }
                                onContainsMouseChanged: {
                                    parent.color = containsMouse ? "#f6f8fa" : "#ffffff";
                                }
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            active: true
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "No users found"
                            font.pixelSize: userItemFontSize * scaleFactor
                            font.family: "Arial"
                            color: "#1a202c"
                            visible: usersListView.count === 0
                        }

                        onModelChanged: {
                            console.log("AdminViewUsers: ListView model changed, count:", usersListView.count);
                        }
                    }
                }
            }

            Connections {
                target: adminViewModel
                function onUsersFetched(success, users, errorMessage) {
                    if (!success) {
                        console.log("AdminViewUsers: Failed to fetch users:", errorMessage);
                    } else {
                        console.log("AdminViewUsers: Users fetched successfully, count:", users.length);
                    }
                }
            }

            Component.onCompleted: {
                console.log("AdminViewUsers: Component completed, adminViewModel exists:", !!adminViewModel);
                if (adminViewModel) {
                    adminViewModel.fetchAllUsers();
                    console.log("AdminViewUsers: Fetching users");
                } else {
                    console.log("AdminViewUsers: Error: adminViewModel is null");
                }
            }
        }
    }
}
