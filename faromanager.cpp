#include "faromanager.h"

FaroManager::FaroManager(QObject *parent)
    : QObject(parent),
      faroScannerController
      (FaroScannerController::instance()),
      http(new Http(this))
{
    QObject::connect(http, &Http::qtreplySucSignal, this, &FaroManager::onReplySucSignal);
    QObject::connect(http, &Http::qtreplyFailSignal, this, &FaroManager::onReplySucSignal);
}

bool FaroManager::init()
{
    return faroScannerController->init();
}

int FaroManager::connect()
{
    return faroScannerController->connect();
}

void FaroManager::startScan(const QString &inputParams)
{
    qDebug() << "scan input params: " << inputParams;
    inputModel = Util::parseJsonStringToObject(inputParams);
    faroScannerController->startScan()
            .scanProgress([this](int percent){
        emit scanProgress(percent);
    }).complete([this](QString flsPath){
        defaultFlsPath = &flsPath;
        emit scanComplete();
    }).scanAbnormal([this](int scanStatus){
        Q_UNUSED(scanStatus);
        faroScannerController->disconnect();
        emit scanAbnormal(scanStatus);
    });
}

void FaroManager::stopScan()
{
    faroScannerController->stopScan();
}

void FaroManager::disconnect()
{
    faroScannerController->disconnect();
}

void FaroManager::shutDown()
{
    faroScannerController->shutDown();
}

//扫描完成之后压缩文件为zip上传
void FaroManager::uploadFileHandle(){
    qDebug() << "default fls path: " << *defaultFlsPath;
    Api *api = Api::instance();
    QString url = api->admin_sys_file_upload();
    QString zipFilePath = *defaultFlsPath+"/"+ZIPDIRECTORY;
    qDebug() << "zipFilePath:" << zipFilePath;
    QString zipDirectory = QDir(zipFilePath).filePath(QString());
    QDir dir;
    if (!dir.exists(zipDirectory)) {
        if (!dir.mkpath (zipDirectory)) {
            qDebug() << "Failed to create directory:" << zipDirectory;
        } else {
            qDebug() << "Directory created:" << zipDirectory;
        }
    }
    QString selectFile2DirPath = FileManager::getFilesInDirectory(*defaultFlsPath,QStringList() << "*.fls").first();
    qDebug() << "fls path: " << selectFile2DirPath;
    QString savePath = zipDirectory;
    bool result = fileManager->compression_zip_file(selectFile2DirPath, savePath);
    if (result) {
        qDebug() << "Compression successful!";
    } else {
        qDebug() << "Compression failed!";
    }
    needUploadZipPath = FileManager::getFilesInDirectory(savePath,QStringList() << "*.zip").first();
    qDebug() << "needUploadZipPath: " << needUploadZipPath;

    bool isOnline = NetworkHelper::checkNetworkStatus();
    qDebug() << "Current network status:" << isOnline;
    NetworkHelper::registerNetworkStatusChangedCallback([this,url](bool isOnline) {
        qDebug() << "Network status changed. Device is online:" << isOnline;
        if (isOnline){
            http->upload(url,needUploadZipPath);
        }
    });
}

void FaroManager::onReplySucSignal(const QString &response)
{
    qDebug() << "response: "<< response;
    //TODO: Failed to remove file: "另一个程序正在使用此文件，进程无法访问。"
    /**
    bool isremoveSuc = FileManager::removePath(needUploadZipPath);
    qDebug() << "isremoveSuc: " + QString::number(isremoveSuc) << response;
    */
    emit uploadFileSucResult(response);
}

void FaroManager::onReplyFailSignal(const QString &error, int errorCode)
{
    qDebug() << "error: "<< error << "errorCode: " << errorCode;
    emit uploadFileFailResult(error,errorCode);
}

