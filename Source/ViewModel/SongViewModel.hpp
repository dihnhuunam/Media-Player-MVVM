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
    Q_PROPERTY(bool shuffle READ shuffle WRITE setShuffle NOTIFY shuffleChanged)
    Q_PROPERTY(int repeatMode READ repeatMode WRITE setRepeatMode NOTIFY repeatModeChanged)
    Q_PROPERTY(bool muted READ muted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(bool allSongsLoaded READ allSongsLoaded NOTIFY allSongsLoadedChanged)

public:
    explicit SongViewModel(QObject *parent = nullptr);

    SongModel *songModel() const { return m_songModel; }
    QString currentSongTitle() const { return m_currentSongTitle; }
    QString currentSongArtist() const { return m_currentSongArtists.join(", "); }
    bool isPlaying() const { return m_mediaPlayer->playbackState() == QMediaPlayer::PlayingState; }
    qint64 position() const { return m_mediaPlayer->position(); }
    qint64 duration() const { return m_mediaPlayer->duration(); }
    qreal volume() const { return m_audioOutput->volume(); }
    bool shuffle() const { return m_shuffle; }
    int repeatMode() const { return m_repeatMode; }
    bool muted() const { return m_muted; }
    bool allSongsLoaded() const { return m_allSongsLoaded; }

    Q_INVOKABLE void setVolume(qreal volume);
    Q_INVOKABLE void search(const QString &query);
    Q_INVOKABLE void fetchAllSongs();
    Q_INVOKABLE void playSong(int songId, const QString &title, const QStringList &artists);
    Q_INVOKABLE void setPosition(qint64 position);
    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void nextSong();
    Q_INVOKABLE void previousSong();
    Q_INVOKABLE void setShuffle(bool shuffle);
    Q_INVOKABLE void setRepeatMode(int mode);
    Q_INVOKABLE void setMuted(bool muted);

signals:
    void currentSongChanged();
    void isPlayingChanged();
    void positionChanged();
    void durationChanged();
    void volumeChanged();
    void shuffleChanged();
    void repeatModeChanged();
    void mutedChanged();
    void errorOccurred(const QString &error);
    void allSongsFetched();
    void allSongsLoadedChanged();

private slots:
    void onMediaStatusChanged(QMediaPlayer::MediaStatus status);
    void onPlaybackStateChanged(QMediaPlayer::PlaybackState state);
    void onPositionChanged(qint64 position);
    void onDurationChanged(qint64 duration);
    void onErrorOccurred(QMediaPlayer::Error error, const QString &errorString);
    void onSongsFetched();

private:
    QString normalizeString(const QString &str) const;
    int findCurrentSongIndex(const QVariantList &songList) const;
    void playSongAtIndex(const QVariantList &songList, int index);

    SongModel *m_songModel;
    QMediaPlayer *m_mediaPlayer;
    QAudioOutput *m_audioOutput;
    QString m_currentSongTitle;
    QStringList m_currentSongArtists;
    bool m_shuffle = false;
    int m_repeatMode = 0; // 0: No repeat, 1: Repeat one, 2: Repeat all
    bool m_muted = false;
    qreal m_previousVolume = 0.5;
    bool m_allSongsLoaded = false;
    QVariantList m_allSongs;
};

#endif // SONGVIEWMODEL_H