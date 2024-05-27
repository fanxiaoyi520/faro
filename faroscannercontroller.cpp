// FaroScannerController.cpp
#include "FaroScannerController.h"

FaroScannerController::FaroScannerController(QObject *parent) : QObject(parent)
{
    scanCtrlSDKPtr = nullptr;
}

FaroScannerController::~FaroScannerController()
{
    // 在析构函数中可能还需要做一些清理工作，比如断开连接等
    // 但是这取决于IScanCtrlSDKPtr的实际接口和生命周期管理
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

bool FaroScannerController::connect() {
    const QString default_ip = "192.168.43.1";
    const QString defaultRemoteScanStoragePath = "D:\\fls";
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
    if (!scanCtrlSDKPtr) initFaroInternal();

    qDebug() << "scanner IP: " << scannerIP;
    scanCtrlSDKPtr->ScannerIP = scannerIP;
    scanCtrlSDKPtr->connect();
    HRESULT hr = scanCtrlSDKPtr->put_RemoteScanStoragePath(remoteScanStoragePath);
    if (SUCCEEDED(hr)) {
        // Path set successfully
        scanCtrlSDKPtr->RemoteScanAccess = RSAEnabled;
        scanCtrlSDKPtr->PutStorageMode(SMRemote);
        return true;
    } else {
        // Handle error
        qDebug() << "Failed to set remote scan storage path";
        return false;
    }
}

void FaroScannerController::startScan() {
    const QString m_Resolution = "8";
    const QString m_ScanName = "SDK_File_";
    startScan(m_Resolution,m_ScanName);
}

void FaroScannerController::startScan(const QString &m_Resolution, const QString &m_ScanName)
{
    qDebug() << "----------: " << m_Resolution << "------------------" << m_ScanName;
    if (scanCtrlSDKPtr) {
        scanCtrlSDKPtr->Resolution = m_Resolution.toInt();
        _bstr_t _bstr_t_m_ScanName = m_ScanName.toStdWString().c_str();
        scanCtrlSDKPtr->ScanBaseName = _bstr_t_m_ScanName;
        scanCtrlSDKPtr->syncParam();
        scanCtrlSDKPtr->startScan();
    }
}

void FaroScannerController::stopScan()
{
    if (scanCtrlSDKPtr) {
        scanCtrlSDKPtr->stopScan();
    }
}

void FaroScannerController::disconnect() {
    if (scanCtrlSDKPtr) {
        scanCtrlSDKPtr = nullptr;
    }
}

void FaroScannerController::shutDown()
{
    if (scanCtrlSDKPtr) {
        scanCtrlSDKPtr->shutDown();
    }
}

