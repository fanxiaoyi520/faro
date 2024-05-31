#ifndef FAROMANAGER_H
#define FAROMANAGER_H

#include <QObject>
//#include "faroscannercontroller.h"
#include "util.h"
#include "http.h"
#include "api.h"
#include "filemanager.h"
#include <QCoreApplication>
#include "faroscannercontroller.h"
#include "networkhelper.h"
class FaroManager : public QObject
{
    Q_OBJECT
public:
    explicit FaroManager(QObject *parent = nullptr);
    Q_INVOKABLE bool init();
    Q_INVOKABLE void startScan(const QString &inputParams);
    Q_INVOKABLE void stopScan();
    Q_INVOKABLE void disconnect();
    Q_INVOKABLE void shutDown();
    QString needUploadZipPath;
public slots:
    void onReplySucSignal(const QString &response);
    void onReplyFailSignal(const QString &error, int errorCode);
    void scannerCompleteSlots(int status);
    void scanProgressSlots(int percent);
signals:

private:
    FaroScannerController *faroScannerController;
    Http *http;
    FileManager *fileManager;
    void uploadFileHandle();
};

#endif // FAROMANAGER_H
