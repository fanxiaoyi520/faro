#ifndef FILEMODEL_H
#define FILEMODEL_H

#include <QtCore>

class FileModel : public QObject/*,public Row*/ {
    // 定义属性
    Q_PROPERTY(int stationId READ stationId WRITE setStationId)
    Q_PROPERTY(QString stationNo READ stationNo WRITE setStationNo)
    Q_PROPERTY(QString taskNo READ taskNo WRITE setTaskNo)
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath)
    Q_PROPERTY(QString fileCreateTime READ fileCreateTime WRITE setFileCreateTime)
    Q_PROPERTY(QString fileUpdateTime READ fileUpdateTime WRITE setFileUpdateTime)
    Q_PROPERTY(bool isSelected READ isSelected WRITE setIsSelected)
    Q_PROPERTY(int mapMode READ mapMode WRITE setMapMode) // 注意：可能是拼写错误
    Q_PROPERTY(int colorMode READ colorMode WRITE setColorMode)
    Q_PROPERTY(int scanMode READ scanMode WRITE setScanMode)
    Q_PROPERTY(QString blockName READ blockName WRITE setBlockName)
    Q_PROPERTY(QString floorName READ floorName WRITE setFloorName)
    Q_PROPERTY(QString projectName READ projectName WRITE setProjectName)
    Q_PROPERTY(QString roomName READ roomName WRITE setRoomName)
    Q_PROPERTY(QString roomTaskNo READ roomTaskNo WRITE setRoomTaskNo)
    Q_PROPERTY(QString stageType READ stageType WRITE setStageType)
    Q_PROPERTY(QString unitName READ unitName WRITE setUnitName)
    Q_PROPERTY(QString block_id READ block_id WRITE setBlock_id)
    Q_PROPERTY(QString floor_id READ floor_id WRITE setFloor_id)
    Q_PROPERTY(QString project_id READ project_id WRITE setProject_id)
    Q_PROPERTY(QString room_id READ room_id WRITE setRoom_id)
    Q_PROPERTY(QString unit_id READ unit_id WRITE setUnit_id)
    Q_PROPERTY(int stationType READ stationType WRITE setStationType) // 注意：可能是拼写错误
    Q_PROPERTY(int measure READ measure WRITE setMeasure)

public:
    explicit FileModel(QObject *parent = nullptr);

    // Getter 方法
    int stationId() const;
    QString stationNo() const;
    QString taskNo() const;
    QString filePath() const;
    QString fileCreateTime() const;
    QString fileUpdateTime() const;
    bool isSelected() const;
    int mapMode() const;
    int colorMode() const;
    int scanMode() const;
    QString blockName() const;
    QString floorName() const;
    QString projectName() const;
    QString roomName() const;
    QString roomTaskNo() const;
    QString stageType() const;
    QString unitName() const;
    QString block_id() const;
    QString floor_id() const;
    QString project_id() const;
    QString room_id() const;
    QString unit_id() const;
    int stationType() const;
    int measure() const;

    // Setter 方法
    void setStationId(int stationId);
    void setStationNo(const QString &stationNo);
    void setTaskNo(const QString &taskNo);
    void setFilePath(const QString &filePath);
    void setFileCreateTime(const QString &fileCreateTime);
    void setFileUpdateTime(const QString &fileUpdateTime);
    void setIsSelected(bool isSelected);
    void setMapMode(int mapMode);
    void setColorMode(int colorMode);
    void setScanMode(int scanMode);
    void setBlockName(const QString &blockName);
    void setFloorName(const QString &floorName);
    void setProjectName(const QString &projectName);
    void setRoomName(const QString &roomName);
    void setRoomTaskNo(const QString &roomTaskNo);
    void setStageType(const QString &stageType);
    void setUnitName(const QString &unitName);
    void setBlock_id(const QString &block_id);
    void setFloor_id(const QString &floor_id);
    void setProject_id(const QString &project_id);
    void setRoom_id(const QString &room_id);
    void setUnit_id(const QString &unit_id);
    void setStationType(int stationType);
    void setMeasure(int measure);

private:
        int m_stationId;
        QString m_stationNo;
        QString m_taskNo;
        QString m_filePath;
        QString m_fileCreateTime;
        QString m_fileUpdateTime;
        bool m_isSelected;
        int m_mapMode; // 注意：可能是拼写错误
        int m_colorMode;
        int m_scanMode;
        QString m_blockName;
        QString m_floorName;
        QString m_projectName;
        QString m_roomName;
        QString m_roomTaskNo;
        QString m_stageType;
        QString m_unitName;
        QString m_block_id;
        QString m_floor_id;
        QString m_project_id;
        QString m_room_id;
        QString m_unit_id;
        int m_stationType; // 注意：可能是拼写错误
        int m_measure;
};

#endif // FILEMODEL_H
