#ifndef UARTMODEL_H
#define UARTMODEL_H

#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QString>

class UartModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
    explicit UartModel(QObject *parent = nullptr);
    ~UartModel();

    bool isConnected() const { return m_serialPort->isOpen(); }
    QString errorMessage() const { return m_errorMessage; }

    Q_INVOKABLE void connectToSerialPort(const QString &portName = "/dev/ttyACM0");
    Q_INVOKABLE void disconnectSerialPort();

signals:
    void isConnectedChanged();
    void errorMessageChanged();
    void playPauseRequested();
    void nextSongRequested();
    void previousSongRequested();
    void volumeChanged(int volume);

private slots:
    void handleSerialData();
    void handleSerialError(QSerialPort::SerialPortError error);

private:
    QSerialPort *m_serialPort;
    QString m_errorMessage;
    QByteArray m_buffer;
};

#endif // UARTMODEL_H