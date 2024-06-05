// Api.h
#ifndef API_H
#define API_H

#include <QObject>
#include <QString>

class Api : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString auth_oauth_token READ auth_oauth_token CONSTANT)
    Q_PROPERTY(QString admin_tenant_queryTenantByUserName READ admin_tenant_queryTenantByUserName CONSTANT)
    Q_PROPERTY(QString admin_user_details READ admin_user_details CONSTANT)
    Q_PROPERTY(QString admin_tenant_details READ admin_tenant_details CONSTANT)
    Q_PROPERTY(QString admin_dept_tree READ admin_dept_tree CONSTANT)
    Q_PROPERTY(QString admin_user_password READ admin_user_password CONSTANT)
    Q_PROPERTY(QString building_project_page READ building_project_page CONSTANT)
    Q_PROPERTY(QString building_room_projectRoomCount READ building_room_projectRoomCount CONSTANT)
    Q_PROPERTY(QString building_block_page READ building_block_page CONSTANT)
    Q_PROPERTY(QString building_room_blockRoomCount READ building_room_blockRoomCount CONSTANT)
    Q_PROPERTY(QString building_unit_page READ building_unit_page CONSTANT)
    Q_PROPERTY(QString building_room_countFloorRoom READ building_room_countFloorRoom CONSTANT)
    Q_PROPERTY(QString building_floor_page READ building_floor_page CONSTANT)
    Q_PROPERTY(QString building_room_listByFloorId READ building_room_listByFloorId CONSTANT)
    Q_PROPERTY(QString building_roomTask_getRoomTaskInfo READ building_roomTask_getRoomTaskInfo CONSTANT)
    Q_PROPERTY(QString building_measureDevice_searchDevice READ building_measureDevice_searchDevice CONSTANT)
    Q_PROPERTY(QString admin_sys_file_listFileByFileIds READ admin_sys_file_listFileByFileIds CONSTANT)
    Q_PROPERTY(QString admin_sys_file_upload READ admin_sys_file_upload CONSTANT)
    Q_PROPERTY(QString building_measureTask_pager READ building_measureTask_pager CONSTANT)
    Q_PROPERTY(QString building_tasknotify_statistics READ building_tasknotify_statistics CONSTANT)
    Q_PROPERTY(QString building_roomTaskExecute_calculateStationTask READ building_roomTaskExecute_calculateStationTask CONSTANT)

public:
    static Api* instance();
    QString admin_tenant_queryTenantByUserName() const;
    QString auth_oauth_token() const;
    QString admin_user_details() const;
    QString admin_tenant_details() const;
    QString admin_user_password() const;
    QString admin_dept_tree() const;
    QString building_project_page() const;
    QString building_room_projectRoomCount() const;
    QString building_block_page() const;
    QString building_room_blockRoomCount() const;
    QString building_unit_page() const;
    QString building_floor_page() const;
    QString building_room_countFloorRoom() const;
    QString building_room_listByFloorId() const;
    QString building_roomTask_getRoomTaskInfo() const;
    QString building_measureDevice_searchDevice() const;
    QString building_measureTask_pager() const;
    QString building_tasknotify_statistics() const;
    QString admin_sys_file_listFileByFileIds() const;
    QString admin_sys_file_upload() const;
    QString building_roomTaskExecute_calculateStationTask() const;
private:
    Api(QObject *parent = nullptr);
    Q_DISABLE_COPY(Api)
};

#endif // API_H
