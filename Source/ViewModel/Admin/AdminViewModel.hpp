#ifndef ADMINVIEWMODEL_HPP
#define ADMINVIEWMODEL_HPP

#include <QAbstractListModel>
#include "AdminModel.hpp"

class AdminViewModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit AdminViewModel(QObject *parent = nullptr);

    enum UserRoles
    {
        IdRole = Qt::UserRole + 1,
        EmailRole,
        NameRole,
        DateOfBirthRole,
        RoleRole
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

public slots:
    void uploadSong(const QString &title, const QString &genres, const QString &artists, const QString &filePath);
    void updateSong(int songId, const QString &title, const QString &genres, const QString &artists);
    void deleteSong(int songId);
    void fetchSongById(int songId);
    void fetchAllUsers();
    void searchUsersByName(const QString &name);

signals:
    void uploadFinished(bool success, const QString &message);
    void updateFinished(bool success, const QString &message);
    void deleteFinished(bool success, const QString &message);
    void songFetched(bool success, const QString &title, const QString &genres, const QString &artists, const QString &errorMessage = "");
    void usersFetched(bool success, const QVariantList &users, const QString &errorMessage = "");

private:
    AdminModel *m_adminModel;
    QList<QVariantMap> m_users;
};

#endif // ADMINVIEWMODEL_HPP