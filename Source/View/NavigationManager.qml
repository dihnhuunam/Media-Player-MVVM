pragma Singleton
import QtQuick

QtObject {
    // Navigation properties
    property var viewHistory: [] // Stack to store navigation history
    property var loader: null // Loader reference (set from Main.qml)

    // Navigate to a new view
    function navigateTo(viewUrl, params) {
        if (!loader) {
            console.log("NavigationManager: Loader not set");
            return;
        }
        // Update AppState with provided params
        if (params) {
            // Only update playlistName when navigating to MediaPlayerView with song selection
            if (viewUrl === "qrc:/Source/View/MediaPlayerView.qml" && params.title !== undefined && params.artist !== undefined) {
                AppState.setState(params);
            } else if (viewUrl === "qrc:/Source/View/MediaFileView.qml") {
                // Update playlistName and mediaFiles for MediaFileView
                AppState.setState({
                    playlistName: params.playlistName,
                    mediaFiles: params.mediaFiles
                });
            } else {
                // Update other state properties without playlistName for other views
                AppState.setState({
                    title: params.title,
                    artist: params.artist,
                    mediaFiles: params.mediaFiles
                });
            }
        }
        // Store current view in history
        if (loader.source !== "") {
            viewHistory.push(loader.source);
            console.log("NavigationManager: Added to history:", loader.source);
        }
        loader.source = viewUrl;
        console.log("NavigationManager: Navigated to", viewUrl, "History:", viewHistory);
    }

    // Go back to the previous view
    function goBack() {
        if (!loader) {
            console.log("NavigationManager: Loader not set");
            return;
        }
        if (viewHistory.length > 0) {
            let lastView = viewHistory.pop();
            loader.source = lastView;
            console.log("NavigationManager: Navigated back to", lastView, "Remaining history:", viewHistory);
        } else {
            console.log("NavigationManager: No previous view in history");
        }
    }

    // Set navigation state without changing view
    function setNavigationState(params) {
        AppState.setState(params);
    }
}
