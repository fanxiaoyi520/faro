#ifndef UTIL_H
#define UTIL_H

#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QString>
#include <QDebug>
#include <QQmlApplicationEngine>
#include <QStandardItemModel>
#include <QJsonArray>
#include <QMap>
#include <QVariant>
#include <QDateTime>
#include <QUuid>
#include <QCoreApplication>
#include "filemanager.h"
#include <QStorageInfo>
class Util {
public:
    // 声明静态方法
    static QJsonObject parseJsonStringToObject(const QString &jsonString);
    // 静态方法：将QMap<QString, QVariant>转换为JSON字符串
    static QString mapToJson(const QMap<QString, QVariant>& map);
    static void populateModel(QStandardItemModel *model, const QJsonObject &data, QStandardItem *parent = nullptr);
    // 将JSON字符串转换为QStandardItemModel
    static QStandardItemModel* jsonStringToStandardModel(const QString& jsonString);
    // 将QStandardItemModel转换为JSON字符串
    static QString standardModelToJsonString(const QStandardItemModel* model);
    static qint64 getTimestampMilliseconds();
    static qint64 getTimestampSeconds();
    static QString generateUuid();
    static QString getdownsampleVoxelSize(const QString &stageType);
    static QString getDriveLetter();
};

#endif // UTIL_H
