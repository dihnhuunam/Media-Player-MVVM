#include "AdminViewModel.hpp"

AdminViewModel::AdminViewModel(QObject *parent)
    : QObject(parent), m_adminModel(new AdminModel(this))
{
    connect(m_adminModel, &AdminModel::uploadFinished, this, [=](bool success, const QString &message, int songId)
            {
        Q_UNUSED(songId); // Not used in QML for now
        emit uploadFinished(success, message); });
}

void AdminViewModel::uploadSong(const QString &title, const QString &genres, const QString &artists, const QString &filePath)
{
    m_adminModel->uploadSong(title, genres, artists, filePath);
}