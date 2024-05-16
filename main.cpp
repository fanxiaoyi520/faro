#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "http.h"
#include "api.h"
#include <QSettings>
#include "settingsmanager.h"
#include <QtQml>
#include <QTextCodec>
QObject *apiProvider(QQmlEngine *engine, QJSEngine *scriptEngine) {
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return Api::instance();
}

int main(int argc, char *argv[])
{
    //解决乱码问题
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QTextCodec *codec = QTextCodec::codecForName("utf8"); //GBK gbk
    QTextCodec::setCodecForLocale(codec);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("YYZS");
    app.setApplicationName("Measure");

    /**
        QSettings settings("YYZS","Measure");
        QStringList allKeys = settings.allKeys();
        for (const QString &key : allKeys) {
            settings.remove(key);
        }
    */

    qmlRegisterType<QNetworkAccessManager>("QNetworkAccessManager", 1, 0, "QNetworkAccessManager");
    qmlRegisterType<Http>("Http", 1, 0, "Http");
    qmlRegisterSingletonType<QObject>("Api", 1, 0, "Api",apiProvider);
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("settingsManager", SettingsManager::instance());

    engine.addImportPath(QStringLiteral("qrc:/"));
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
