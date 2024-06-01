#ifndef FAROMANAGER_H
#define FAROMANAGER_H

#include <QObject>
#include "util.h"
#include "http.h"
#include "api.h"
#include "filemanager.h"
#include <QCoreApplication>
#include "networkhelper.h"
#include "wifihelper.h"
#include "faroscannercontroller.h"
class FaroManager : public QObject
{
    Q_OBJECT
public:
    explicit FaroManager(QObject *parent = nullptr);
    QString needUploadZipPath;
public slots:
    void onReplySucSignal(const QString &response);
    void onReplyFailSignal(const QString &error, int errorCode);

    int connect();
    void startScan(const QString &inputParams);
    bool init();
    void stopScan();
    void disconnect();
    void shutDown();
    void uploadFileHandle();
signals:
    void scanComplete();
    void scanProgress(int percent);
    void scanAbnormal(int percent);
    void uploadFileSucResult(const QString &response);
    void uploadFileFailResult(const QString &error, int errorCode);
private:
    FaroScannerController *faroScannerController;
    Http *http;
    FileManager *fileManager;
    QJsonObject inputModel;
    QString *defaultFlsPath;
};

#endif // FAROMANAGER_H
