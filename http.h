﻿#ifndef HTTP_H
#define HTTP_H

#include <QObject>
#include<QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QHttpPart>
#include <QHttpMultiPart>
#include <QUrl>
#include "httpclient.h"
#include "settingsmanager.h"
#include <QString>
#include <thread>
#include "uploadnetthread.h"

class Http : public QObject
{
    Q_OBJECT
public:

    explicit Http(QObject *parent = nullptr);
    Q_INVOKABLE void downloadReplyFinished(const QString &response);
    Q_INVOKABLE void replyFinished(const QString &response);
    Q_INVOKABLE void replyFail(const QString &error, int errorCode);

    Q_INVOKABLE void get(QString url);
    Q_INVOKABLE void get(QString url,const QMap<QString, QVariant> &ps);

    Q_INVOKABLE void post(QString url);
    Q_INVOKABLE void post(QString url,const QMap<QString, QVariant> &ps);
    Q_INVOKABLE void postForm(QString url);
    Q_INVOKABLE void put(QString url,const QMap<QString, QVariant> &ps);
    Q_INVOKABLE void loginPost(QString url,const QMap<QString, QVariant> &ps,const QMap<QString, QVariant> &headers);

    Q_INVOKABLE void download(QString url,const QMap<QString, QVariant> &ps,int allcount);

    Q_INVOKABLE QString getActiveWifi();
    Q_INVOKABLE void delayedExecution(const QString &response);
public slots:
    void upload(QString url,QString path);

signals:
    void downloadReplyFinishedSignal(const QString &response);
    void replySucSignal(const QString &response);
    void replyFailSignal(const QString &error, int errorCode);
    void qtreplySucSignal(const QString &response);
    void qtreplyFailSignal(const QString &error, int errorCode);
private:
    QNetworkAccessManager *manager;
<<<<<<< HEAD
    //QString BASE_URL = "http://192.168.2.222:9002";
=======
//    QString BASE_URL = "http://192.168.2.222:9002";
>>>>>>> 1276cd8682e23ae5c9d2345d55f449c6dd9dfb62
    void uploadExcuseThread(QString url,QString path);
    std::thread m_thread;
    bool m_running = false;
    QString BASE_URL = "http://gateway.metadigital.net.cn";
    int count = 0;
};

#endif // HTTP_H
