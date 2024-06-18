#include "uploadnetthread.h"


void UploadNetThread::run()
{
    QJsonObject user = Util::parseJsonStringToObject(SettingsManager::instance()->getValue(SettingsManager::instance()->user()));
    QMap<QString, QString>headersMap;
    if(!user.isEmpty()) {
        qDebug()<<"selected tenant id: "+user.value("tenant_id").toString();
        headersMap.insert("Tenant-id",user.value("tenant_id").toString());
        headersMap.insert("lang","zh_CN");
        headersMap.insert("Authorization","Bearer " + user.value("access_token").toString());
    } else {
        qDebug() << "user info is empty";
    }
    qDebug() << "headers: "<< headersMap;
    qDebug() << "url" << url;
    qDebug() << "path" << path;
    HttpClient(BASE_URL+url)
            .debug(true)
            .headers(headersMap)
            .success([this](const QString &response) {
         qDebug() << "response" << response;
        emit qtreplySucSignal(response);
    }).fail([this](const QString &error, int errorCode) {
        qDebug() << "error" << error;
        emit qtreplyFailSignal(error,errorCode);
    }).upload(path);
}
