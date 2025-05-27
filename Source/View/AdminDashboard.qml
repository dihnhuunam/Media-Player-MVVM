import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./Components"
import AppState 1.0

Item {
    property real scaleFactor: parent ? Math.min(parent.width / 1024, parent.height / 600) : 1.0
    property real formFieldHeight: 55
    property real formFieldFontSize: 22
    property real formSpacing: 18
    property real formWidth: 385
    property real formHeight: 550

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
                    text: "Admin Dashboard"
                    font.pixelSize: 34 * scaleFactor
                    font.family: "Arial"
                    font.weight: Font.Medium
                    color: "#1a202c"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 15 * scaleFactor
                }

                HoverButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    text: "Upload"
                    defaultColor: "#2b6cb0"
                    hoverColor: "#3182ce"
                    radius: 12 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    font.family: "Arial"
                    onClicked: {
                        NavigationManager.navigateTo("qrc:/Source/View/AdminUploadFile.qml");
                        console.log("AdminDashboard: Navigate to AdminUploadFileView");
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

                HoverButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    text: "View Media Files"
                    defaultColor: "#2b6cb0"
                    hoverColor: "#3182ce"
                    radius: 12 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    font.family: "Arial"
                    onClicked: {
                        songViewModel.fetchAllSongs();
                        NavigationManager.navigateTo("qrc:/Source/View/AdminMediaFilesView.qml");
                        console.log("AdminDashboard: Navigate to AdminMediaFilesView");
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

                HoverButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formFieldHeight * scaleFactor
                    text: "Logout"
                    defaultColor: "#2b6cb0"
                    hoverColor: "#3182ce"
                    radius: 12 * scaleFactor
                    font.pixelSize: formFieldFontSize * scaleFactor
                    font.family: "Arial"
                    onClicked: {
                        AppState.clearUserInfo();
                        NavigationManager.navigateTo("qrc:/Source/View/LoginView.qml");
                        console.log("AdminDashboard: Logout clicked, navigated to LoginView");
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
            }
        }
    }

    Component.onCompleted: {
        console.log("AdminDashboardView: Component completed");
    }
}
