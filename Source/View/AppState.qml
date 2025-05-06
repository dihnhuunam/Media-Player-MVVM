pragma Singleton
import QtQuick

QtObject {
    // Shared application state
    property string currentPlaylistName: "Unknown Playlist"
    property var currentMediaFiles: []
    property string currentMediaTitle: "Unknown Title"
    property string currentMediaArtist: "Unknown Artist"

    function setState(params) {
        if (params) {
            if (params.playlistName !== undefined)
                currentPlaylistName = params.playlistName;
            if (params.mediaFiles !== undefined)
                currentMediaFiles = params.mediaFiles;
            if (params.title !== undefined)
                currentMediaTitle = params.title;
            if (params.artist !== undefined)
                currentMediaArtist = params.artist;
        }
        console.log("AppState: Updated state - playlistName:", currentPlaylistName, "title:", currentMediaTitle, "artist:", currentMediaArtist);
    }
}
