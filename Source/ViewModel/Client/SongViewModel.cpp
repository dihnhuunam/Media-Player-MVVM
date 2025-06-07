#include "SongViewModel.hpp"
#include "AppState.hpp"
#include <QDebug>
#include <QRandomGenerator>

SongViewModel::SongViewModel(QObject *parent)
    : QObject(parent), m_songModel(new SongModel(this)), m_mediaPlayer(new QMediaPlayer(this)), m_audioOutput(new QAudioOutput(this))
{
    m_mediaPlayer->setAudioOutput(m_audioOutput);
    m_audioOutput->setVolume(0.5);

    connect(m_mediaPlayer, &QMediaPlayer::mediaStatusChanged,
            this, &SongViewModel::onMediaStatusChanged);
    connect(m_mediaPlayer, &QMediaPlayer::playbackStateChanged,
            this, &SongViewModel::onPlaybackStateChanged);
    connect(m_mediaPlayer, &QMediaPlayer::positionChanged,
            this, &SongViewModel::onPositionChanged);
    connect(m_mediaPlayer, &QMediaPlayer::durationChanged,
            this, &SongViewModel::onDurationChanged);
    connect(m_mediaPlayer, &QMediaPlayer::errorOccurred,
            this, &SongViewModel::onErrorOccurred);
    connect(m_songModel, &SongModel::songsChanged,
            this, &SongViewModel::onSongsFetched);
}

void SongViewModel::setVolume(qreal volume)
{
    if (volume != m_audioOutput->volume())
    {
        m_audioOutput->setVolume(volume);
        m_muted = (volume == 0);
        if (!m_muted)
            m_previousVolume = volume;
        emit volumeChanged();
        emit mutedChanged();
        qDebug() << "SongViewModel: Volume set to" << volume;
    }
}

void SongViewModel::setMuted(bool muted)
{
    if (m_muted != muted)
    {
        m_muted = muted;
        if (muted)
        {
            m_previousVolume = m_audioOutput->volume();
            m_audioOutput->setVolume(0);
        }
        else
        {
            m_audioOutput->setVolume(m_previousVolume);
        }
        emit mutedChanged();
        emit volumeChanged();
        qDebug() << "SongViewModel: Muted set to" << muted << "volume:" << m_audioOutput->volume();
    }
}

void SongViewModel::search(const QString &query)
{
    m_songModel->setQuery(query);
}

void SongViewModel::fetchAllSongs()
{
    m_songModel->fetchAllSongs();
}

void SongViewModel::playSong(int songId, const QString &title, const QStringList &artists)
{
    QString streamUrl = m_songModel->getStreamUrl(songId);
    m_currentSongTitle = title;
    m_currentSongArtists = artists;

    m_mediaPlayer->setSource(QUrl(streamUrl));
    m_mediaPlayer->play();

    emit currentSongChanged();
    qDebug() << "SongViewModel: Playing song:" << title << "by" << artists.join(", ") << "URL:" << streamUrl;
}

void SongViewModel::setPosition(qint64 position)
{
    m_mediaPlayer->setPosition(position);
}

void SongViewModel::play()
{
    m_mediaPlayer->play();
    emit isPlayingChanged();
}

void SongViewModel::pause()
{
    m_mediaPlayer->pause();
    emit isPlayingChanged();
}

void SongViewModel::setShuffle(bool shuffle)
{
    if (m_shuffle != shuffle)
    {
        m_shuffle = shuffle;
        emit shuffleChanged();
        qDebug() << "SongViewModel: Shuffle set to" << shuffle;
    }
}

void SongViewModel::setRepeatMode(int mode)
{
    if (m_repeatMode != mode)
    {
        m_repeatMode = mode;
        emit repeatModeChanged();
        qDebug() << "SongViewModel: Repeat mode set to" << mode;
    }
}

QString SongViewModel::normalizeString(const QString &str) const
{
    return str.trimmed().replace(QRegularExpression("\\s+"), " ");
}

int SongViewModel::findCurrentSongIndex(const QVariantList &songList) const
{
    if (songList.isEmpty() || m_currentSongTitle.isEmpty())
    {
        qDebug() << "SongViewModel: Song list empty or no current song";
        return 0;
    }

    QString normalizedTitle = normalizeString(m_currentSongTitle);
    QString normalizedArtist = normalizeString(m_currentSongArtists.join(", "));
    for (int i = 0; i < songList.size(); ++i)
    {
        QVariantMap song = songList[i].toMap();
        QString songTitle = normalizeString(song.value("title").toString());
        QString songArtists = normalizeString(song.value("artists").toStringList().join(", "));
        if (songTitle == normalizedTitle && songArtists == normalizedArtist)
        {
            return i;
        }
    }
    qDebug() << "SongViewModel: Current song not found in list, defaulting to index 0";
    return 0;
}

void SongViewModel::playSongAtIndex(const QVariantList &songList, int index)
{
    if (index < 0 || index >= songList.size())
    {
        qDebug() << "SongViewModel: Invalid song index:" << index;
        return;
    }
    QVariantMap song = songList[index].toMap();
    int songId = song.value("id").toInt();
    QString title = song.value("title").toString();
    QStringList artists = song.value("artists").toStringList();
    QString filePath = song.value("file_path").toString();

    AppState::instance()->setState({{"title", title},
                                    {"artist", artists.join(", ")},
                                    {"filePath", filePath},
                                    {"playlistId", AppState::instance()->currentPlaylistId()}});

    playSong(songId, title, artists);
    qDebug() << "SongViewModel: Playing song at index:" << index << "Title:" << title << "Artists:" << artists.join(", ");
}

void SongViewModel::nextSong()
{
    QVariantList songList = AppState::instance()->currentPlaylistId() != -1
                                ? AppState::instance()->currentMediaFiles()
                                : m_allSongs;

    if (songList.isEmpty())
    {
        qDebug() << "SongViewModel: No songs available to play";
        return;
    }

    int currentIndex = findCurrentSongIndex(songList);
    if (m_repeatMode == 1)
    {
        playSongAtIndex(songList, currentIndex);
    }
    else
    {
        int nextIndex;
        if (m_shuffle)
        {
            nextIndex = QRandomGenerator::global()->bounded(songList.size());
            while (nextIndex == currentIndex && songList.size() > 1)
            {
                nextIndex = QRandomGenerator::global()->bounded(songList.size());
            }
        }
        else
        {
            nextIndex = currentIndex + 1;
            if (nextIndex >= songList.size())
            {
                if (m_repeatMode == 2)
                {
                    nextIndex = 0;
                }
                else
                {
                    qDebug() << "SongViewModel: Reached end of song list, stopping";
                    return;
                }
            }
        }
        playSongAtIndex(songList, nextIndex);
    }
}

void SongViewModel::previousSong()
{
    QVariantList songList = AppState::instance()->currentPlaylistId() != -1
                                ? AppState::instance()->currentMediaFiles()
                                : m_allSongs;

    if (songList.isEmpty())
    {
        qDebug() << "SongViewModel: No songs available to play";
        return;
    }

    int currentIndex = findCurrentSongIndex(songList);
    if (m_repeatMode == 1)
    {
        playSongAtIndex(songList, currentIndex);
    }
    else
    {
        int prevIndex;
        if (m_shuffle)
        {
            prevIndex = QRandomGenerator::global()->bounded(songList.size());
            while (prevIndex == currentIndex && songList.size() > 1)
            {
                prevIndex = QRandomGenerator::global()->bounded(songList.size());
            }
        }
        else
        {
            prevIndex = currentIndex - 1;
            if (prevIndex < 0)
            {
                if (m_repeatMode == 2)
                {
                    prevIndex = songList.size() - 1;
                }
                else
                {
                    qDebug() << "SongViewModel: Reached start of song list, stopping";
                    return;
                }
            }
        }
        playSongAtIndex(songList, prevIndex);
    }
}

void SongViewModel::onMediaStatusChanged(QMediaPlayer::MediaStatus status)
{
    qDebug() << "SongViewModel: Media status changed:" << status;
}

void SongViewModel::onPlaybackStateChanged(QMediaPlayer::PlaybackState state)
{
    emit isPlayingChanged();
    qDebug() << "SongViewModel: Playback state changed:" << state;
}

void SongViewModel::onPositionChanged(qint64 position)
{
    emit positionChanged();
}

void SongViewModel::onDurationChanged(qint64 duration)
{
    emit durationChanged();
}

void SongViewModel::onErrorOccurred(QMediaPlayer::Error error, const QString &errorString)
{
    emit errorOccurred(errorString);
    qDebug() << "SongViewModel: Media error:" << errorString;
}

void SongViewModel::onSongsFetched()
{
    m_allSongs.clear();
    for (int i = 0; i < m_songModel->rowCount(); ++i)
    {
        QModelIndex index = m_songModel->index(i, 0);
        QVariantMap song;
        song["id"] = m_songModel->data(index, SongModel::IdRole);
        song["title"] = m_songModel->data(index, SongModel::TitleRole);
        song["artists"] = m_songModel->data(index, SongModel::ArtistsRole);
        song["file_path"] = m_songModel->data(index, SongModel::FilePathRole);
        song["genres"] = m_songModel->data(index, SongModel::GenresRole);
        m_allSongs.append(song);
    }
    m_allSongsLoaded = true;
    emit allSongsFetched();
    emit allSongsLoadedChanged();
    qDebug() << "SongViewModel: All songs fetched, count:" << m_allSongs.size();
}