#include "AuthModel.hpp"
#include "AppConfig.hpp"
#include "AppState.hpp"
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
    QUrl url(AppConfig::instance().getAuthLoginEndpoint());
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
    QUrl url(AppConfig::instance().getAuthRegisterEndpoint());
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
                    success = false;
                }
            }
            else
            {
                success = !message.contains("error", Qt::CaseInsensitive);
            }
        }
        else
        {
            message = "Phản hồi không hợp lệ từ server";
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
    AppState::instance()->loadUserInfo(); // Cập nhật trạng thái trong AppState
}

void AuthModel::saveUserInfo(const QJsonObject &user)
{
    m_settings->setValue("user/email", user["email"].toString());
    m_settings->setValue("user/name", user["name"].toString());
    m_settings->setValue("user/dateOfBirth", user["dateOfBirth"].toString());
    m_settings->setValue("user/role", user["role"].toString());
    AppState::instance()->loadUserInfo(); // Cập nhật trạng thái trong AppState
}

QString AuthModel::getToken() const
{
    return m_settings->value("jwt_token", "").toString();
}

void AuthModel::clearToken()
{
    AppState::instance()->clearUserInfo(); // Gọi phương thức clearUserInfo của AppState
}