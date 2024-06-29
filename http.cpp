#include "http.h"
#include "util.h"

Http::Http(QObject *parent) : QObject(parent)
{
    manager = new QNetworkAccessManager(this);
    //QObject::connect(manager,SIGNAL(finished(const QString &)),this,SLOT(replyFinished(const QString &)));
    //QObject::connect(manager,SIGNAL(finished(const QString &, int)),this,SLOT(replyFail(const QString &, int)));
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
        headersMap.insert("Tenant-id",user.value("tenant_id").toString());
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
        headersMap.insert("Tenant-id",user.value("tenant_id").toString());
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

void Http::postForm(QString url)
{
    //    QMap<QString, QVariant> paramsMap;
    //    for(int i = 0; i < ps.keys().size(); i++) {
    //        paramsMap.insert(ps.keys().at(i),ps.values().at(i));
    //    }
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
    //    qDebug() << "params: " << paramsMap;
    //    qDebug() << "json: " << Util::mapToJson(paramsMap);
    HttpClient(BASE_URL+url)
            .debug(true)
            //            .params(paramsMap)
            .headers(headersMap)
            .success([this](const QString &response) {
        replyFinished(response);
    }).fail([this](const QString &error, int errorCode) {
        replyFail(error,errorCode);
    }).post();
}



void Http::put(QString url, const QMap<QString, QVariant> &ps)
{
    QMap<QString, QVariant> paramsMap;
    for(int i = 0; i < ps.keys().size(); i++) {
        paramsMap.insert(ps.keys().at(i),ps.values().at(i));
    }
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
    }).put();
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

void Http::download(QString url,const QMap<QString, QVariant> &ps)
{
    QMap<QString, QVariant> paramsMap;
    for(int i = 0; i < ps.keys().size(); i++) {
        paramsMap.insert(ps.keys().at(i),ps.values().at(i));
    }

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
    qDebug() << "params: " << paramsMap;
    qDebug() << "json: " << Util::mapToJson(paramsMap);
    QString jsonParams = Util::mapToJson(paramsMap);
//    if (paramsMap.contains("integers")) {
//        QJsonArray jsonArray;
//        for (const QVariant  &id : paramsMap.value("integers").toList()) {
//            QString stringItem = id.toString();
//            jsonArray.append(stringItem);
//        }
//        QJsonDocument jsonDoc(jsonArray);
//        jsonParams = jsonDoc.toJson(QJsonDocument::Indented);
//        qDebug() << "jsonParams: " << jsonParams;
//    }
    HttpClient(BASE_URL+url)
            .debug(true)
            //.params(paramsMap)
            .json(jsonParams)
            .headers(headersMap)
            .success([headersMap,this](const QString &response) {
        //replyFinished(response);
        qDebug() << "download response: " << response;
        QJsonObject responseModel = Util::parseJsonStringToObject(response);
        QJsonObject data = responseModel.value("data").toArray().first().toObject();
        QString bucketName = data["bucketName"].toString();
        QString fileUri = data["fileUri"].toString();
        QString fileName = data["fileName"].toString();
        QString fileId = data["fileId"].toString();
        qDebug() << "fileId: " << fileId;
        QString urlStr= "http://"+bucketName+"."+fileUri+"/"+fileName;

        QNetworkAccessManager *manager = new QNetworkAccessManager(this);
        QNetworkRequest request(urlStr);
        QNetworkReply *reply = manager->get(request);
        connect(reply, &QNetworkReply::finished, this, [=]() {
            if (reply->error() == QNetworkReply::NoError) {
                QByteArray imageData = reply->readAll();
                QFile file(FileManager::getMajorPicsPath()+"/"+fileId+".png");
                if (file.open(QIODevice::WriteOnly)) {
                    file.write(imageData);
                    file.close();
                }
            }
            reply->deleteLater();
        });
    }).fail([this](const QString &error, int errorCode) {
        qDebug() << "error: " << error << " errorCode: "<< errorCode;
        replyFail(error,errorCode);
    }).post();
}

void Http::upload(QString url,QString path)
{
    qDebug() << "enter upload path = " + path;
    //    if (!m_running) {
    //        m_thread = std::thread(&Http::uploadExcuseThread,this,url,path);
    //        m_running = true;
    //    }
    //    else{
    //        m_running = false;
    //        m_thread.join();
    //        upload(url,path);
    //    }
    uploadExcuseThread(url,path);

    //    auto myUploadThread = new UploadNetThread(url,path);
    //    connect(myUploadThread, &UploadNetThread::qtreplySucSignal, this,&Http::qtreplySucSignal);
    //    connect(myUploadThread, &UploadNetThread::qtreplyFailSignal, this, &Http::qtreplyFailSignal);
    //    myUploadThread->start();
}

QString Http::getActiveWifi()
{
    return QString("123");
}

void Http::uploadExcuseThread(QString url,QString path)
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
