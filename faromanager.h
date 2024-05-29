#ifndef FAROMANAGER_H
#define FAROMANAGER_H

#include <QObject>
//#include "faroscannercontroller.h"
#include "util.h"
#include "http.h"
#include "api.h"
#include "filemanager.h"

class FaroManager : public QObject
{
    Q_OBJECT
public:
    explicit FaroManager(QObject *parent = nullptr);
    Q_INVOKABLE bool init();
    Q_INVOKABLE void startScan(const QString &inputParams);
public slots:
    void onReplySucSignal(const QString &response);
    void onReplyFailSignal(const QString &error, int errorCode);
signals:

private:
    //FaroScannerController faroScannerController;
    Http *http;
    FileManager *fileManager;
};

#endif // FAROMANAGER_H
