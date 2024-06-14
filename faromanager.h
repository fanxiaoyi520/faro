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
#include <thread>
//#include "EasyQtSql/src/EasyQtSql.h"
//#include "EasyQtSql/filemodel.h"
//#include "EasyQtSql/sqlmanager.h"
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
    void onCalculationSucSignal(const QString &response);
    void onCalculationFailSignal(const QString &error, int errorCode);

    int connect();
    void startScan(const QString &inputParams);
    bool init();
    void stopScan();
    void disconnect();
    void shutDown();
    void uploadFileHandle();
    void performCalculation(const QString &response,const QString &filePath);
    // 转换fls文件为ply文件~含下采样
    void convertFlsToPly(const QString& inFlsFilePath,const QString& outPlyFilePath);
    void convertFlsToPly(const QString& inFlsFilePath,const QString& outPlyFilePath,int xyCropDist,int zCropDist);
    void performCalculation(const QString &response,const QString &filePath,const QString &calParams);
    void zipFileHandle();
signals:
    void scanComplete(const QString& filePath);
    void scanProgress(int percent);
    void scanAbnormal(int percent);
    void uploadFileSucResult(const QString &response);
    void uploadFileFailResult(const QString &error, int errorCode);
    void performCalculationSucResult(const QString &response);
    void performCalculationFailResult(const QString &error, int errorCode);
private:
    FaroScannerController *faroScannerController;
    Http *http;
    //FileManager *fileManager;
    QJsonObject inputModel;
    QString *defaultFlsPath;
    NetworkHelper networkHelper;
};

#endif // FAROMANAGER_H
