#include "UartModel.hpp"
#include <QDebug>

UartModel::UartModel(QObject *parent)
    : QObject(parent), m_serialPort(new QSerialPort(this)), m_errorMessage("")
{
    connect(m_serialPort, &QSerialPort::readyRead, this, &UartModel::handleSerialData);
    connect(m_serialPort, &QSerialPort::errorOccurred, this, &UartModel::handleSerialError);
}

UartModel::~UartModel()
{
    disconnectSerialPort();
}

void UartModel::connectToSerialPort(const QString &portName)
{
    if (m_serialPort->isOpen())
    {
        disconnectSerialPort();
    }

    m_serialPort->setPortName(portName);
    m_serialPort->setBaudRate(QSerialPort::Baud9600);
    m_serialPort->setDataBits(QSerialPort::Data8);
    m_serialPort->setParity(QSerialPort::NoParity);
    m_serialPort->setStopBits(QSerialPort::OneStop);
    m_serialPort->setFlowControl(QSerialPort::NoFlowControl);

    if (m_serialPort->open(QIODevice::ReadOnly))
    {
        m_errorMessage = "";
        emit isConnectedChanged();
        qDebug() << "UartModel: Connected to" << portName;
    }
    else
    {
        m_errorMessage = m_serialPort->errorString();
        emit errorMessageChanged();
        qDebug() << "UartModel: Failed to connect to" << portName << ":" << m_errorMessage;
    }
}

void UartModel::disconnectSerialPort()
{
    if (m_serialPort->isOpen())
    {
        m_serialPort->close();
        m_errorMessage = "";
        emit isConnectedChanged();
        qDebug() << "UartModel: Disconnected from serial port";
    }
}

void UartModel::handleSerialData()
{
    m_buffer.append(m_serialPort->readAll());

    // Process complete lines (terminated by \n\r)
    while (m_buffer.contains("\n\r"))
    {
        int endIndex = m_buffer.indexOf("\n\r");
        QString line = QString(m_buffer.left(endIndex)).trimmed();
        m_buffer = m_buffer.mid(endIndex + 2); // Remove processed line

        qDebug() << "UartModel: Received line:" << line;

        if (line == "play_pause")
        {
            emit playPauseRequested();
        }
        else if (line == "next")
        {
            emit nextSongRequested();
        }
        else if (line == "prev")
        {
            emit previousSongRequested();
        }
        else
        {
            bool ok;
            int volume = line.toInt(&ok);
            if (ok && volume >= 0 && volume <= 100)
            {
                emit volumeChanged(volume);
            }
            else
            {
                m_errorMessage = "Invalid UART command or volume: " + line;
                emit errorMessageChanged();
                qDebug() << m_errorMessage;
            }
        }
    }
}

void UartModel::handleSerialError(QSerialPort::SerialPortError error)
{
    if (error != QSerialPort::NoError && m_serialPort->isOpen())
    {
        m_errorMessage = m_serialPort->errorString();
        emit errorMessageChanged();
        qDebug() << "UartModel: Serial error:" << m_errorMessage;
        disconnectSerialPort();
    }
}