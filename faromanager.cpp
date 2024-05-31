#include "faromanager.h"

FaroManager::FaroManager(QObject *parent)
    : QObject(parent),
      faroScannerController
      (FaroScannerController::instance()),
      http(new Http(this))
{
    connect(faroScannerController, &FaroScannerController::scannerComplete, this, &FaroManager::scannerCompleteSlots);
    connect(faroScannerController, &FaroScannerController::scanProgress, this, &FaroManager::scanProgressSlots);
    connect(http, &Http::qtreplySucSignal, this, &FaroManager::onReplySucSignal);
    connect(http, &Http::qtreplyFailSignal, this, &FaroManager::onReplySucSignal);
}

bool FaroManager::init()
{
    return faroScannerController->init();
}


void FaroManager::startScan(const QString &inputParams)
{
    qDebug() << "scan input params: " << inputParams;
    faroScannerController->connect();
    faroScannerController->startScan();
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
    Api *api = Api::instance();
    QString url = api->admin_sys_file_upload();
    QString zipFilePath = FileManager::getFlsPath()+"/"+ZIPDIRECTORY;
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

    QString selectFile2DirPath = "D:\\fls\\SDK_File_000.fls";
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
    if (isOnline){
        http->upload(url,needUploadZipPath);
    }

    NetworkHelper::registerNetworkStatusChangedCallback([](bool isOnline) {
        qDebug() << "Network status changed. Device is online:" << isOnline;
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
}

void FaroManager::onReplyFailSignal(const QString &error, int errorCode)
{
    qDebug() << "error: "<< error << "errorCode: " << errorCode;
}

void FaroManager::scannerCompleteSlots(int status)
{
    Q_UNUSED(status);
    qDebug() << "Scanner complete!!!";
    faroScannerController->stopScan();
    faroScannerController->disconnect();
    uploadFileHandle();
}

void FaroManager::scanProgressSlots(int percent)
{
    qDebug() << "scan progress: " << percent;
}
