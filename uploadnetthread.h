#ifndef UPLOADNETTHREAD_H
#define UPLOADNETTHREAD_H
#include <QtCore>
#include "httpclient.h"
#include "settingsmanager.h"
#include "http.h"

class UploadNetThread : public QThread
{
    Q_OBJECT
public:
    explicit UploadNetThread(const QString &url, const QString &filePath, QObject *parent = nullptr)
        : QThread(parent), url(url), path(filePath){};

    void run() ;

    signals:
        void qtreplySucSignal(const QString &response);
        void qtreplyFailSignal(const QString &error, int errorCode);

    private:
        QString url;
        QString path;
        QString BASE_URL = "http://192.168.2.222:9002";
};

#endif // UPLOADNETTHREAD_H
