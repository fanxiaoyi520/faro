#include "http.h"
#include "util.h"

Http::Http(QObject *parent) : QObject(parent)
{
    manager = new QNetworkAccessManager(this);
    QObject::connect(manager,SIGNAL(finished(const QString &)),this,SLOT(replyFinished(const QString &)));
    QObject::connect(manager,SIGNAL(finished(const QString &, int)),this,SLOT(replyFail(const QString &, int)));
}

void Http::replyFinished(const QString &response)
{
    emit replySucSignal(response);
}

void Http::replyFail(const QString &error, int errorCode)
{
    emit replyFailSignal(error,errorCode);
}

/*"http://192.168.2.222:9002/admin/tenant/queryTenantByUserName"*/
void Http::get(QString url)
{
    QMap<QString, QVariant> defaultParams;
    this->get(url, defaultParams);
}

void Http::get(QString url, const QMap<QString, QVariant> &ps)
{
    qDebug() << url;
    QMap<QString, QVariant> paramsMap;
    for(int i = 0; i < ps.keys().size(); i++) {
        paramsMap.insert(ps.keys().at(i),ps.values().at(i));
    }

    QJsonObject user = Util::parseJsonStringToObject(SettingsManager::instance()->getValue(SettingsManager::instance()->user()));
    QMap<QString, QString>headersMap;
    if(!user.isEmpty()) {
        qDebug()<<"selected tenant id: "+user.value("tenant_id").toString();
        headersMap.insert("Tenant_id",user.value("tenant_id").toString());
        headersMap.insert("lang","zh_CN");
        headersMap.insert("Authorization","Bearer " + user.value("access_token").toString());
    } else {
        qDebug() << "user info is empty";
    }

    HttpClient(BASE_URL+url)
            .debug(true)
            .params(paramsMap)
            .headers(headersMap)
            .success([this](const QString &response) {
        replyFinished(response);
    }).fail([this](const QString &error, int errorCode) {
        replyFail(error,errorCode);
    }).get();
}


void Http::post(QString url)
{
    QMap<QString, QVariant> defaultParams;
    this->post(url, defaultParams);
}

void Http::post(QString url, const QMap<QString, QVariant> &ps)
{
    QMap<QString, QVariant> paramsMap;
    for(int i = 0; i < ps.keys().size(); i++) {
        paramsMap.insert(ps.keys().at(i),ps.values().at(i));
    }
    QJsonObject user = Util::parseJsonStringToObject(SettingsManager::instance()->getValue(SettingsManager::instance()->user()));
    QMap<QString, QString>headersMap;
    if(!user.isEmpty()) {
        qDebug()<<"selected tenant id: "+user.value("tenant_id").toString();
        headersMap.insert("Tenant_id",user.value("tenant_id").toString());
        headersMap.insert("lang","zh_CN");
        headersMap.insert("Authorization","Bearer " + user.value("access_token").toString());
    } else {
        qDebug() << "user info is empty";
    }
    qDebug() << "headers: "<< headersMap;
    qDebug() << "params: " << paramsMap;
    qDebug() << "json: " << Util::mapToJson(paramsMap);
    QString jsonParams = Util::mapToJson(paramsMap);
    if (paramsMap.contains("integers")) {
        QJsonArray jsonArray;
        for (const QVariant  &id : paramsMap.value("integers").toList()) {
            QString stringItem = id.toString();
            jsonArray.append(stringItem);
        }
        QJsonDocument jsonDoc(jsonArray);
        jsonParams = jsonDoc.toJson(QJsonDocument::Indented);
        qDebug() << "jsonParams: " << jsonParams;
    }
    HttpClient(BASE_URL+url)
            .debug(true)
            //.params(paramsMap)
            .json(jsonParams)
            .headers(headersMap)
            .success([this](const QString &response) {
        replyFinished(response);
    }).fail([this](const QString &error, int errorCode) {
        replyFail(error,errorCode);
    }).post();
}

void Http::loginPost(QString url,
                     const QMap<QString, QVariant> &ps,
                     const QMap<QString, QVariant> &headers)
{
    QMap<QString, QVariant> paramsMap;
    for(int i = 0; i < ps.keys().size(); i++) {
        paramsMap.insert(ps.keys().at(i),ps.values().at(i));
    }
    paramsMap.insert("grant_type","password");
    paramsMap.insert("scope","server");

    QMap<QString, QString> headersMap;
    for(int i = 0; i < headers.keys().size(); i++) {
        headersMap.insert(headers.keys().at(i),headers.values().at(i).toString());
        qDebug() << "headers: "<< headers.keys().at(i) << "====" << headers.values().at(i).toString();
    }

    QString clientId = "mini";
    QString clientSecret = "mini";
    QString authString = clientId.append(":").append(clientSecret);
    QString base64AuthString = authString.toUtf8().toBase64();
    QString authorization = "Basic ";
    authorization.append(base64AuthString);
    headersMap.insert("Authorization",authorization);
    qDebug() << "login headers: "<< headersMap;
    qDebug() << "login params: " << paramsMap;
    HttpClient(BASE_URL+url)
            .debug(true)
            .params(paramsMap)
            .headers(headersMap)
            .success([this](const QString &response) {
        QSettings settings("YYZS","Measure");
        settings.setValue("user",response);
        replyFinished(response);
    }).fail([this](const QString &error, int errorCode) {
        replyFail(error,errorCode);
    }).post();
}
