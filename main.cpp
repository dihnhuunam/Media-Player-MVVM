#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "AuthViewModel.hpp"
#include "SongViewModel.hpp"
#include "PlaylistViewModel.hpp"
#include "AppState.hpp"
#include "AdminViewModel.hpp"
#include "UartViewModel.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // Register singletons
    engine.addImportPath("qrc:/");
    qmlRegisterSingletonType(QUrl("qrc:/Source/View/Helper/NavigationManager.qml"), "NavigationManager", 1, 0, "NavigationManager");
    qmlRegisterSingletonInstance<AppState>("AppState", 1, 0, "AppState", AppState::instance());

    // Register AuthViewModel
    AuthViewModel authViewModel;
    engine.rootContext()->setContextProperty("authViewModel", &authViewModel);

    // Register SongViewModel
    SongViewModel songViewModel;
    engine.rootContext()->setContextProperty("songViewModel", &songViewModel);

    // Register PlaylistViewModel
    PlaylistViewModel playlistViewModel;
    engine.rootContext()->setContextProperty("playlistViewModel", &playlistViewModel);

    // Register AdminViewModel
    AdminViewModel adminViewModel;
    engine.rootContext()->setContextProperty("adminViewModel", &adminViewModel);

    // Register UartViewModel and link with SongViewModel
    UartViewModel uartViewModel(&songViewModel);
    engine.rootContext()->setContextProperty("uartViewModel", &uartViewModel);

    // Start UART communication
    uartViewModel.startUart("/dev/ttyACM0");

    const QUrl url("qrc:/Source/View/Main.qml");
    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}