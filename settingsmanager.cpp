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
