#include "UartViewModel.hpp"
#include <QDebug>

UartViewModel::UartViewModel(SongViewModel *songViewModel, QObject *parent)
    : QObject(parent), m_uartModel(new UartModel(this)), m_songViewModel(songViewModel)
{
    connect(m_uartModel, &UartModel::playPauseRequested, this, &UartViewModel::onPlayPauseRequested);
    connect(m_uartModel, &UartModel::nextSongRequested, this, &UartViewModel::onNextSongRequested);
    connect(m_uartModel, &UartModel::previousSongRequested, this, &UartViewModel::onPreviousSongRequested);
    connect(m_uartModel, &UartModel::volumeChanged, this, &UartViewModel::onVolumeChanged);
    connect(m_uartModel, &UartModel::errorMessageChanged, this, &UartViewModel::errorMessageChanged);
    connect(m_uartModel, &UartModel::isConnectedChanged, this, &UartViewModel::isConnectedChanged);
}

void UartViewModel::startUart(const QString &portName)
{
    m_uartModel->connectToSerialPort(portName);
    qDebug() << "UartViewModel: Starting UART on" << portName;
}

void UartViewModel::stopUart()
{
    m_uartModel->disconnectSerialPort();
    qDebug() << "UartViewModel: Stopping UART";
}

void UartViewModel::onPlayPauseRequested()
{
    if (m_songViewModel)
    {
        if (m_songViewModel->isPlaying())
        {
            m_songViewModel->pause();
            qDebug() << "UartViewModel: Play/Pause - Pausing playback";
        }
        else
        {
            m_songViewModel->play();
            qDebug() << "UartViewModel: Play/Pause - Starting playback";
        }
        emit playPauseRequested();
    }
}

void UartViewModel::onNextSongRequested()
{
    {
        if (m_songViewModel)
        {
            m_songViewModel->nextSong();
            qDebug() << "UartViewModel: Next song requested";
            emit nextSongRequested();
        }
    }
}

void UartViewModel::onPreviousSongRequested()
{
    if (m_songViewModel)
    {
        m_songViewModel->previousSong();
        qDebug() << "UartViewModel: Previous song requested";
        emit previousSongRequested();
    }
}

void UartViewModel::onVolumeChanged(int volume)
{
    if (m_songViewModel)
    {
        qreal scaledVolume = volume / 100.0;
        m_songViewModel->setVolume(scaledVolume);
        qDebug() << "UartViewModel: Volume changed to" << volume << "% (" << scaledVolume << ")";
    }
}