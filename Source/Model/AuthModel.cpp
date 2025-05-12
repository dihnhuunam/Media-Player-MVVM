#include "AuthModel.hpp"
#include <QUrl>
#include <QNetworkRequest>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDebug>

AuthModel::AuthModel(QObject *parent)
    : QObject(parent),
      m_networkManager(new QNetworkAccessManager(this)),
      m_settings(new QSettings("MediaPlayer", "Auth", this))
{
}

void AuthModel::loginUser(const QString &email, const QString &password)
{
    QUrl url("http://localhost:3000/api/auth/login");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject json;
    json["email"] = email;
    json["password"] = password;
    QJsonDocument doc(json);
    QByteArray data = doc.toJson();

    QNetworkReply *reply = m_networkManager->post(request, data);
    connect(reply, &QNetworkReply::finished, this, [=]()
            {
        handleNetworkReply(reply, true);
        reply->deleteLater(); });
}

void AuthModel::registerUser(const QString &email, const QString &password, const QString &name, const QString &dob)
{
    QUrl url("http://localhost:3000/api/auth/register");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject json;
    json["email"] = email;
    json["password"] = password;
    json["name"] = name;
    json["dateOfBirth"] = dob;
    QJsonDocument doc(json);
    QByteArray data = doc.toJson();

    QNetworkReply *reply = m_networkManager->post(request, data);
    connect(reply, &QNetworkReply::finished, this, [=]()
            {
        handleNetworkReply(reply, false);
        reply->deleteLater(); });
}

void AuthModel::handleNetworkReply(QNetworkReply *reply, bool isLogin)
{
    bool success = false;
    QString message;

    if (reply->error() == QNetworkReply::NoError)
    {
        QByteArray responseData = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(responseData);
        if (!doc.isNull() && doc.isObject())
        {
            QJsonObject obj = doc.object();
            message = obj["message"].toString();
            if (isLogin)
            {
                // Check for successful login by presence of token and user
                if (obj.contains("token") && obj.contains("user"))
                {
                    success = true;
                    QString token = obj["token"].toString();
                    QJsonObject user = obj["user"].toObject();
                    saveToken(token);
                    saveUserInfo(user);
                }
                else
                {
                    success = false; // Login failed, e.g., "Invalid email or password"
                }
            }
            else
            {
                // Assume registration success if message doesn't contain "error"
                success = !message.contains("error", Qt::CaseInsensitive);
            }
        }
        else
        {
            message = "Invalid response from server";
        }
    }
    else
    {
        message = reply->errorString();
    }

    if (isLogin)
    {
        emit loginResult(success, message);
    }
    else
    {
        emit registerResult(success, message);
    }
}

void AuthModel::saveToken(const QString &token)
{
    m_settings->setValue("jwt_token", token);
}

void AuthModel::saveUserInfo(const QJsonObject &user)
{
    m_settings->setValue("user/email", user["email"].toString());
    m_settings->setValue("user/name", user["name"].toString());
    m_settings->setValue("user/dateOfBirth", user["dateOfBirth"].toString());
    m_settings->setValue("user/role", user["role"].toString());
}

QString AuthModel::getToken() const
{
    return m_settings->value("jwt_token", "").toString();
}

void AuthModel::clearToken()
{
    m_settings->remove("jwt_token");
    m_settings->remove("user/email");
    m_settings->remove("user/name");
    m_settings->remove("user/dateOfBirth");
    m_settings->remove("user/role");
}