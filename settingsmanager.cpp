#include "settingsmanager.h"
#include <QGuiApplication>
#include <QDebug>

SettingsManager* SettingsManager::instancePtr = nullptr;

SettingsManager* SettingsManager::instance()
{
    if (instancePtr == nullptr) {
        instancePtr = new SettingsManager();
    }
    return instancePtr;
}

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent),
      settings(QCoreApplication::organizationName(), QCoreApplication::applicationName())
{
}

QString SettingsManager::getValue(const QString &key, const QString &defaultValue) const {
    return settings.value(key, defaultValue).toString();
}

void SettingsManager::setValue(const QString &key, const QString &value) {
    settings.setValue(key, value);
}

QString SettingsManager::user() const
{
    return QString("user");
}

QString SettingsManager::organizationalTree() const
{
    QJsonObject user = Util::parseJsonStringToObject(SettingsManager::instance()->getValue(SettingsManager::instance()->user()));
    QMap<QString, QString>headersMap;
    return user.value("tenant_id").toString();
}

QString SettingsManager::selectedProject() const
{
    QJsonObject user = Util::parseJsonStringToObject(SettingsManager::instance()->getValue(SettingsManager::instance()->user()));
    QMap<QString, QString>headersMap;
    return "selectedProject_"+user.value("tenant_id").toString();
}

QString SettingsManager::selectedProjectSource() const
{
    return "selectedProjectSource";
}

QString SettingsManager::selectedStageType() const
{
    return "selectedStageType";
}

QString SettingsManager::selectedItem() const
{
    return "selectedItem";
}

QString SettingsManager::stageType() const
{
    QJsonArray jsonArray;
    QStringList stringList = { "主体阶段(一阶段)", "砌筑阶段(二阶段)", "抹灰阶段(三阶段)","装修腻子阶段1(四阶段)","装修腻子阶段2(五阶段)" };
    for (int i = 0; i < stringList.size(); ++i) {
        QJsonObject jsonObject;
        jsonObject["name"] = stringList.at(i);
        jsonObject["index"] = i;
        jsonArray.append(jsonObject);
    }
    QJsonDocument jsonDoc(jsonArray);
    QString jsonString = jsonDoc.toJson(QJsonDocument::Indented);
    return jsonString;
}

QString SettingsManager::moreType() const
{
    QJsonArray jsonArray;
    QStringList stringList = {"重新计算","上传文件","测量模式"};
    QStringList imageList = {"../../images/home_page_slices/home_more_recalculate@2x.png","../../images/home_page_slices/home_more_upload@2x.png","../../images/home_page_slices/home_more_measuremode@2x.png"};
    for (int i = 0; i < stringList.size(); ++i) {
        QJsonObject jsonObject;
        jsonObject["name"] = stringList.at(i);
        jsonObject["imagePath"] = imageList.at(i);
        jsonObject["index"] = i;
        jsonArray.append(jsonObject);
    }
    QJsonDocument jsonDoc(jsonArray);
    QString jsonString = jsonDoc.toJson(QJsonDocument::Indented);
    return jsonString;
}

QString SettingsManager::selectedMeasureMode() const
{
    QJsonArray jsonArray;
    QStringList stringList = { "识别砌体", "测量平面范围(米)", "测量高度范围(米)","测量下尺模式","扫描密度","" };
    for (int i = 0; i < stringList.size(); ++i) {
        QJsonObject jsonObject;
        jsonObject["name"] = stringList.at(i);
        jsonObject["index"] = i;
        jsonArray.append(jsonObject);
    }
    QJsonDocument jsonDoc(jsonArray);
    QString jsonString = jsonDoc.toJson(QJsonDocument::Indented);
    return jsonString;
}


QString SettingsManager::pubKey_integers() const
{
    return "integers";
}

