import QtQuick 
import QtQuick.Controls 

Slider {
    id: slider

    property real sliderWidth: 400
    property real sliderHeight: 30
    property real minValue: 0.0
    property real maxValue: 1.0
    property real initialValue: 0.5
    property real step: 0.0
    property color backgroundColor: "#cccccc"
    property color fillColor: "#000000"
    property color handleColor: "#ffffff"
    property color handlePressedColor: "#000000"
    property color borderColor: "#000000"
    property real handleSize: 14
    property real trackHeight: 4

    width: sliderWidth
    height: sliderHeight
    from: minValue
    to: maxValue
    value: initialValue
    stepSize: step

    background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        implicitWidth: sliderWidth
        implicitHeight: trackHeight
        width: slider.availableWidth
        height: implicitHeight
        radius: trackHeight / 2
        color: backgroundColor

        Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            color: fillColor
            radius: trackHeight / 2
        }
    }

    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        implicitWidth: handleSize
        implicitHeight: handleSize
        radius: handleSize / 2
        color: slider.pressed ? handlePressedColor : handleColor
        border.color: borderColor
    }
}
