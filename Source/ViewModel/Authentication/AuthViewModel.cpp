#include "AuthViewModel.hpp"

AuthViewModel::AuthViewModel(QObject *parent)
    : QObject(parent), m_authModel(new AuthModel(this))
{
    connect(m_authModel, &AuthModel::loginResult, this, &AuthViewModel::loginFinished);
    connect(m_authModel, &AuthModel::registerResult, this, &AuthViewModel::registerFinished);
    connect(m_authModel, &AuthModel::profileUpdateResult, this, &AuthViewModel::profileUpdateFinished);
}

void AuthViewModel::loginUser(const QString &email, const QString &password)
{
    m_authModel->loginUser(email, password);
}

void AuthViewModel::registerUser(const QString &email, const QString &password, const QString &name, const QString &dob)
{
    m_authModel->registerUser(email, password, name, dob);
}

void AuthViewModel::updateProfile(int userId, const QString &name, const QString &dob, const QString &currentPassword, const QString &newPassword)
{
    m_authModel->updateProfile(userId, name, dob, currentPassword, newPassword);
}