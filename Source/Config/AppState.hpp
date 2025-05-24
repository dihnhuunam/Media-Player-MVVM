#ifndef APPSTATE_HPP
#define APPSTATE_HPP

#include <QObject>
#include <QVariantList>
#include <QSettings>

class AppState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentPlaylistName READ currentPlaylistName WRITE setCurrentPlaylistName NOTIFY currentPlaylistNameChanged)
    Q_PROPERTY(QVariantList currentMediaFiles READ currentMediaFiles WRITE setCurrentMediaFiles NOTIFY currentMediaFilesChanged)
    Q_PROPERTY(QString currentMediaTitle READ currentMediaTitle WRITE setCurrentMediaTitle NOTIFY currentMediaTitleChanged)
    Q_PROPERTY(QString currentMediaArtist READ currentMediaArtist WRITE setCurrentMediaArtist NOTIFY currentMediaArtistChanged)
    Q_PROPERTY(int currentPlaylistId READ currentPlaylistId WRITE setCurrentPlaylistId NOTIFY currentPlaylistIdChanged)
    Q_PROPERTY(bool isAuthenticated READ isAuthenticated NOTIFY authenticationChanged)              // Thêm thuộc tính xác thực
    Q_PROPERTY(QString email READ email WRITE setEmail NOTIFY emailChanged)                         // Thêm thuộc tính email
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)                             // Thêm thuộc tính name
    Q_PROPERTY(QString dateOfBirth READ dateOfBirth WRITE setDateOfBirth NOTIFY dateOfBirthChanged) // Thêm thuộc tính dob
    Q_PROPERTY(QString role READ role WRITE setRole NOTIFY roleChanged)                             // Thêm thuộc tính role

public:
    static AppState *instance();
    QString currentPlaylistName() const;
    QVariantList currentMediaFiles() const;
    QString currentMediaTitle() const;
    QString currentMediaArtist() const;
    int currentPlaylistId() const;
    bool isAuthenticated() const; // Chuyển phương thức isAuthenticated
    QString email() const;
    QString name() const;
    QString dateOfBirth() const;
    QString role() const;

public slots:
    void setCurrentPlaylistName(const QString &name);
    void setCurrentMediaFiles(const QVariantList &files);
    void setCurrentMediaTitle(const QString &title);
    void setCurrentMediaArtist(const QString &artist);
    void setCurrentPlaylistId(int id);
    void setState(const QVariantMap &state);
    void setEmail(const QString &email);
    void setName(const QString &name);
    void setDateOfBirth(const QString &dob);
    void setRole(const QString &role);
    void loadUserInfo();  // Phương thức mới để load thông tin từ QSettings
    void clearUserInfo(); // Phương thức để xóa thông tin người dùng (khi đăng xuất)

signals:
    void currentPlaylistNameChanged();
    void currentMediaFilesChanged();
    void currentMediaTitleChanged();
    void currentMediaArtistChanged();
    void currentPlaylistIdChanged();
    void authenticationChanged(); // Signal cho trạng thái xác thực
    void emailChanged();
    void nameChanged();
    void dateOfBirthChanged();
    void roleChanged();

private:
    AppState(QObject *parent = nullptr);
    static AppState *m_instance;
    QString m_currentPlaylistName;
    QVariantList m_currentMediaFiles;
    QString m_currentMediaTitle;
    QString m_currentMediaArtist;
    int m_currentPlaylistId;
    QString m_email;        // Thêm biến lưu email
    QString m_name;         // Thêm biến lưu name
    QString m_dateOfBirth;  // Thêm biến lưu dateOfBirth
    QString m_role;         // Thêm biến lưu role
    bool m_isAuthenticated; // Thêm biến lưu trạng thái xác thực
    QSettings *m_settings;  // Thêm QSettings để truy cập thông tin
};

#endif // APPSTATE_HPP