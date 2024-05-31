#ifndef WIFISCANNER_H
#define WIFISCANNER_H

#include <QObject>
#include <windows.h>
#include <wlanapi.h>
#include <vector>
#include <string>
#include <thread>
#include <objbase.h>
#include <wtypes.h>
#include <iostream>
#include <QDebug>
#include "nativeWifiConnect.h"

#pragma comment(lib, "wlanapi.lib")
#pragma comment(lib, "ole32.lib")

class WifiHelper : public QObject
{
    Q_OBJECT

public:
    explicit WifiHelper(QObject *parent = nullptr);
    ~WifiHelper();



public slots:
    void startWork();
    void connectToWiFi(const QString qssid, const QString qpassword);
    void disConnectWifi();

signals:
    void networksResult(const QStringList list);

private:
    void scanNetworks();
    HANDLE wlanHandle;
    GUID interfaceGuid;
    std::thread m_thread;
    bool m_running;
    NativeWifiConnect mNativeWifi;
    std::map<std::string, int>		mWifiMap;
};

#endif // WIFISCANNER_H
