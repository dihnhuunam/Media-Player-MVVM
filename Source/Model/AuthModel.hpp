#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSettings>

class AuthModel : public QObject
{
    Q_OBJECT
public:
    explicit AuthModel(QObject *parent = nullptr);

    void loginUser(const QString &email, const QString &password);
    void registerUser(const QString &email, const QString &password, const QString &name, const QString &dob);
    void updateProfile(int userId, const QString &name, const QString &dob, const QString &currentPassword, const QString &newPassword);
    QString getToken() const;
    int getUserId() const;
    void clearToken();

signals:
    void loginResult(bool success, const QString &message);
    void registerResult(bool success, const QString &message);
    void profileUpdateResult(bool success, const QString &message);

private:
    QNetworkAccessManager *m_networkManager;
    QSettings *m_settings;
    void handleNetworkReply(QNetworkReply *reply, bool isLogin, bool isUpdate = false);
    void saveToken(const QString &token);
    void saveUserInfo(const QJsonObject &user);
};