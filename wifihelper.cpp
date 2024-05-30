#include "wifihelper.h"
#include <thread>
#include <QDebug>


WifiHelper::WifiHelper(QObject *parent) : QObject(parent), wlanHandle(nullptr),m_running(false)
{
    DWORD negotiatedVersion;
    if (WlanOpenHandle(2, NULL, &negotiatedVersion, &wlanHandle) != ERROR_SUCCESS) {
        throw std::runtime_error("Failed to open WLAN handle");
    }

    PWLAN_INTERFACE_INFO_LIST pIfList = NULL;
    if (WlanEnumInterfaces(wlanHandle, NULL, &pIfList) != ERROR_SUCCESS) {
        WlanCloseHandle(wlanHandle, NULL);
        throw std::runtime_error("Failed to enumerate WLAN interfaces");
    }

    if (pIfList->dwNumberOfItems > 0) {
        interfaceGuid = pIfList->InterfaceInfo[0].InterfaceGuid;
    } else {
        WlanCloseHandle(wlanHandle, NULL);
        throw std::runtime_error("No WLAN interfaces found");
    }

    WlanFreeMemory(pIfList);
}

WifiHelper::~WifiHelper()
{
    if (wlanHandle != nullptr) {
        WlanCloseHandle(wlanHandle, NULL);
    }
    if (m_thread.joinable()) {
       m_thread.join();
    }
}

void WifiHelper::startWork()
{
    if (!m_running) {
          m_thread = std::thread(&WifiHelper::scanNetworks, this);
          m_running = true;
    }
    else{
        m_running = false;
        m_thread.join();
        startWork();
    }
}




void WifiHelper::scanNetworks()
{
    QStringList list;

    if (WlanScan(wlanHandle, &interfaceGuid, NULL, NULL, NULL) != ERROR_SUCCESS) {
        throw std::runtime_error("Failed to initiate WLAN scan");
    }

    std::this_thread::sleep_for(std::chrono::seconds(4));

    PWLAN_AVAILABLE_NETWORK_LIST pNetworkList = NULL;
    if (WlanGetAvailableNetworkList(wlanHandle, &interfaceGuid, 0, NULL, &pNetworkList) != ERROR_SUCCESS) {
        throw std::runtime_error("Failed to get available network list");
    }

    for (unsigned int i = 0; i < pNetworkList->dwNumberOfItems; ++i) {
        WLAN_AVAILABLE_NETWORK network = pNetworkList->Network[i];
        QString itemNetWork = QString::fromUtf8(reinterpret_cast<const char*>(network.dot11Ssid.ucSSID), network.dot11Ssid.uSSIDLength);
        if(!list.contains(itemNetWork)){
            list.append(itemNetWork);
        }
    }


    WlanFreeMemory(pNetworkList);
    emit networksResult(list);
}
