#ifndef NETWORKHELPER_H
#define NETWORKHELPER_H

#include <QObject>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <functional>

class NetworkHelper : public QObject {
    Q_OBJECT
public:
    explicit NetworkHelper(QObject *parent = nullptr);
    ~NetworkHelper();

    void setNetworkStatusCallback(std::function<void(bool)> callback);
    void stopMonitoring();

private slots:
    void checkNetworkStatus();
    void onNetworkReplyFinished();

private:
    QNetworkAccessManager *manager;
    QTimer *checkTimer;
    std::function<void(bool)> networkStatusCallback;
    bool isMonitoring;
};

#endif // NETWORKHELPER_H
