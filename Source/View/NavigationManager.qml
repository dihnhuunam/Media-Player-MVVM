pragma Singleton
import QtQuick
import AppState 1.0

QtObject {
    property var viewHistory: []
    property var loader: null

    function navigateTo(viewUrl, params) {
        if (!loader) {
            console.log("NavigationManager: Loader not set");
            return;
        }
        if (params) {
            AppState.setState(params);
        }
        if (loader.source !== "") {
            viewHistory.push(loader.source);
            console.log("NavigationManager: Added to history:", loader.source);
        }
        loader.source = viewUrl;
        console.log("NavigationManager: Navigated to", viewUrl, "History:", viewHistory);
    }

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

    function setNavigationState(params) {
        AppState.setState(params);
    }
}
