import QtQuick 6.8
import QtQuick.Controls 6.8

Button {
    id: hoverButton

    property string imageSource: ""
    property real buttonWidth: 60
    property real buttonHeight: 60
    property real imageWidth: 30
    property real imageHeight: 30
    property color hoverColor: "#cccccc"
    property color defaultColor: "transparent"
    property real hoverScale: 1.1
    property real radius: width / 2
    property real defaultScale: 1.0
    property int animationDuration: 150
    property bool showBorder: true
    property bool enableHover: true

    width: buttonWidth
    height: buttonHeight
    flat: true

    background: Rectangle {
        radius: hoverButton.radius
        color: enableHover && hoverButton.hovered ? hoverColor : defaultColor

        Behavior on color {
            ColorAnimation {
                duration: animationDuration
            }
        }
    }

    Image {
        anchors.centerIn: parent
        source: imageSource
        width: imageWidth
        height: imageHeight
        visible: imageSource !== ""
    }

    scale: (enableHover && hoverButton.hovered) ? hoverScale : defaultScale
    Behavior on scale {
        NumberAnimation {
            duration: animationDuration
        }
    }
}
