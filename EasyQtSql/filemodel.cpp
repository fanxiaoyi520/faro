#include "filemodel.h"

FileModel::FileModel(QObject *parent) : QObject(parent)
{

}

// Getter 方法
int FileModel::stationId() const { return m_stationId; }
QString FileModel::stationNo() const { return m_stationNo; }
QString FileModel::taskNo() const { return m_taskNo; }
QString FileModel::filePath() const { return m_filePath; }
QString FileModel::fileCreateTime() const { return m_fileCreateTime; }
QString FileModel::fileUpdateTime() const { return m_fileUpdateTime; }
bool FileModel::isSelected() const { return m_isSelected; }
int FileModel::mapMode() const { return m_mapMode; }
int FileModel::colorMode() const { return m_colorMode; }
int FileModel::scanMode() const { return m_scanMode; }
QString FileModel::blockName() const { return m_blockName; }
QString FileModel::floorName() const { return m_floorName; }
QString FileModel::projectName() const { return m_projectName; }
QString FileModel::roomName() const { return m_roomName; }
QString FileModel::roomTaskNo() const { return m_roomTaskNo; }
QString FileModel::stageType() const { return m_stageType; }
QString FileModel::unitName() const { return m_unitName; }
QString FileModel::block_id() const { return m_block_id; }
QString FileModel::floor_id() const { return m_floor_id; }
QString FileModel::project_id() const { return m_project_id; }
QString FileModel::room_id() const { return m_room_id; }
QString FileModel::unit_id() const { return m_unit_id; }
int FileModel::stationType() const { return m_stationType; }
int FileModel::measure() const { return m_measure; }

// Setter 方法
void FileModel::setStationId(int stationId) { m_stationId = stationId; }
void FileModel::setStationNo(const QString &stationNo) { m_stationNo = stationNo; }
void FileModel::setTaskNo(const QString &taskNo) { m_taskNo = taskNo; }
void FileModel::setFilePath(const QString &filePath) { m_filePath = filePath; }
void FileModel::setFileCreateTime(const QString &fileCreateTime) { m_fileCreateTime = fileCreateTime; }
void FileModel::setFileUpdateTime(const QString &fileUpdateTime) { m_fileUpdateTime = fileUpdateTime; }
void FileModel::setIsSelected(bool isSelected) { m_isSelected = isSelected; }
void FileModel::setMapMode(int mapMode) { m_mapMode = mapMode; }
void FileModel::setColorMode(int colorMode) { m_colorMode = colorMode; }
void FileModel::setScanMode(int scanMode) { m_scanMode = scanMode; }
void FileModel::setBlockName(const QString &blockName) { m_blockName = blockName; }
void FileModel::setFloorName(const QString &floorName) { m_floorName = floorName; }
void FileModel::setProjectName(const QString &projectName) { m_projectName = projectName; }
void FileModel::setRoomName(const QString &roomName) { m_roomName = roomName; }
void FileModel::setRoomTaskNo(const QString &roomTaskNo) { m_roomTaskNo = roomTaskNo; }
void FileModel::setStageType(const QString &stageType) { m_stageType = stageType; }
void FileModel::setUnitName(const QString &unitName) { m_unitName = unitName; }
void FileModel::setBlock_id(const QString &block_id) { m_block_id = block_id; }
void FileModel::setFloor_id(const QString &floor_id) { m_floor_id = floor_id; }
void FileModel::setProject_id(const QString &project_id) { m_project_id = project_id; }
void FileModel::setRoom_id(const QString &room_id) { m_room_id = room_id; }
void FileModel::setUnit_id(const QString &unit_id) { m_unit_id = unit_id; }
void FileModel::setStationType(int stationType) { m_stationType = stationType; } // 注意：可能是拼写错误
void FileModel::setMeasure(int measure) { m_measure = measure; }
