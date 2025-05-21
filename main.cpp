#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "AuthViewModel.hpp"
#include "SongViewModel.hpp"
#include "PlaylistViewModel.hpp"
#include "AppState.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // Register singletons
    engine.addImportPath("qrc:/");
    qmlRegisterSingletonType(QUrl("qrc:/Source/View/NavigationManager.qml"), "NavigationManager", 1, 0, "NavigationManager");
    qmlRegisterSingletonInstance<AppState>("AppState", 1, 0, "AppState", AppState::instance());

    // Register AuthViewModel as context property
    AuthViewModel authViewModel;
    engine.rootContext()->setContextProperty("authViewModel", &authViewModel);

    // Register SongViewModel as context property
    SongViewModel songViewModel;
    engine.rootContext()->setContextProperty("songViewModel", &songViewModel);

    // Register PlaylistViewModel as context property
    PlaylistViewModel playlistViewModel;
    engine.rootContext()->setContextProperty("playlistViewModel", &playlistViewModel);

    const QUrl url(QStringLiteral("qrc:/Source/View/Main.qml"));
    engine.load(url);

    return app.exec();
}