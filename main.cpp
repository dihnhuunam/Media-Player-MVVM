#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // Register singletons
    engine.addImportPath("qrc:/");
    qmlRegisterSingletonType(QUrl("qrc:/Source/View/NavigationManager.qml"), "NavigationManager", 1, 0, "NavigationManager");
    qmlRegisterSingletonType(QUrl("qrc:/Source/View/AppState.qml"), "AppState", 1, 0, "AppState");

    const QUrl url(QStringLiteral("qrc:/Source/View/Main.qml"));
    engine.load(url);

    return app.exec();
}