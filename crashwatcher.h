#ifndef CRASHWATCHER_H
#define CRASHWATCHER_H

#include <QGuiApplication>
#include <QAbstractNativeEventFilter>
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include "wifihelper.h"
#include "faroscannercontroller.h"
#include "settingsmanager.h"
#include "util.h"

class CrashWatcher : public QAbstractNativeEventFilter
{
protected:
    bool nativeEventFilter(const QByteArray &eventType, void *message, long *result) override {
        // 检查是否为崩溃事件
        if (eventType == "windows_nt_exception") {
            // 保存崩溃信息
            QFile crashLog("crash_log.txt");
            crashLog.open(QIODevice::WriteOnly | QIODevice::Text);
            QTextStream stream(&crashLog);
            stream << "Application crashed!" << endl;
            crashLog.close();
            FaroScannerController::instance()->disconnect();
            WifiHelper wifiHelper;
            QString wifiName = wifiHelper.queryInterfaceName();
            QString wifijson = SettingsManager::instance()->getValue(SettingsManager::instance()->currentDevice());
            QJsonObject wifiObject = Util::parseJsonStringToObject(wifijson);
            if (wifiName == wifiObject.value("wifiName").toString()) {
                wifiHelper.disConnectWifi();
            }
            return true;
        }
        return false;
    }

public:
    static void handleAbort(int sig) {
        Q_UNUSED(sig);
        qDebug() << "Caught SIGABRT, doing some cleanup...";
        FaroScannerController::instance()->disconnect();
        WifiHelper wifiHelper;
        QString wifiName = wifiHelper.queryInterfaceName();
        qDebug() << "wifi name: " << wifiName;
        QString wifijson = SettingsManager::instance()->getValue(SettingsManager::instance()->currentDevice());
        QJsonObject wifiObject = Util::parseJsonStringToObject(wifijson);
        if (wifiName == wifiObject.value("wifiName").toString()) {
            wifiHelper.disConnectWifi();
        }
    }
};

#endif // CRASHWATCHER_H
