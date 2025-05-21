#ifndef SONGVIEWMODEL_H
#define SONGVIEWMODEL_H

#include <QObject>
#include <QMediaPlayer>
#include <QAudioOutput>
#include "SongModel.hpp"

class SongViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(SongModel *songModel READ songModel CONSTANT)
    Q_PROPERTY(QString currentSongTitle READ currentSongTitle NOTIFY currentSongChanged)
    Q_PROPERTY(QString currentSongArtist READ currentSongArtist NOTIFY currentSongChanged)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY isPlayingChanged)
    Q_PROPERTY(qint64 position READ position NOTIFY positionChanged)
    Q_PROPERTY(qint64 duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(qreal volume READ volume WRITE setVolume NOTIFY volumeChanged)

public:
    explicit SongViewModel(QObject *parent = nullptr);

    SongModel *songModel() const { return m_songModel; }
    QString currentSongTitle() const { return m_currentSongTitle; }
    QString currentSongArtist() const { return m_currentSongArtists.join(", "); }
    bool isPlaying() const { return m_mediaPlayer->playbackState() == QMediaPlayer::PlayingState; }
    qint64 position() const { return m_mediaPlayer->position(); }
    qint64 duration() const { return m_mediaPlayer->duration(); }
    qreal volume() const { return m_audioOutput->volume(); }

    Q_INVOKABLE void setVolume(qreal volume);
    Q_INVOKABLE void search(const QString &query);
    Q_INVOKABLE void fetchAllSongs();
    Q_INVOKABLE void playSong(int songId, const QString &title, const QStringList &artists);
    Q_INVOKABLE void setPosition(qint64 position);
    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();

signals:
    void currentSongChanged();
    void isPlayingChanged();
    void positionChanged();
    void durationChanged();
    void volumeChanged();
    void errorOccurred(const QString &error);
    void allSongsFetched();

private slots:
    void onMediaStatusChanged(QMediaPlayer::MediaStatus status);
    void onPlaybackStateChanged(QMediaPlayer::PlaybackState state);
    void onPositionChanged(qint64 position);
    void onDurationChanged(qint64 duration);
    void onErrorOccurred(QMediaPlayer::Error error, const QString &errorString);

private:
    SongModel *m_songModel;
    QMediaPlayer *m_mediaPlayer;
    QAudioOutput *m_audioOutput;
    QString m_currentSongTitle;
    QStringList m_currentSongArtists;
};

#endif // SONGVIEWMODEL_H