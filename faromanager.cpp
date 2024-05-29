#include "faromanager.h"

FaroManager::FaroManager(QObject *parent)
    : QObject(parent),
      http(new Http(this))
{
    connect(http, &Http::qtreplySucSignal, this, &FaroManager::onReplySucSignal);
    connect(http, &Http::qtreplyFailSignal, this, &FaroManager::onReplySucSignal);
}

bool FaroManager::init()
{
    return true;//faroScannerController.init();
}

#include "faroscannercontroller.h"
void FaroManager::startScan(const QString &inputParams)
{
    qDebug() << "scan input params: " << inputParams;

    Api *api = Api::instance();
    QString url = api->admin_sys_file_upload();
    QString path = "D:\\fls\\SDK_File_000.zip";

    QString selectFile2DirPath = "D:\\fls\\SDK_File_000.fls";
    QString savePath = "D:\\fls\\zip";
    bool result = fileManager->compression_zip_file(selectFile2DirPath, savePath);
    if (result) {
        qDebug() << "Compression successful!";
    } else {
        qDebug() << "Compression failed!";
    }

    http->upload(url,path);

//    FaroScannerController faroScannerController;
//    faroScannerController.init();
//    faroScannerController.connect();
//    faroScannerController.startScan();
}

void FaroManager::onReplySucSignal(const QString &response)
{
    qDebug() << "response: "<< response;

}

void FaroManager::onReplyFailSignal(const QString &error, int errorCode)
{
    qDebug() << "error: "<< error << "errorCode: " << errorCode;
}
