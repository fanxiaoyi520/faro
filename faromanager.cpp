#include "faromanager.h"

FaroManager::FaroManager(QObject *parent)
    : QObject(parent),
      faroScannerController
      (FaroScannerController::instance()),
      http(new Http(this))
{

    QObject::connect(http, &Http::qtreplySucSignal, this, &FaroManager::onReplySucSignal);
    QObject::connect(http, &Http::qtreplyFailSignal, this, &FaroManager::onReplyFailSignal);
    QObject::connect(http, &Http::replySucSignal, this, &FaroManager::onCalculationSucSignal);
    QObject::connect(http, &Http::replyFailSignal, this, &FaroManager::onCalculationFailSignal);
}

bool FaroManager::init()
{
    return faroScannerController->init();
}

int FaroManager::connect()
{
    qDebug() << "enter connect";
    return faroScannerController->connect();
}

void FaroManager::startScan(const QString &inputParams)
{
    qDebug() << "scan input params: " << inputParams;
    inputModel = Util::parseJsonStringToObject(inputParams);
    faroScannerController->startScan(inputParams)
            .scanProgress([this](int percent){
        emit scanProgress(percent);
    }).complete([this](QString flsPath){
        defaultFlsPath = &flsPath;
        emit scanComplete(flsPath);
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
    Api *api = Api::instance();
    QString url = api->admin_sys_file_upload();
    networkHelper.setNetworkStatusCallback([this,url](bool isOnline) {
        qDebug() << "Network status changed:" << (isOnline ? "Online" : "Offline");
        if (isOnline){
            http->upload(url,needUploadZipPath);
            networkHelper.stopMonitoring();
        }
    });
}

void FaroManager::zipFileHandle()
{
    qDebug() << "default fls path: " << *defaultFlsPath;
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
    bool result = FileManager::instance()->compression_zip_file(selectFile2DirPath, savePath);
    if (result) {
        qDebug() << "Compression successful!";
    } else {
        qDebug() << "Compression failed!";
    }
    needUploadZipPath = FileManager::getFilesInDirectory(savePath,QStringList() << "*.zip").first();
    qDebug() << "needUploadZipPath: " << needUploadZipPath;
}

void FaroManager::monitorNetworkChanges()
{
    networkHelper.setNetworkStatusCallback([this](bool isOnline) {
        qDebug() << "Network status changed:" << (isOnline ? "Online" : "Offline");
        if (isOnline){
            networkHelper.stopMonitoring();
            emit monitorNetworkChangesComplete(isOnline);
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

void FaroManager::onCalculationSucSignal(const QString &response)
{
    qDebug() << "calculation response: "<< response;
    emit performCalculationSucResult(response);
}

void FaroManager::onCalculationFailSignal(const QString &error, int errorCode)
{
    qDebug() << "error: "<< error << "errorCode: " << errorCode;
    emit performCalculationFailResult(error,errorCode);
}

void FaroManager::performCalculation(const QString &response,const QString &filePath){

    qDebug() << "default fls path : " << filePath;

    faroScannerController->convertFlsToPly("",filePath);
    faroScannerController->disconnect();
    faroScannerController->iQLibIfPtrDisconnect();
    QJsonObject fileModel = Util::parseJsonStringToObject(response);
    QMap<QString, QVariant> paramsMap;
    paramsMap.insert("roomId",inputModel.value("roomId"));
    paramsMap.insert("stationId",inputModel.value("stationId"));
    paramsMap.insert("stageType",inputModel.value("stageType"));
    paramsMap.insert("fileId",fileModel.value("fileId"));
    paramsMap.insert("equipmentModel","Faro-Focus-X");
    paramsMap.insert("scanningMode",/*"1/20"*/inputModel.value("scanningMode"));
    paramsMap.insert("scanningDataFormat","xyzi");
    paramsMap.insert("fileType","fls");
    QMap<QString, QVariant> modeTable;
    modeTable.insert("masonry_mode",inputModel.value("masonry_mode"));
    modeTable.insert("map_mode",inputModel.value("map_mode"));
    paramsMap.insert("modeTable",modeTable);
    QMap<QString, QVariant> inpPcdInfo;
    inpPcdInfo.insert("downsample_voxel_size",Util::getdownsampleVoxelSize(inputModel.value("stageType").toString()));
    inpPcdInfo.insert("is_cropped",1);
    inpPcdInfo.insert("is_downsampled",1);
    QVariantList values;
    values << "0.0" << "0.0" << "0.0";
    inpPcdInfo.insert("scanner_xyz",values);
    int xyCropDist = inputModel.value("xyCropDist").toInt() <= 0 ? 6 : inputModel.value("xyCropDist").toInt();
    int zCropDist = inputModel.value("zCropDist").toInt() <= 0 ? 3 : inputModel.value("zCropDist").toInt();
    inpPcdInfo.insert("xy_crop_dist",xyCropDist);
    inpPcdInfo.insert("z_crop_dist",zCropDist);
    paramsMap.insert("inpPcdInfo",inpPcdInfo);

    qDebug() << "calculate input parasm: " << Util::mapToJson(paramsMap);
    http->post(Api::instance()->building_roomTaskExecute_calculateStationTask(),paramsMap);
}

void FaroManager::convertFlsToPly(const QString &inFlsFilePath, const QString &outPlyFilePath)
{
    faroScannerController->convertFlsToPly(inFlsFilePath,outPlyFilePath);
}

void FaroManager::convertFlsToPly(const QString &inFlsFilePath, const QString &outPlyFilePath, int xyCropDist, int zCropDist)
{
    faroScannerController->convertFlsToPly(inFlsFilePath,outPlyFilePath,xyCropDist,zCropDist);
}
void FaroManager::performCalculation(const QString &response,const QString &filePath,const QString &calParams){

    qDebug() << "default fls path : " << filePath;
    QJsonObject fileModel = Util::parseJsonStringToObject(response);
    QJsonObject myCalParams = Util::parseJsonStringToObject(calParams);
    QMap<QString, QVariant> paramsMap;
    paramsMap.insert("roomId",myCalParams.value("roomId"));
    paramsMap.insert("stationId",myCalParams.value("stationId"));
    paramsMap.insert("stageType",myCalParams.value("stageType"));
    paramsMap.insert("fileId",fileModel.value("fileId"));
    paramsMap.insert("equipmentModel","Faro-Focus-X");
    paramsMap.insert("scanningMode","1/20"/*inputModel.value("scanningMode")*/);
    //    paramsMap.insert("scanningDataFormat","xyzi");
    paramsMap.insert("fileType","ply");
    QMap<QString, QVariant> modeTable;
    modeTable.insert("masonry_mode",myCalParams.value("masonry_mode"));
    modeTable.insert("map_mode",myCalParams.value("map_mode"));
    paramsMap.insert("modeTable",modeTable);
    QMap<QString, QVariant> inpPcdInfo;
    inpPcdInfo.insert("downsample_voxel_size",Util::getdownsampleVoxelSize(myCalParams.value("stageType").toString()));
    inpPcdInfo.insert("is_cropped",1);
    inpPcdInfo.insert("is_downsampled",1);
    QVariantList values;
    values << "0.0" << "0.0" << "0.0";
    inpPcdInfo.insert("scanner_xyz",values);
    int xyCropDist = myCalParams.value("xyCropDist").toInt() <= 0 ? 6 : myCalParams.value("xyCropDist").toInt();
    int zCropDist = myCalParams.value("zCropDist").toInt() <= 0 ? 3 : myCalParams.value("zCropDist").toInt();
    inpPcdInfo.insert("xy_crop_dist",xyCropDist);
    inpPcdInfo.insert("z_crop_dist",zCropDist);
    paramsMap.insert("inpPcdInfo",inpPcdInfo);
    qDebug() << "calculate input parasm: " << Util::mapToJson(paramsMap);
    http->post(Api::instance()->building_roomTaskExecute_calculateStationTask(),paramsMap);
}

void FaroManager::convertFlsToZipPly(const QString &filePath)
{
    QString resultPath = "";
    QString originPath = filePath;
    originPath.replace(0,7,Util::getDriveLetter());

    QString fileName = originPath.mid(originPath.lastIndexOf("/") + 1,originPath.length());
    faroScannerController->convertFlsToPly(originPath,originPath + "/" + fileName +".ply");
    QString plyZipPath = FileManager::instance()-> compression_zip_by_filepath(originPath + "/" + fileName +".ply");
    emit convertFlsToZipPlyResult(plyZipPath);
}

void FaroManager::startConvertFlsToZipPly(const QString &filePath){

    if (!m_running) {
        m_thread = std::thread(&FaroManager::convertFlsToZipPly, this , filePath);
        m_running = true;
    }
    else{
        m_running = false;
        m_thread.join();
        startConvertFlsToZipPly(filePath);
    }
}




