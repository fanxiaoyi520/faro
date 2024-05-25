﻿#ifndef FAROSCANNERCONTROLLER_H
#define FAROSCANNERCONTROLLER_H

#include <QObject>
#include <QDebug>
#include <atlcomcli.h>
#include <comutil.h>
#include <cstdlib>

#ifdef _WIN64
// Yes - type is 'win32' even on WIN64!
#pragma comment(linker, "\"/manifestdependency:type='win32' name='FARO.LS' version='1.1.0.0' processorArchitecture='amd64' publicKeyToken='1d23f5635ba800ab'\"")
#else
#pragma comment(linker, "\"/manifestdependency:type='win32' name='FARO.LS' version='1.1.0.0' processorArchitecture='x86' publicKeyToken='1d23f5635ba800ab'\"")
#endif
#import "C:\Windows\WinSxS\amd64_faro.ls_1d23f5635ba800ab_1.1.702.0_none_3590af4b356bcd81\iQOpen.dll" no_namespace
#import "C:\Windows\WinSxS\amd64_faro.ls_1d23f5635ba800ab_1.1.702.0_none_3590af4b356bcd81\FARO.LS.SDK.dll" no_namespace

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

class FaroScannerController : public QObject
{
    Q_OBJECT

public:
    explicit FaroScannerController(QObject *parent = nullptr);
    ~FaroScannerController();

    // 初始化FARO SDK
    Q_INVOKABLE bool init();

    // 连接到扫描仪
    Q_INVOKABLE bool connect();
    Q_INVOKABLE bool connect(const QString &scannerIP, const QString &remoteScanStoragePath);
    Q_INVOKABLE void startScan();
    Q_INVOKABLE void startScan(const QString &m_Resolution, const QString &m_ScanName);
    Q_INVOKABLE void stopScan();
    Q_INVOKABLE void disconnect();
    Q_INVOKABLE void shutDown();

private:
    IScanCtrlSDKPtr scanCtrlSDKPtr;

    // 初始化FARO SDK的内部实现
    bool initFaroInternal();

    // 连接到扫描仪的内部实现
    bool connectToScannerInternal(const _bstr_t &scannerIP, const CComBSTR &remoteScanStoragePath);
};

#endif // FAROSCANNERCONTROLLER_H
