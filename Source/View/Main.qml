import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 1400
    height: 900
    minimumWidth: 1400
    minimumHeight: 900
    visible: true
    title: "Media Player"

    Loader {
        id: loader
        anchors.fill: parent
        source: "qrc:/Source/View/LoginView.qml"
        asynchronous: true
        onLoaded: {
            console.log("Main: Loaded view:", source);
        }
    }

    Component.onCompleted: {
        NavigationManager.loader = loader;
        console.log("Main: NavigationManager loader set");
    }
}
