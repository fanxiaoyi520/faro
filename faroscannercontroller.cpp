// FaroScannerController.cpp
#include "faroscannercontroller.h"
#include <QMutex>

QPointer<FaroScannerController> FaroScannerController::instancePtr = nullptr;
QMutex FaroScannerController::mutex;

FaroScannerController* FaroScannerController::instance() {
    QMutexLocker locker(&mutex);
    if (!instancePtr) {
        instancePtr = new FaroScannerController();
    }
    return instancePtr;
}

FaroScannerController &FaroScannerController::scanProgress(std::function<void (int)> scanProgressHandler)
{
    this->scanProgressHandler = scanProgressHandler;
    return *this;
}

FaroScannerController &FaroScannerController::complete(std::function<void (const QString &)> completeHandler)
{
    this->completeHandler = completeHandler;
    return *this;
}

FaroScannerController &FaroScannerController::scanAbnormal(std::function<void (int)> scanAbnormalHandler)
{
    this->scanAbnormalHandler = scanAbnormalHandler;
    return *this;
}

FaroScannerController::FaroScannerController(QObject *parent) : QObject(parent)
{
    scanCtrlSDKPtr = nullptr;
    scanOpInterfPtr = nullptr;
    iQLibIfPtr = nullptr;
}

FaroScannerController::~FaroScannerController()
{
    if (timer) {
        timer->stop();
        delete timer;
        timer = nullptr;
    }
    stopScan();
    disconnect();
}

bool FaroScannerController::init()
{
    // 调用内部实现
    return initFaroInternal();
}

bool FaroScannerController::initFaroInternal()
{
    try {
        const wchar_t* licenseText =
                L"FARO Open Runtime License\n"
                L"Key: 434ELNNRTCTXXMKT8KVUSPUPS\n"
                L"\n"
                L"The software is the registered property of "
                L"FARO Scanner Production GmbH, Stuttgart, Germany.\n"
                L"All rights reserved.\n"
                L"This software may only be used with written permission "
                L"of FARO Scanner Production GmbH, Stuttgart, Germany.";
        BSTR licenseCode = SysAllocString(licenseText);
        IiQLicensedInterfaceIfPtr licPtr(__uuidof(ScanCtrlSDK));
        try {
            licPtr->License = licenseCode;
            scanCtrlSDKPtr = static_cast<IScanCtrlSDKPtr>(licPtr);
            scanOpInterfPtr = static_cast<IiQScanOpInterfPtr>(scanCtrlSDKPtr);
        }
        catch (...) {
            qDebug() << "No license for FARO.LS.SDK interface provided";
            return false;
        }
    }
    catch (...) {
        qDebug() << "Cannot access FARO.LS.SDK";
        return false;
    }

    if (scanCtrlSDKPtr == NULL) {
        qDebug() << "Failed to initialize FARO SDK";
        return false;
    }

    return true;
}

bool FaroScannerController::initIiQLibInternal()
{
    try {
        const wchar_t* licenseText1 =
                L"FARO Open Runtime License\n"
                L"Key: 434ELNNRTCTXXMKT8KVUSPUPS\n"
                L"\n"
                L"The software is the registered property of "
                L"FARO Scanner Production GmbH, Stuttgart, Germany.\n"
                L"All rights reserved.\n"
                L"This software may only be used with written permission "
                L"of FARO Scanner Production GmbH, Stuttgart, Germany.";
        BSTR licenseCode1 = SysAllocString(licenseText1);
        IiQLicensedInterfaceIfPtr licPtr1(__uuidof(iQLibIf));
        try {
            licPtr1->License = licenseCode1;
            iQLibIfPtr = static_cast<IiQLibIfPtr>(licPtr1);
        }
        catch (...) {
            qDebug() << "No license for iQOpen interface provided";
            return false;
        }
    }
    catch (...) {
        qDebug() << "Cannot access iQOpen";
        return false;
    }

    if (iQLibIfPtr == NULL) {
        qDebug() << "Failed to initialize iQOpen";
        return false;
    }

    return true;
}

bool FaroScannerController::connect() {
    const QString default_ip = "192.168.43.1";
    const QString defaultRemoteScanStoragePath = FileManager::getFlsPath();
    flsPath = defaultRemoteScanStoragePath;
    return connect(default_ip,defaultRemoteScanStoragePath);
}

bool FaroScannerController::connect(const QString &scannerIP, const QString &remoteScanStoragePath)
{
    // 转换QString到_bstr_t和CComBSTR
    _bstr_t scannerIPBstr = scannerIP.toStdWString().c_str();
    CComBSTR bstrPath(reinterpret_cast<const wchar_t*>(remoteScanStoragePath.utf16()));
    return connectToScannerInternal(scannerIPBstr, bstrPath);
}

bool FaroScannerController::connectToScannerInternal(const _bstr_t &scannerIP, const CComBSTR &remoteScanStoragePath)
{
    Q_UNUSED(remoteScanStoragePath);
    if (!scanCtrlSDKPtr) {
        initFaroInternal();
    }

    scanCtrlSDKPtr->ScannerIP = scannerIP;
    scanCtrlSDKPtr->clearExceptions();
    scanCtrlSDKPtr->PutScanMode(StationaryGrey);
    scanCtrlSDKPtr->connect();
    /**
    HRESULT hr = scanCtrlSDKPtr->put_RemoteScanStoragePath(remoteScanStoragePath);
    if (SUCCEEDED(hr)) {
        // Path set successfully
        scanCtrlSDKPtr->RemoteScanAccess = RSAEnabled;
        scanCtrlSDKPtr->PutStorageMode(SMRemote);
        scanCtrlSDKPtr->PutScanMode(StationaryGrey);
        //        scanCtrlSDKPtr->PutResolution(1);
        //        int aa = scanCtrlSDKPtr->GetResolution();
        //        qDebug() << "Get Resolution: " << aa;

        //scanCtrlSDKPtr->PutMeasurementRate(1);
        return true;
    } else {
        // Handle error
        qDebug() << "Failed to set remote scan storage path";
        return false;
    }
    */
    return true;
}

FaroScannerController& FaroScannerController::startScan(const QString &inputParams) {
    qDebug() << "start scan input params: " << inputParams;
    QJsonObject inputMap = Util::parseJsonStringToObject(inputParams);
    /**保存规则*/
    QString name = "Faro_"+inputMap.value("roomId").toString()+"_"+inputMap.value("stationId").toString()+"_"+inputMap.value("taskNo").toString()+"_";
    qDebug() << "name: " << name;
    const QString m_Resolution = "20";
    const QString m_ScanName = name;
    startScan(inputParams,m_Resolution,m_ScanName);
    return *this;
}

QString FaroScannerController::getScanPathName() {
    int result;
    BSTR path = nullptr;
    result = scanOpInterfPtr->getScanPathName(&path);

    QString qstringPath;
    if (result == 0) {
        if (path) {
            qstringPath = QString::fromWCharArray(path);
        }

        SysFreeString(path);
    } else {
        qDebug() << "err";
    }

    return qstringPath;
}

FaroScannerController& FaroScannerController::startScan(const QString &inputParams,const QString &m_Resolution, const QString &m_ScanName)
{
    Q_UNUSED(inputParams);
    if (scanCtrlSDKPtr) {
        scanCtrlSDKPtr->Resolution = m_Resolution.toInt();
        _bstr_t _bstr_t_m_ScanName = m_ScanName.toStdWString().c_str();
        scanCtrlSDKPtr->ScanBaseName = _bstr_t_m_ScanName;
        scanCtrlSDKPtr->syncParam();
        scanCtrlSDKPtr->startScan();
        pollingScannerStatus();
    }
    return *this;
}

void FaroScannerController::stopScan()
{
    if (scanCtrlSDKPtr) {
        if (timer) timer->stop();
        scanCtrlSDKPtr->stopScan();
    }
}

void FaroScannerController::disconnect() {
    if (scanCtrlSDKPtr) {
        if (timer) {
            timer->stop();
            delete timer;
            timer = nullptr;
        }
        stopScan();
        scanCtrlSDKPtr = nullptr;
        scanOpInterfPtr = nullptr;
    }
}

void FaroScannerController::iQLibIfPtrDisconnect()
{
    if (iQLibIfPtr) {
        iQLibIfPtr = nullptr;
    }
}

void FaroScannerController::shutDown()
{
    if (scanCtrlSDKPtr) {
        if (timer) {
            timer->stop();
            delete timer;
            timer = nullptr;
        }
        scanCtrlSDKPtr->shutDown();
    }
}

void FaroScannerController::convertFlsToPly(const QString& inFlsFilePath,const QString& outPlyFilePath)
{
    convertFlsToPly(inFlsFilePath,outPlyFilePath,6,3);
}

void FaroScannerController::FaroScannerController::convertFlsToPly(const QString &inFlsFilePath,
                                                                   const QString &outPlyFilePath,
                                                                   int xyCropDist,
                                                                   int zCropDist)
{

    initIiQLibInternal();
    HRESULT result;
    std::string stdStr = inFlsFilePath.toStdString();
    const char* cStr = stdStr.c_str();
    _bstr_t bstr(cStr);
    result = iQLibIfPtr->load(cStr);
    qDebug() << "result: " << result;

    int scans = iQLibIfPtr->getNumScans();
    qDebug() << "scans: " << scans;
    int row = iQLibIfPtr->getScanNumRows(0);
    int col = iQLibIfPtr->getScanNumCols(0);
    qDebug() << "row: " << row;
    qDebug() << "col: " << col;

    QString m_ScanNo = "0";
    int scanNo = m_ScanNo.toInt();
    double Rx,Ry,Rz,angle;
    iQLibIfPtr->getScanOrientation(scanNo,&Rx,&Ry,&Rz,&angle);
    qDebug() << Rx << "  " << Ry << "  " << Rz << "  " << angle;
    double x,y,z;
    int refl;
    for (int i = 0; i < row; ++i) {
        for (int j = 0; j < col; ++j) {
            CartesianPoint cartesian{};
            iQLibIfPtr->getScanPoint(0,i,j,&x,&y,&z,&refl);
            cartesian.x = (Rx*Rx*(1-cos(angle))+cos(angle))*x
                    + (Ry*Rx*(1-cos(angle))-Rz*sin(angle))*y
                    + (Rz*Rx*(1-cos(-angle))+Ry*sin(angle))*z;

            cartesian.y = (Rx*Ry*(1-cos(angle))+Rz*sin(angle))*x
                    + (Ry*Ry*(1-cos(angle))+cos(angle))*y
                    + (Rz*Ry*(1-cos(-angle))-Rx*sin(angle))*z;

            cartesian.z = (Rx*Rz*(1-cos(angle))-Ry*sin(angle))*x
                    + (Ry*Rz*(1-cos(angle))+Rx*sin(angle))*y
                    + (Rz*Rz*(1-cos(-angle))+cos(angle))*z;
            cartesian.intensity = refl/255.0;
            syncPlyApi.myXYZData.push_back(cartesian);
        }
    }

    syncPlyApi.downSamplePoint(xyCropDist,zCropDist);
    std::ofstream outfile(outPlyFilePath.toStdString());
    syncPlyApi.SavePly(outfile,syncPlyApi.myXYZData);
    syncPlyApi.myXYZData.clear();
    iQLibIfPtrDisconnect();
}

void FaroScannerController::checkScannerStatus()
{
    qDebug() << "is connected: " << scanOpInterfPtr->isConnected();
    scanOpInterfPtr->getScannerStatus(&scanStatus);
    qDebug() << "Scanner status: " << scanStatus;

    if (scanStatus == 0) {
        //QTimer *timer = qobject_cast<QTimer*>(sender());
        if (timer) timer->stop();
        timer->deleteLater();
        QString path = getScanPathName();
        /**
        int index = path.indexOf("/Scans");
        if (index != -1) {
            path.replace(index, QString("/Scans").length(), "G:");
        }
        qDebug() << "get scan path name: " << path;
        */
        qDebug() << "scan complete path: " << path;
        if (path.isEmpty()) {
            this->scanAbnormalHandler(scanStatus);
        } else {
            this->completeHandler(path/*flsPath*/);
        }
    } else if (scanStatus == 1) {
        this->scanAbnormalHandler(scanStatus);
    } else {
        getScanProgress();
    }
}

void FaroScannerController::pollingScannerStatus(){

    scanStatus = -1;
    timer = new QTimer();
    QObject::connect(timer, &QTimer::timeout, this, &FaroScannerController::checkScannerStatus);
    timer->start(1000);
}

void FaroScannerController::getScanProgress()
{
    int percent = 1;
    scanOpInterfPtr->getScanProgress(&percent);
    if (percent > 0) {
        this->scanProgressHandler(percent);
    }
}
