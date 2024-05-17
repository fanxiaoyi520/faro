#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include <QSettings>
#include "util.h"

class SettingsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString user READ user CONSTANT)
    Q_PROPERTY(QString organizationalTree READ organizationalTree CONSTANT)
    Q_PROPERTY(QString selectedProject READ selectedProject CONSTANT)
    Q_PROPERTY(QString selectedProjectSource READ selectedProjectSource CONSTANT)
    Q_PROPERTY(QString selectedStageType READ selectedStageType CONSTANT)
    Q_PROPERTY(QString selectedItem READ selectedItem CONSTANT)

    Q_PROPERTY(QString stageType READ stageType CONSTANT)
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
    QString organizationalTree() const;
    QString selectedProject() const;
    QString selectedProjectSource() const;
    QString selectedStageType() const;
    QString selectedItem() const;

    /**
     * @brief 静态数据
     * @return
     */
    QString stageType() const;
private:
    QSettings settings;
    explicit SettingsManager(QObject *parent = nullptr);
    SettingsManager(const SettingsManager &) = delete;
    SettingsManager& operator=(const SettingsManager &) = delete;
    static SettingsManager *instancePtr;
};

#endif // SETTINGSMANAGER_H
