#include "UartModel.hpp"
#include <QDebug>

UartModel::UartModel(QObject *parent)
    : QObject(parent),
      m_serialPort(new QSerialPort(this)),
      m_bufferTimer(this)
{
    m_validCommands = {"play_pause", "next", "prev"};
    m_bufferTimer.setSingleShot(true);
    connect(m_serialPort, &QSerialPort::readyRead, this, &UartModel::handleReadyRead);
    connect(m_serialPort, &QSerialPort::errorOccurred, this, &UartModel::handleSerialError);
    connect(&m_bufferTimer, &QTimer::timeout, this, &UartModel::processBufferedData);
}

UartModel::~UartModel()
{
    disconnectSerialPort();
}

bool UartModel::connectToSerialPort(const QString &portName)
{
    if (m_serialPort->isOpen())
    {
        m_serialPort->close();
    }

    m_serialPort->setPortName(portName);
    m_serialPort->setBaudRate(QSerialPort::Baud9600);
    m_serialPort->setDataBits(QSerialPort::Data8);
    m_serialPort->setParity(QSerialPort::NoParity);
    m_serialPort->setStopBits(QSerialPort::OneStop);
    m_serialPort->setFlowControl(QSerialPort::NoFlowControl);

    if (!m_serialPort->open(QIODevice::ReadOnly))
    {
        m_errorMessage = tr("Failed to open port %1: %2")
                             .arg(portName)
                             .arg(m_serialPort->errorString());
        emit errorMessageChanged();
        qDebug() << "UartModel: Failed to open port" << portName << ":" << m_errorMessage;
        return false;
    }

    qDebug() << "UartModel: Started listening on port" << portName;
    emit isConnectedChanged();
    return true;
}

void UartModel::disconnectSerialPort()
{
    if (m_serialPort->isOpen())
    {
        m_serialPort->close();
        qDebug() << "UartModel: Stopped listening on port" << m_serialPort->portName();
        emit isConnectedChanged();
    }
}

void UartModel::handleReadyRead()
{
    m_buffer.append(m_serialPort->readAll());
    if (!m_bufferTimer.isActive())
    {
        m_bufferTimer.start(50);
    }
}

void UartModel::processBufferedData()
{
    if (m_buffer.isEmpty())
    {
        return;
    }

    QString command = QString::fromUtf8(m_buffer).trimmed();
    m_buffer.clear();

    if (!command.isEmpty())
    {
        processCommand(command);
    }
}

void UartModel::handleSerialError(QSerialPort::SerialPortError error)
{
    if (error == QSerialPort::NoError)
    {
        return;
    }

    m_errorMessage = tr("Serial port error: %1").arg(m_serialPort->errorString());
    emit errorMessageChanged();
    qDebug() << "UartModel: Serial error:" << m_errorMessage;
}

void UartModel::processCommand(const QString &command)
{
    if (command.isEmpty())
    {
        return;
    }

    bool ok;
    int volume = command.toInt(&ok);
    if (ok && volume >= 0 && volume <= 100)
    {
        emit volumeChanged(volume);
        qDebug() << "UartModel: Valid volume processed:" << volume;
        return;
    }

    if (m_validCommands.contains(command))
    {
        if (command == "play_pause")
        {
            emit playPauseRequested();
            qDebug() << "UartModel: Play/Pause command processed";
        }
        else if (command == "next")
        {
            emit nextSongRequested();
            qDebug() << "UartModel: Next song command processed";
        }
        else if (command == "prev")
        {
            emit previousSongRequested();
            qDebug() << "UartModel: Previous song command processed";
        }
    }
    else
    {
        qDebug() << "UartModel: Invalid command received:" << command;
    }
}