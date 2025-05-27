#include "AppState.hpp"

AppState *AppState::m_instance = nullptr;

AppState::AppState(QObject *parent) : QObject(parent)
{
    m_currentPlaylistName = "Unknown Playlist";
    m_currentMediaTitle = "Unknown Title";
    m_currentMediaArtist = "Unknown Artist";
    m_currentPlaylistId = -1;
    m_isAuthenticated = false;
    m_userId = -1;
    m_settings = new QSettings("MediaPlayer", "Auth", this);

    loadUserInfo();
}

AppState *AppState::instance()
{
    if (!m_instance)
    {
        m_instance = new AppState();
    }
    return m_instance;
}

QString AppState::currentPlaylistName() const
{
    return m_currentPlaylistName;
}

QVariantList AppState::currentMediaFiles() const
{
    return m_currentMediaFiles;
}

QString AppState::currentMediaTitle() const
{
    return m_currentMediaTitle;
}

QString AppState::currentMediaArtist() const
{
    return m_currentMediaArtist;
}

int AppState::currentPlaylistId() const
{
    return m_currentPlaylistId;
}

bool AppState::isAuthenticated() const
{
    return m_isAuthenticated;
}

QString AppState::email() const
{
    return m_email;
}

QString AppState::name() const
{
    return m_name;
}

QString AppState::dateOfBirth() const
{
    return m_dateOfBirth;
}

QString AppState::role() const
{
    return m_role;
}

int AppState::userId() const
{
    return m_userId;
}

QString AppState::getToken() const
{
    return m_settings->value("jwt_token", "").toString();
}

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

void AppState::setEmail(const QString &email)
{
    if (m_email != email)
    {
        m_email = email;
        emit emailChanged();
    }
}

void AppState::setName(const QString &name)
{
    if (m_name != name)
    {
        m_name = name;
        emit nameChanged();
    }
}

void AppState::setDateOfBirth(const QString &dob)
{
    if (m_dateOfBirth != dob)
    {
        m_dateOfBirth = dob;
        emit dateOfBirthChanged();
    }
}

void AppState::setRole(const QString &role)
{
    if (m_role != role)
    {
        m_role = role;
        emit roleChanged();
    }
}

void AppState::setUserId(int id)
{
    if (m_userId != id)
    {
        m_userId = id;
        emit userIdChanged();
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

void AppState::loadUserInfo()
{
    QString token = m_settings->value("jwt_token", "").toString();
    m_isAuthenticated = !token.isEmpty();
    m_email = m_settings->value("user/email", "").toString();
    m_name = m_settings->value("user/name", "").toString();
    m_dateOfBirth = m_settings->value("user/dateOfBirth", "").toString();
    m_role = m_settings->value("user/role", "").toString();
    m_userId = m_settings->value("user/id", -1).toInt();

    emit authenticationChanged();
    emit emailChanged();
    emit nameChanged();
    emit dateOfBirthChanged();
    emit roleChanged();
    emit userIdChanged();
}

void AppState::clearUserInfo()
{
    m_settings->remove("jwt_token");
    m_settings->remove("user/email");
    m_settings->remove("user/name");
    m_settings->remove("user/dateOfBirth");
    m_settings->remove("user/role");
    m_settings->remove("user/id");

    m_isAuthenticated = false;
    m_email.clear();
    m_name.clear();
    m_dateOfBirth.clear();
    m_role.clear();
    m_userId = -1;

    emit authenticationChanged();
    emit emailChanged();
    emit nameChanged();
    emit dateOfBirthChanged();
    emit roleChanged();
    emit userIdChanged();
}