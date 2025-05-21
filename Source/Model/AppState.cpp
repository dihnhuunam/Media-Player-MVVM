#include "AppState.hpp"

AppState *AppState::m_instance = nullptr;

AppState::AppState(QObject *parent) : QObject(parent)
{
    m_currentPlaylistName = "Unknown Playlist";
    m_currentMediaTitle = "Unknown Title";
    m_currentMediaArtist = "Unknown Artist";
    m_currentPlaylistId = -1;
}

AppState *AppState::instance()
{
    if (!m_instance)
    {
        m_instance = new AppState();
    }
    return m_instance;
}

QString AppState::currentPlaylistName() const { return m_currentPlaylistName; }
QVariantList AppState::currentMediaFiles() const { return m_currentMediaFiles; }
QString AppState::currentMediaTitle() const { return m_currentMediaTitle; }
QString AppState::currentMediaArtist() const { return m_currentMediaArtist; }
int AppState::currentPlaylistId() const { return m_currentPlaylistId; }

void AppState::setCurrentPlaylistName(const QString &name)
{
    if (m_currentPlaylistName != name)
    {
        m_currentPlaylistName = name;
        emit currentPlaylistNameChanged();
    }
}

void AppState::setCurrentMediaFiles(const QVariantList &files)
{
    if (m_currentMediaFiles != files)
    {
        m_currentMediaFiles = files;
        emit currentMediaFilesChanged();
    }
}

void AppState::setCurrentMediaTitle(const QString &title)
{
    if (m_currentMediaTitle != title)
    {
        m_currentMediaTitle = title;
        emit currentMediaTitleChanged();
    }
}

void AppState::setCurrentMediaArtist(const QString &artist)
{
    if (m_currentMediaArtist != artist)
    {
        m_currentMediaArtist = artist;
        emit currentMediaArtistChanged();
    }
}

void AppState::setCurrentPlaylistId(int id)
{
    if (m_currentPlaylistId != id)
    {
        m_currentPlaylistId = id;
        emit currentPlaylistIdChanged();
    }
}

void AppState::setState(const QVariantMap &state)
{
    if (state.contains("playlistName"))
    {
        setCurrentPlaylistName(state["playlistName"].toString());
    }
    if (state.contains("mediaFiles"))
    {
        setCurrentMediaFiles(state["mediaFiles"].toList());
    }
    if (state.contains("title"))
    {
        setCurrentMediaTitle(state["title"].toString());
    }
    if (state.contains("artist"))
    {
        setCurrentMediaArtist(state["artist"].toString());
    }
    if (state.contains("playlistId"))
    {
        setCurrentPlaylistId(state["playlistId"].toInt());
    }
}