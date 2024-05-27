#ifndef WIFISCANNER_H
#define WIFISCANNER_H

#include <QObject>
#include <windows.h>
#include <wlanapi.h>
#include <vector>
#include <string>
#include <thread>

#pragma comment(lib, "wlanapi.lib")

class WifiHelper : public QObject
{
    Q_OBJECT

public:
    explicit WifiHelper(QObject *parent = nullptr);
    ~WifiHelper();

public slots:
    void startWork();

signals:
    void networksResult(const QStringList list);

private:
    void scanNetworks();
    HANDLE wlanHandle;
    GUID interfaceGuid;
    std::thread m_thread;
    bool m_running;
};

#endif // WIFISCANNER_H
