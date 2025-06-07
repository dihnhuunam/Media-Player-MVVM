#ifndef UARTMODEL_H
#define UARTMODEL_H

#include <QObject>
#include <QSerialPort>
#include <QTimer>

class UartModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)

public:
    explicit UartModel(QObject *parent = nullptr);
    ~UartModel();

    QString errorMessage() const { return m_errorMessage; }
    bool isConnected() const { return m_serialPort->isOpen(); }

    Q_INVOKABLE bool connectToSerialPort(const QString &portName);
    Q_INVOKABLE void disconnectSerialPort();

signals:
    void errorMessageChanged();
    void isConnectedChanged();
    void playPauseRequested();
    void nextSongRequested();
    void previousSongRequested();
    void volumeChanged(int volume);

private slots:
    void handleReadyRead();
    void processBufferedData();
    void handleSerialError(QSerialPort::SerialPortError error);

private:
    void processCommand(const QString &command);

    QSerialPort *m_serialPort;
    QString m_errorMessage;
    QByteArray m_buffer;
    QTimer m_bufferTimer;
    QStringList m_validCommands;
};

#endif // UARTMODEL_H