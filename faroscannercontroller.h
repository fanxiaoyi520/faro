#ifndef FAROSCANNERCONTROLLER_H
#define FAROSCANNERCONTROLLER_H

#include <QObject>
#include <QDebug>
#include <atlcomcli.h>
#include <comutil.h>
#include <cstdlib>
#include "filemanager.h"
#include "networkhelper.h"
#include <QTimer>
#include <QStorageInfo>
#include <QMutex>
#include <QPointer>
#include "syncplyapi.h"
#include <cmath>
#include <QThread>
#include <QtConcurrent>
#include <QFuture>

#include <QtConcurrent>
#include <functional>

#ifdef _WIN64
// Yes - type is 'win32' even on WIN64!
#pragma comment(linker, "\"/manifestdependency:type='win32' name='FARO.LS' version='1.1.0.0' processorArchitecture='amd64' publicKeyToken='1d23f5635ba800ab'\"")
#else
#pragma comment(linker, "\"/manifestdependency:type='win32' name='FARO.LS' version='1.1.0.0' processorArchitecture='x86' publicKeyToken='1d23f5635ba800ab'\"")
#endif
//#import "C:\Windows\WinSxS\amd64_faro.ls_1d23f5635ba800ab_1.1.702.0_none_3590af4b356bcd81\iQOpen.dll" no_namespace
//#import "C:\Windows\WinSxS\amd64_faro.ls_1d23f5635ba800ab_1.1.702.0_none_3590af4b356bcd81\FARO.LS.SDK.dll" no_namespace
#import "thirdparty/iQOpen.dll" no_namespace
#import "thirdparty/FARO.LS.SDK.dll" no_namespace
//#ifdef _DEBUG
//#define new DEBUG_NEW
//#undef THIS_FILE
//static char THIS_FILE[] = __FILE__;
//#endif

class FaroScannerController : public QObject
{
    Q_OBJECT

public:
    static FaroScannerController* instance();

    std::function<void (int)> scanProgressHandler = nullptr;
    std::function<void (const QString &)>                 completeHandler = nullptr;
    std::function<void (int)>                 scanAbnormalHandler = nullptr;

    FaroScannerController& scanProgress(std::function<void (int)> scanProgressHandler);
    FaroScannerController& complete(std::function<void (const QString &)> completeHandler);
    FaroScannerController& scanAbnormal(std::function<void (int)> scanAbnormalHandler);
    // 初始化FARO SDK
    Q_INVOKABLE bool init();

    // 连接到扫描仪
    Q_INVOKABLE bool connect();
    Q_INVOKABLE bool connect(const QString &scannerIP, const QString &remoteScanStoragePath);
    Q_INVOKABLE FaroScannerController& startScan(const QString &inputParams);
    Q_INVOKABLE FaroScannerController& startScan(const QString &inputParams,const QString &m_Resolution, const QString &m_ScanName);
    Q_INVOKABLE void stopScan();
    Q_INVOKABLE void disconnect();
    Q_INVOKABLE void iQLibIfPtrDisconnect();
    Q_INVOKABLE void shutDown();
    // 转换fls文件为ply文件~含下采样
    Q_INVOKABLE void convertFlsToPly(const QString& inFlsFilePath,const QString& outPlyFilePath);
    Q_INVOKABLE void convertFlsToPly(const QString& inFlsFilePath,const QString& outPlyFilePath,int xyCropDist,int zCropDist);
    Q_INVOKABLE QString getScanPathName();
    Q_INVOKABLE void pollingScannerStatus();
    void asyncTaskHandle(QTimer *timer);
signals:
    void timerResultReady(QTimer *timer);
private slots:
    void checkScannerStatus(QTimer *timer);
    void handleResults(QTimer *timer);
private:
//    explicit FaroScannerController(QObject *parent = nullptr);
//    ~FaroScannerController();
    FaroScannerController(QObject *parent = nullptr);
    ~FaroScannerController();
    FaroScannerController(const FaroScannerController&) = delete;
    FaroScannerController& operator=(const FaroScannerController&) = delete;
    static QPointer<FaroScannerController> instancePtr;
    static QMutex mutex;

    IScanCtrlSDKPtr scanCtrlSDKPtr;
    IiQScanOpInterfPtr scanOpInterfPtr;
    IiQLibIfPtr iQLibIfPtr;
    // 初始化FARO SDK的内部实现
    bool initFaroInternal();
    bool initIiQLibInternal();
    // 连接到扫描仪的内部实现
    bool connectToScannerInternal(const _bstr_t &scannerIP, const CComBSTR &remoteScanStoragePath);

//    void pollingScannerStatus();
    void getScanProgress();
    int scanStatus;
//    QTimer *timer;
    QString flsPath;
    SyncPlyApi syncPlyApi;
};

#endif // FAROSCANNERCONTROLLER_H


