#include "networkhelper.h"
#include <QUrl>
#include <QDebug>

NetworkHelper::NetworkHelper(QObject *parent) : QObject(parent), manager(new QNetworkAccessManager(this)), checkTimer(new QTimer(this)), isMonitoring(true) {
    connect(checkTimer, &QTimer::timeout, this, &NetworkHelper::checkNetworkStatus);
    //checkTimer->start(5000); // 每5秒检查一次网络状态
}

NetworkHelper::~NetworkHelper() {
    stopMonitoring();
}

void NetworkHelper::setNetworkStatusCallback(std::function<void(bool)> callback) {
    isMonitoring = true;
    checkTimer->start(2500);
    networkStatusCallback = callback;
}

void NetworkHelper::stopMonitoring() {
    isMonitoring = false;
    checkTimer->stop();
    // 如果需要，可以在这里断开所有的信号连接或执行清理工作
}

void NetworkHelper::checkNetworkStatus() {
    if (!isMonitoring) return;

    QNetworkRequest request(QUrl("http://www.baidu.com"));
    QNetworkReply *reply = manager->get(request);
    QObject::connect(reply, &QNetworkReply::finished, this, &NetworkHelper::onNetworkReplyFinished);
}

void NetworkHelper::onNetworkReplyFinished() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    reply->deleteLater();
    bool isOnline = (reply->error() == QNetworkReply::NoError);
    if (networkStatusCallback) {
        networkStatusCallback(isOnline);
    }
}
