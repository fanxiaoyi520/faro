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

    void startScan(const QString &inputParams);
    bool init();
    void stopScan();
    void disconnect();
    void shutDown();
signals:
    void scanComplete();
    void scanProgress(int percent);
private:
    FaroScannerController *faroScannerController;
    Http *http;
    FileManager *fileManager;
    void uploadFileHandle();
};

#endif // FAROMANAGER_H
