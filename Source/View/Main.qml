import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 1024
    height: 600
    minimumWidth: 800
    minimumHeight: 500
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
