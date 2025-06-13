#pragma once
#include <QObject>
#include "UartModel.hpp"
#include "SongViewModel.hpp"

class UartViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(UartModel *uartModel READ uartModel CONSTANT)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)

public:
    explicit UartViewModel(SongViewModel *songViewModel, QObject *parent = nullptr);

    UartModel *uartModel() const { return m_uartModel; }
    QString errorMessage() const { return m_uartModel->errorMessage(); }
    bool isConnected() const { return m_uartModel->isConnected(); }

    Q_INVOKABLE void startUart(const QString &portName = "/dev/ttyACM0");
    Q_INVOKABLE void stopUart();

signals:
    void errorMessageChanged();
    void isConnectedChanged();
    void playPauseRequested();
    void nextSongRequested();
    void previousSongRequested();

private slots:
    void onPlayPauseRequested();
    void onNextSongRequested();
    void onPreviousSongRequested();
    void onVolumeChanged(int volume);

private:
    UartModel *m_uartModel;
    SongViewModel *m_songViewModel;
};
