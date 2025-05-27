import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import AppState 1.0

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

        if (AppState.isAuthenticated) {
            console.log("Main: User is authenticated, role:", AppState.role);
            if (AppState.role === "admin") {
                NavigationManager.navigateTo("qrc:/Source/View/AdminDashboard.qml");
                console.log("Main: Navigating to AdminView");
            } else {
                NavigationManager.navigateTo("qrc:/Source/View/MediaPlayerView.qml");
                console.log("Main: Navigating to MediaPlayerView");
            }
        } else {
            console.log("Main: User is not authenticated, staying at LoginView");
        }
    }
}
