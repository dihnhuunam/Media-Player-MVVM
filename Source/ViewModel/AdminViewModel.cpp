#include "AdminViewModel.hpp"

AdminViewModel::AdminViewModel(QObject *parent)
    : QObject(parent), m_adminModel(new AdminModel(this))
{
    connect(m_adminModel, &AdminModel::uploadFinished, this, [=](bool success, const QString &message, int songId)
            {
        Q_UNUSED(songId);
        emit uploadFinished(success, message); });
    connect(m_adminModel, &AdminModel::updateFinished, this, &AdminViewModel::updateFinished);
    connect(m_adminModel, &AdminModel::deleteFinished, this, &AdminViewModel::deleteFinished);
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