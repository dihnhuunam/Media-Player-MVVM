#ifndef ADMINVIEWMODEL_HPP
#define ADMINVIEWMODEL_HPP

#include <QObject>
#include "AdminModel.hpp"

class AdminViewModel : public QObject
{
    Q_OBJECT
public:
    explicit AdminViewModel(QObject *parent = nullptr);

public slots:
    void uploadSong(const QString &title, const QString &genres, const QString &artists, const QString &filePath);
    void updateSong(int songId, const QString &title, const QString &genres, const QString &artists);
    void deleteSong(int songId);

signals:
    void uploadFinished(bool success, const QString &message);
    void updateFinished(bool success, const QString &message);
    void deleteFinished(bool success, const QString &message);

private:
    AdminModel *m_adminModel;
};

#endif // ADMINVIEWMODEL_HPP