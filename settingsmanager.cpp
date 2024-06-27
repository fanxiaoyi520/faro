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

QString SettingsManager::selectedMeasureData() const
{
    return "selectedMeasureData";
}

QString SettingsManager::currentDevice() const
{
    return "currentDevice";
}

QString SettingsManager::fileInfoData() const
{
    return "fileInfoData";
}

QString SettingsManager::LoginMode() const
{
    return "LoginMode";
}

QString SettingsManager::pubKey_integers() const
{
    return "integers";
}

