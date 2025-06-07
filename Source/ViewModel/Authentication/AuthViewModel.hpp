#pragma once
#include "AuthModel.hpp"
#include <QObject>

class AuthViewModel : public QObject
{
    Q_OBJECT
public:
    explicit AuthViewModel(QObject *parent = nullptr);

    Q_INVOKABLE void loginUser(const QString &email, const QString &password);
    Q_INVOKABLE void registerUser(const QString &email, const QString &password, const QString &name, const QString &dob);
    Q_INVOKABLE void updateProfile(int userId, const QString &name, const QString &dob, const QString &currentPassword, const QString &newPassword);

signals:
    void loginFinished(bool success, const QString &message);
    void registerFinished(bool success, const QString &message);
    void profileUpdateFinished(bool success, const QString &message);

private:
    AuthModel *m_authModel;
};