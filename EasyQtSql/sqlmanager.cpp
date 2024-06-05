#include "sqlmanager.h"

using namespace EasyQtSql;
SqlManager::SqlManager(QObject *parent) : QObject(parent)
{

}

void SqlManager::initDefaultDataBase()
{
    QLatin1Literal driverName("QSQLITE");

    if (!QSqlDatabase::drivers().contains(driverName))
        qDebug() << "This test requires the SQLITE database driver";

    QSqlDatabase sdb = QSqlDatabase::addDatabase(driverName);

    sdb.setDatabaseName(":memory:");

    if (!sdb.open())
    {
        qDebug() << sdb.lastError().text().toStdString().c_str();
    }
}

void SqlManager::cleanupDefaultDataBase()
{
    {
        QSqlDatabase sdb = QSqlDatabase::database(QSqlDatabase::defaultConnection);
        if (sdb.isOpen())
        {
            sdb.close();
        }
    }

    QSqlDatabase::removeDatabase(QSqlDatabase::defaultConnection);
}

void SqlManager::createTableWithName(const QString &tableName)
{
    try
    {
        Transaction t;
        QString sql = "CREATE TABLE " + tableName + "(\n"
                                                   "    stationId INT NOT NULL,\n"
                                                   "    stationNo VARCHAR(255) NOT NULL,\n"
                                                   "    taskNo VARCHAR(255) NOT NULL,\n"
                                                   "    filePath TEXT NOT NULL,\n"
                                                   "    fileCreateTime DATETIME,\n"
                                                   "    fileUpdateTime DATETIME,\n"
                                                   "    isSelected BOOLEAN DEFAULT FALSE,\n"
                                                   "    mapMode INT,\n"
                                                   "    colorMode INT,\n"
                                                   "    scanMode INT,\n"
                                                   "    blockName VARCHAR(255),\n"
                                                   "    floorName VARCHAR(255),\n"
                                                   "    projectName VARCHAR(255),\n"
                                                   "    roomName VARCHAR(255),\n"
                                                   "    roomTaskNo VARCHAR(255),\n"
                                                   "    stageType VARCHAR(255),\n"
                                                   "    unitName VARCHAR(255),\n"
                                                   "    block_id VARCHAR(255),\n"
                                                   "    floor_id VARCHAR(255),\n"
                                                   "    project_id VARCHAR(255),\n"
                                                   "    room_id VARCHAR(255),\n"
                                                   "    unit_id VARCHAR(255),\n"
                                                   "    station_Type INT,\n"
                                                   "    measure INT\n"
                                                   ");";

        t.execNonQuery(sql);
        PreparedQuery query = t.prepare("SELECT * FROM "+tableName);
        QueryResult res = query.exec();
        t.commit(); // commit transaction (tableName created and commited)
    }
    catch (const DBException &e)
    {
        qDebug() << e.lastError.text().toStdString().c_str();
    }
}

void SqlManager::dropTableWithName(const QString &tableName)
{
    try
    {
        Transaction t;

        t.execNonQuery("DROP TABLE "+tableName); //can drop tableName

        t.commit(); // commit transaction
    }
    catch (const DBException &e)
    {
        qDebug() << e.lastError.text().toStdString().c_str();
    }
}

void SqlManager::insertData(Row row, const QString &tableName)
{
    qDebug() << "insert data: " << row.taskNo;
    try
    {
        Transaction t;
        InsertQuery query = t.insertInto(tableName + " (stationId,stationNo,taskNo,filePath,fileCreateTime,fileUpdateTime,isSelected,mapMode,colorMode,scanMode,blockName,floorName,projectName,roomName,roomTaskNo,stageType,unitName,block_id,floor_id,project_id,room_id,unit_id,stationTpye,measure)");

        query.values(row.stationId,
                     row.stationNo,
                     row.taskNo,
                     row.filePath,
                     row.fileCreateTime,
                     row.fileUpdateTime,
                     row.isSelected,
                     row.mapMode,
                     row.colorMode,
                     row.scanMode,
                     row.blockName,
                     row.floorName,
                     row.projectName,
                     row.roomName,
                     row.roomTaskNo,
                     row.stageType,
                     row.unitName,
                     row.block_id,
                     row.floor_id,
                     row.project_id,
                     row.room_id,
                     row.unit_id,
                     row.stationType,
                     row.measure
                     ).exec();
qDebug() << "insert data 1111111111: " << row.taskNo;
        QueryResult res = t.execQuery("SELECT COUNT(*) FROM "+tableName);
        qDebug() << "insert data 2222222222222222: " << row.taskNo;
        t.each("SELECT * FROM "+tableName, [](const QueryResult &row){
           qDebug() << "-------------------------1: "<<row.toMap();
        });
    }
    catch (const DBException &ex)
    {
        qDebug() << ex.lastError.text().toStdString().c_str();
    }
}
