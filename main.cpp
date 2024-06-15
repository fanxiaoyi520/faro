#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "http.h"
#include "api.h"
#include <QSettings>
#include "settingsmanager.h"
#include <QtQml>
#include <QTextCodec>
#include "faromanager.h"
#include "wifihelper.h"
#include "filemanager.h"
#include "crashwatcher.h"
#include <csignal>
#include "faroscannercontroller.h"

QObject *apiProvider(QQmlEngine *engine, QJSEngine *scriptEngine) {
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return Api::instance();
}

void testsql();
int main(int argc, char *argv[])
{
    qDebug() << "OpenSSL支持情况:" << QSslSocket::supportsSsl();
    qDebug()<<"QSslSocket="<<QSslSocket::sslLibraryBuildVersionString();


    //解决乱码问题
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QTextCodec *codec = QTextCodec::codecForName("UTF-8"); //GBK gbk
    QTextCodec::setCodecForLocale(codec);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("YYZS");
    app.setApplicationName("Measure");

    ///异常处理
    CrashWatcher watcher;
    app.installNativeEventFilter(&watcher);
    signal(SIGABRT, CrashWatcher::handleAbort);

    /**
        QSettings settings("YYZS","Measure");
        QStringList allKeys = settings.allKeys();
        for (const QString &key : allKeys) {
            settings.remove(key);
        }
    */

    qmlRegisterType<QNetworkAccessManager>("QNetworkAccessManager", 1, 0, "QNetworkAccessManager");
    qmlRegisterType<Http>("Http", 1, 0, "Http");
    qmlRegisterType<WifiHelper>("WifiHlper",1,0,"WifiHelper");
    qmlRegisterType<FaroManager>("FaroManager", 1, 0, "FaroManager");
    qmlRegisterSingletonType<QObject>("Api", 1, 0, "Api",apiProvider);
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("settingsManager", SettingsManager::instance());
    engine.rootContext()->setContextProperty("fileManager", FileManager::instance());
    engine.addImportPath(QStringLiteral("qrc:/"));
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    //测试代码
//    FaroScannerController::instance()->convertFlsToPly("D:/SDK_File_020.fls","D:/ghhhx.ply");

    return app.exec();
}


/**
void testsql(){
    SqlManager::initDefaultDataBase();
    SqlManager::createTableWithName();
    Row rowInstance = {
        1,                      // stationId
        "Station123",           // stationNo
        "Task456",              // taskNo
        "/path/to/file.txt",    // filePath
        "2023-01-01 12:00:00",  // fileCreateTime
        "2023-01-02 12:00:00",  // fileUpdateTime
        true,                   // isSelected
        0,                      // mapMode
        0,                      // colorMode
        0,                      // scanMode
        "BlockA",               // blockName
        "Floor1",               // floorName
        "ProjectX",             // projectName
        "Room101",              // roomName
        "RoomTask1",            // roomTaskNo
        "Stage1",               // stageType
        "Unit1",                // unitName
        "1",                    // block_id
        "1",                    // floor_id
        "1",                    // project_id
        "1",                    // room_id
        "1",                    // unit_id
        0,                      // stationType
        0                       // measure
    };
    SqlManager::insertData(rowInstance);
}
*/
