// FaroScannerController.cpp
#include "faroscannercontroller.h"
#include <QMutex>

QPointer<FaroScannerController> FaroScannerController::instancePtr = nullptr;
QMutex FaroScannerController::mutex;

FaroScannerController* FaroScannerController::instance() {
    QMutexLocker locker(&mutex);
    if (!instancePtr) {
        instancePtr = new FaroScannerController();
        QObject::connect(instancePtr, &FaroScannerController::timerResultReady, instancePtr, &FaroScannerController::handleResults);
    }
    return instancePtr;
}

FaroScannerController &FaroScannerController::scanProgress(std::function<void (int)> scanProgressHandler)
{
    instancePtr->scanProgressHandler = scanProgressHandler;
    return *instancePtr;
}

FaroScannerController &FaroScannerController::complete(std::function<void (const QString &)> completeHandler)
{
    instancePtr->completeHandler = completeHandler;
    return *instancePtr;
}

FaroScannerController &FaroScannerController::scanAbnormal(std::function<void (int)> scanAbnormalHandler)
{
    instancePtr->scanAbnormalHandler = scanAbnormalHandler;
    return *instancePtr;
}

FaroScannerController::FaroScannerController(QObject *parent) : QObject(parent)
{
    scanCtrlSDKPtr = nullptr;
    scanOpInterfPtr = nullptr;
    iQLibIfPtr = nullptr;
    timer = new QTimer();
}

FaroScannerController::~FaroScannerController()
{
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
    return connect(default_ip,""/*defaultRemoteScanStoragePath*/);
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
    qDebug() << "enter connect to scanner internal";
    Q_UNUSED(remoteScanStoragePath);
    if (!scanCtrlSDKPtr) {
        qDebug() << "init faro internal";
        initFaroInternal();
    }

    scanCtrlSDKPtr->ScannerIP = scannerIP;
    scanCtrlSDKPtr->clearExceptions();
    scanCtrlSDKPtr->PutScanMode(StationaryGrey);

    qDebug() << "start connect";
    scanCtrlSDKPtr->connect();
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
    return *instancePtr;
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
    }
    return *instancePtr;
}

void FaroScannerController::stopScan()
{
    if (scanCtrlSDKPtr) {
        scanCtrlSDKPtr->stopScan();
        qDebug() << "stop scanCtrlSDKPtr stopScan completed";
    }
}

void FaroScannerController::disconnect() {
    qDebug() << "input disconnect";
    if (scanCtrlSDKPtr) {
        qDebug() << "input disconnect completed";
        stopScan();
        scanCtrlSDKPtr = nullptr;
        scanOpInterfPtr = nullptr;
        qDebug() << "destruction scanCtrlSDKPtr and scanOpInterfPtr completed";
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
        scanCtrlSDKPtr->shutDown();
    }
}

void FaroScannerController::convertFlsToPly(const QString& inFlsFilePath,const QString& outPlyFilePath)
{
    convertFlsToPly(inFlsFilePath,outPlyFilePath,6,3);
}

void FaroScannerController::convertFlsToPly(const QString &inFlsFilePath,
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
    if(scans == 0 || result != 0){
         qDebug() << "error convert";
        iQLibIfPtrDisconnect();
        return;
    }
    int row = iQLibIfPtr->getScanNumRows(0);
    int col = iQLibIfPtr->getScanNumCols(0);
    qDebug() << "row: " << row;
    qDebug() << "col: " << col;

    QString m_ScanNo = "0";
    int scanNo = m_ScanNo.toInt();
    double Rx, Ry, Rz, angle;
    iQLibIfPtr->getScanOrientation(scanNo, &Rx, &Ry, &Rz, &angle);
    qDebug() << Rx << "  " << Ry << "  " << Rz << "  " << angle;

    double cosAngle = cos(angle);
    double sinAngle = sin(angle);

    QVector<CartesianPoint> allPoints(row * col);

    auto processRow = [&](int i) {
        QVector<CartesianPoint> rowPoints(col);
        for (int j = 0; j < col; ++j) {
            double x, y, z;
            int refl;
            iQLibIfPtr->getScanPoint(scanNo, i, j, &x, &y, &z, &refl);

            CartesianPoint cartesian;
            cartesian.x = (Rx * Rx * (1 - cosAngle) + cosAngle) * x
                    + (Ry * Rx * (1 - cosAngle) - Rz * sinAngle) * y
                    + (Rz * Rx * (1 - cosAngle) + Ry * sinAngle) * z;

            cartesian.y = (Rx * Ry * (1 - cosAngle) + Rz * sinAngle) * x
                    + (Ry * Ry * (1 - cosAngle) + cosAngle) * y
                    + (Rz * Ry * (1 - cosAngle) - Rx * sinAngle) * z;

            cartesian.z = (Rx * Rz * (1 - cosAngle) - Ry * sinAngle) * x
                    + (Ry * Rz * (1 - cosAngle) + Rx * sinAngle) * y
                    + (Rz * Rz * (1 - cosAngle) + cosAngle) * z;

            cartesian.intensity = refl / 255.0;
            rowPoints[j] = cartesian;
        }
        return rowPoints;
    };

    QVector<QFuture<QVector<CartesianPoint>>> futures;
    for (int i = 0; i < row; ++i) {
        futures.append(QtConcurrent::run(processRow, i));
    }

    int index = 0;
    for (auto &future : futures) {
        future.waitForFinished();
        for (auto &point : future.result()) {
            allPoints[index++] = point;
        }
    }

    syncPlyApi.myXYZData = allPoints.toStdVector();
    syncPlyApi.downSamplePoint(xyCropDist, zCropDist);
    std::ofstream outfile(outPlyFilePath.toStdString());
    syncPlyApi.SavePly(outfile, syncPlyApi.myXYZData);
    syncPlyApi.myXYZData.clear();
    iQLibIfPtrDisconnect();
}

void FaroScannerController::checkScannerStatus(/*QTimer *timer*/)
{
    QFuture<void> future = QtConcurrent::run([&]() {
        asyncTaskHandle();
    });
}

void FaroScannerController::handleResults(/*QTimer *timer*/)
{
    qDebug() << "enter timer handle";
    if (timer) {
        qDebug() << "start stop timer";
        timer->stop();
        qDebug() << "stoped timer";
        delete timer;
        timer = nullptr;
    }
}

void FaroScannerController::asyncTaskHandle(/*QTimer *timer*/){

    qDebug() << "is connected: " << scanOpInterfPtr->isConnected();
    scanOpInterfPtr->getScannerStatus(&scanStatus);
    qDebug() << "Scanner status: " << scanStatus;

    if (scanStatus == 0) {
        QString path = getScanPathName();
        qDebug() << "scan complete path: " << path;
        disconnect();
        if (path.isEmpty()) {
            qDebug() << "scan complete path isEmpty";
            emit timerResultReady(/*timer*/);
            instancePtr->scanAbnormalHandler(scanStatus);
        } else {
            qDebug() << "scan complete path no isEmpty";
            emit timerResultReady(/*timer*/);
            instancePtr->completeHandler(path/*flsPath*/);
        }
    } else if (scanStatus == 1) {
        disconnect();
        emit timerResultReady(/*timer*/);
        instancePtr->scanAbnormalHandler(scanStatus);
    } else {
        getScanProgress();
    }
}

void FaroScannerController::pollingScannerStatus(){

    scanStatus = -1;
    if(!timer) timer = new QTimer();
    QObject::connect(timer, &QTimer::timeout, [](){
        instance()->checkScannerStatus();
    });
    timer->start(1000);
}

void FaroScannerController::getScanProgress()
{
    int percent = 1;
    scanOpInterfPtr->getScanProgress(&percent);
    if (percent > 0) {
        instancePtr->scanProgressHandler(percent);
    }
}
