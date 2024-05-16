#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include <QSettings>

class SettingsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString user READ user CONSTANT)

public:
    static SettingsManager* instance();

    // Getter
    Q_INVOKABLE QString getValue(const QString &key, const QString &defaultValue = "") const;

    // Setter
    Q_INVOKABLE void setValue(const QString &key, const QString &value);

    /**
     * @brief user
     * @return
     * 保存的字段
     */
    QString user() const;

private:
    QSettings settings;
    explicit SettingsManager(QObject *parent = nullptr);
    SettingsManager(const SettingsManager &) = delete;
    SettingsManager& operator=(const SettingsManager &) = delete;
    static SettingsManager *instancePtr;
};

#endif // SETTINGSMANAGER_H
