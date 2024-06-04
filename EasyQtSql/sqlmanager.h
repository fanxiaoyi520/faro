#ifndef SQLMANAGER_H
#define SQLMANAGER_H

#include <QObject>
#include <QDebug>
#include "EasyQtSql/src/EasyQtSql.h"
#include "filemodel.h"

#define FileTable QString("filetable1")

struct Row
{
    int stationId;
    QString stationNo;
    QString taskNo;
    QString filePath;
    QString fileCreateTime;
    QString fileUpdateTime;
    bool isSelected;
    int mapMode;
    int colorMode;
    int scanMode;
    QString blockName;
    QString floorName;
    QString projectName;
    QString roomName;
    QString roomTaskNo;
    QString stageType;
    QString unitName;
    QString block_id;
    QString floor_id;
    QString project_id;
    QString room_id;
    QString unit_id;
    int stationType;
    int measure;                    //测量模式

private:
    Q_GADGET
    Q_PROPERTY(int stationId MEMBER stationId)
    Q_PROPERTY(QString stationNo MEMBER stationNo)
    Q_PROPERTY(QString taskNo MEMBER taskNo)
    Q_PROPERTY(QString filePath MEMBER filePath)
    Q_PROPERTY(QString fileCreateTime MEMBER fileCreateTime)
    Q_PROPERTY(QString fileUpdateTime MEMBER fileUpdateTime)
    Q_PROPERTY(bool isSelected MEMBER isSelected)
    Q_PROPERTY(int mapMode MEMBER mapMode)
    Q_PROPERTY(int colorMode MEMBER colorMode)
    Q_PROPERTY(int scanMode MEMBER scanMode)
    Q_PROPERTY(QString blockName MEMBER blockName)
    Q_PROPERTY(QString floorName MEMBER floorName)
    Q_PROPERTY(QString projectName MEMBER projectName)
    Q_PROPERTY(QString roomName MEMBER roomName)
    Q_PROPERTY(QString roomTaskNo MEMBER roomTaskNo)
    Q_PROPERTY(QString stageType MEMBER stageType)
    Q_PROPERTY(QString unitName MEMBER unitName)
    Q_PROPERTY(QString block_id MEMBER block_id)
    Q_PROPERTY(QString floor_id MEMBER floor_id)
    Q_PROPERTY(QString project_id MEMBER project_id)
    Q_PROPERTY(QString room_id MEMBER room_id)
    Q_PROPERTY(QString unit_id MEMBER unit_id)
    Q_PROPERTY(int stationType MEMBER stationType)
    Q_PROPERTY(int measure MEMBER measure)
};

class SqlManager : public QObject
{
    Q_OBJECT
public:
    explicit SqlManager(QObject *parent = nullptr);

    static void initDefaultDataBase();
    static void cleanupDefaultDataBase();
    static void createTableWithName(const QString& tableName = FileTable);
    static void dropTableWithName(const QString& tableName = FileTable);

    static void insertData(Row row,const QString& tableName = FileTable);
};

#endif // SQLMANAGER_H
