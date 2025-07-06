#include "AuthModel.hpp"
#include "AppConfig.hpp"
#include "AppState.hpp"
#include <QUrl>
#include <QNetworkRequest>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDebug>
#include <QDateTime>

AuthModel::AuthModel(QObject *parent)
    : QObject(parent),
      m_networkManager(new QNetworkAccessManager(this)),
      m_settings(new QSettings("MediaPlayer", "Auth", this))
{
}

void AuthModel::loginUser(const QString &email, const QString &password)
{
    if (email.isEmpty() || password.isEmpty())
    {
        emit loginResult(false, "Email and password are required");
        return;
    }

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
    if (email.isEmpty() || password.isEmpty() || name.isEmpty() || dob.isEmpty())
    {
        emit registerResult(false, "Email, password, name, and date of birth are required");
        return;
    }

    QUrl url(AppConfig::instance().getAuthRegisterEndpoint());
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject json;
    json["email"] = email;
    json["password"] = password;
    json["name"] = name;
    QString formattedDob = dob;
    if (!dob.isEmpty())
    {
        QDateTime date = QDateTime::fromString(dob, "yyyy-MM-dd");
        if (!date.isValid())
        {
            date = QDateTime::fromString(dob, Qt::ISODate);
        }
        if (date.isValid())
        {
            formattedDob = date.toUTC().toString(Qt::ISODate);
        }
        else
        {
            emit registerResult(false, "Invalid dateOfBirth format");
            return;
        }
    }
    json["dateOfBirth"] = formattedDob;
    QJsonDocument doc(json);
    QByteArray data = doc.toJson();

    QNetworkReply *reply = m_networkManager->post(request, data);
    connect(reply, &QNetworkReply::finished, this, [=]()
            {
        handleNetworkReply(reply, false);
        reply->deleteLater(); });
}

void AuthModel::updateProfile(int userId, const QString &name, const QString &dob, const QString &currentPassword, const QString &newPassword)
{
    if (userId <= 0)
    {
        emit profileUpdateResult(false, "Invalid user ID");
        return;
    }

    QUrl url(AppConfig::instance().getAuthUpdateEndpoint(userId));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", "Bearer " + getToken().toUtf8());

    QJsonObject json;
    bool hasData = false;

    if (!name.isEmpty() && name != AppState::instance()->name())
    {
        json["name"] = name;
        hasData = true;
    }

    QString formattedDob = dob;
    if (!dob.isEmpty() && dob != AppState::instance()->dateOfBirth())
    {
        QDateTime date = QDateTime::fromString(dob, "yyyy-MM-dd");
        if (!date.isValid())
        {
            date = QDateTime::fromString(dob, Qt::ISODate);
        }
        if (date.isValid())
        {
            formattedDob = date.toUTC().toString(Qt::ISODate);
            json["dateOfBirth"] = formattedDob;
            hasData = true;
        }
        else
        {
            emit profileUpdateResult(false, "Invalid dateOfBirth format");
            return;
        }
    }

    if (!currentPassword.isEmpty() && !newPassword.isEmpty())
    {
        json["password"] = newPassword;
        hasData = true;
    }
    else if (currentPassword.isEmpty() != newPassword.isEmpty())
    {
        emit profileUpdateResult(false, "Both current and new passwords are required for password change");
        return;
    }

    if (!hasData)
    {
        emit profileUpdateResult(false, "No valid data provided for update");
        return;
    }

    QJsonDocument doc(json);
    QByteArray data = doc.toJson();

    QNetworkReply *reply = m_networkManager->put(request, data);
    connect(reply, &QNetworkReply::finished, this, [=]()
            {
        handleNetworkReply(reply, false, true);
        reply->deleteLater(); });
}

void AuthModel::handleNetworkReply(QNetworkReply *reply, bool isLogin, bool isUpdate)
{
    bool success = false;
    QString message;

    // Check HTTP status code
    int httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    if (reply->error() == QNetworkReply::NoError && (httpStatus >= 200 && httpStatus < 300))
    {
        QByteArray responseData = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(responseData);
        if (!doc.isNull() && doc.isObject())
        {
            QJsonObject obj = doc.object();
            message = obj["message"].toString();
            success = !message.contains("error", Qt::CaseInsensitive);

            if (isLogin && success)
            {
                if (obj.contains("token") && obj.contains("user"))
                {
                    QString token = obj["token"].toString();
                    QJsonObject user = obj["user"].toObject();
                    saveToken(token);
                    saveUserInfo(user);
                }
                else
                {
                    success = false;
                    message = "Invalid login response from server";
                }
            }
            else if (isUpdate && success)
            {
                if (obj.contains("user"))
                {
                    QJsonObject user = obj["user"].toObject();
                    saveUserInfo(user);
                }
            }
        }
        else
        {
            success = false;
            message = "Invalid response from server";
        }
    }
    else
    {
        // Handle specific HTTP status codes
        QByteArray responseData = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(responseData);
        if (!doc.isNull() && doc.isObject())
        {
            QJsonObject obj = doc.object();
            message = obj["message"].toString();
            if (message.isEmpty())
            {
                message = reply->errorString();
            }
        }
        else
        {
            message = reply->errorString();
        }

        // Map HTTP status codes to specific messages if backend doesn't provide one
        switch (httpStatus)
        {
        case 400:
            if (message.isEmpty())
                message = "Bad request: Invalid input data";
            break;
        case 401:
            if (message.isEmpty())
                message = "Unauthorized: Invalid credentials";
            break;
        case 403:
            if (message.isEmpty())
                message = "Forbidden: Insufficient permissions";
            break;
        case 404:
            if (message.isEmpty())
                message = "Resource not found";
            break;
        case 409:
            if (message.isEmpty())
                message = "Conflict: Resource already exists";
            break;
        case 500:
            if (message.isEmpty())
                message = "Internal server error";
            break;
        default:
            if (message.isEmpty())
                message = "Unknown error occurred";
            break;
        }
    }

    if (isLogin)
    {
        emit loginResult(success, message);
    }
    else if (isUpdate)
    {
        emit profileUpdateResult(success, message);
    }
    else
    {
        emit registerResult(success, message);
    }
}

void AuthModel::saveToken(const QString &token)
{
    m_settings->setValue("jwt_token", token);
    AppState::instance()->loadUserInfo();
}

void AuthModel::saveUserInfo(const QJsonObject &user)
{
    AppState *appState = AppState::instance();
    QString currentEmail = appState->email();
    QString currentName = appState->name();
    QString currentDateOfBirth = appState->dateOfBirth();
    QString currentRole = appState->role();
    int currentUserId = appState->userId();

    QString email = user.contains("email") ? user["email"].toString() : currentEmail;
    QString name = user.contains("name") ? user["name"].toString() : currentName;
    QString dateOfBirth = user.contains("dateOfBirth") ? user["dateOfBirth"].toString() : currentDateOfBirth;
    QString role = user.contains("role") ? user["role"].toString() : currentRole;
    int userId = user.contains("id") ? user["id"].toInt() : currentUserId;

    if (!dateOfBirth.isEmpty())
    {
        QDateTime date = QDateTime::fromString(dateOfBirth, Qt::ISODate);
        if (!date.isValid())
        {
            qDebug() << "Invalid ISO 8601 date format for dob in saveUserInfo:" << dateOfBirth;
            dateOfBirth = currentDateOfBirth;
        }
    }

    if (currentEmail != email)
    {
        m_settings->setValue("user/email", email);
        appState->setEmail(email);
    }
    if (currentName != name)
    {
        m_settings->setValue("user/name", name);
        appState->setName(name);
    }
    if (currentDateOfBirth != dateOfBirth)
    {
        m_settings->setValue("user/dateOfBirth", dateOfBirth);
        appState->setDateOfBirth(dateOfBirth);
    }

    if (currentUserId != userId && userId != 0)
    {
        m_settings->setValue("user/id", userId);
        appState->setUserId(userId);
    }
    if (currentRole != role && !role.isEmpty())
    {
        m_settings->setValue("user/role", role);
        appState->setRole(role);
    }
}

QString AuthModel::getToken() const
{
    return m_settings->value("jwt_token", "").toString();
}

int AuthModel::getUserId() const
{
    return m_settings->value("user/id", -1).toInt();
}

void AuthModel::clearToken()
{
    AppState::instance()->clearUserInfo();
}