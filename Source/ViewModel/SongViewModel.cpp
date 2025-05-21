#include "SongViewModel.hpp"
#include <QDebug>

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
            this, &SongViewModel::allSongsFetched);
}

void SongViewModel::setVolume(qreal volume)
{
    if (volume != m_audioOutput->volume())
    {
        m_audioOutput->setVolume(volume);
        emit volumeChanged();
        qDebug() << "SongViewModel: Volume set to" << volume;
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