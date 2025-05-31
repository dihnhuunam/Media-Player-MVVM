#include "AdminViewModel.hpp"
#include <QDebug>

AdminViewModel::AdminViewModel(QObject *parent)
    : QAbstractListModel(parent), m_adminModel(new AdminModel(this))
{
    connect(m_adminModel, &AdminModel::uploadFinished, this, [=](bool success, const QString &message, int songId)
            {
        Q_UNUSED(songId);
        emit uploadFinished(success, message); });
    connect(m_adminModel, &AdminModel::updateFinished, this, &AdminViewModel::updateFinished);
    connect(m_adminModel, &AdminModel::deleteFinished, this, &AdminViewModel::deleteFinished);
    connect(m_adminModel, &AdminModel::songFetched, this, &AdminViewModel::songFetched);
    connect(m_adminModel, &AdminModel::usersFetched, this, [=](bool success, const QVariantList &users, const QString &errorMessage)
            {
        if (success) {
            beginResetModel();
            m_users.clear();
            for (const QVariant &user : users) {
                m_users.append(user.toMap());
            }
            qDebug() << "AdminViewModel: Updated users, count:" << m_users.count() << ", first email:" << (m_users.isEmpty() ? "N/A" : m_users.value(0)["email"].toString());
            endResetModel();
        }
        emit usersFetched(success, users, errorMessage); });
}

int AdminViewModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    qDebug() << "AdminViewModel: rowCount:" << m_users.count();
    return m_users.count();
}

QVariant AdminViewModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_users.count())
    {
        qDebug() << "AdminViewModel: Invalid index or out of range, row:" << index.row() << ", count:" << m_users.count();
        return QVariant();
    }

    const QVariantMap &user = m_users[index.row()];
    qDebug() << "AdminViewModel: data requested, row:" << index.row() << ", role:" << role << ", email:" << user["email"].toString();
    switch (role)
    {
    case IdRole:
        return user["id"];
    case EmailRole:
        return user["email"];
    case NameRole:
        return user["name"];
    case DateOfBirthRole:
        return user["date_of_birth"];
    case RoleRole:
        return user.contains("role") ? user["role"] : "user";
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> AdminViewModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[EmailRole] = "email";
    roles[NameRole] = "name";
    roles[DateOfBirthRole] = "date_of_birth";
    roles[RoleRole] = "role";
    return roles;
}

void AdminViewModel::fetchAllUsers()
{
    m_adminModel->fetchAllUsers();
}

void AdminViewModel::searchUsersByName(const QString &name)
{
    if (name.isEmpty())
    {
        m_adminModel->fetchAllUsers();
        return;
    }

    m_adminModel->searchUsersByName(name);
}

void AdminViewModel::uploadSong(const QString &title, const QString &genres, const QString &artists, const QString &filePath)
{
    m_adminModel->uploadSong(title, genres, artists, filePath);
}

void AdminViewModel::updateSong(int songId, const QString &title, const QString &genres, const QString &artists)
{
    m_adminModel->updateSong(songId, title, genres, artists);
}

void AdminViewModel::deleteSong(int songId)
{
    m_adminModel->deleteSong(songId);
}

void AdminViewModel::fetchSongById(int songId)
{
    m_adminModel->fetchSongById(songId);
}