#include "networkhelper.h"

QNetworkConfigurationManager *NetworkHelper::networkConfigurationManager = nullptr;
QMutex NetworkHelper::mutex;
std::vector<std::function<void(bool)>> NetworkHelper::callbacks;

void NetworkHelper::initStaticMembers() {
    QMutexLocker locker(&mutex);
    if (!networkConfigurationManager) {
        networkConfigurationManager = new QNetworkConfigurationManager(nullptr);
        QObject::connect(networkConfigurationManager, &QNetworkConfigurationManager::configurationChanged,
                         NetworkHelper::onNetworkConfigurationChanged);
    }
}

bool NetworkHelper::checkNetworkStatus() {
    initStaticMembers();
    return networkConfigurationManager->isOnline();
}

void NetworkHelper::registerNetworkStatusChangedCallback(const std::function<void(bool)>& callback) {
    callbacks.push_back(callback);
}

void NetworkHelper::onNetworkConfigurationChanged(const QNetworkConfiguration &config) {
    Q_UNUSED(config);
    bool isOnline = networkConfigurationManager->isOnline();
    qDebug() << "Network configuration changed. Device is online:" << isOnline;

    // 通知所有注册的回调函数
    for (const auto& cb : callbacks) {
        cb(isOnline);
    }
}


