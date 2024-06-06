#include "api.h"

Api* Api::instance() {
    static Api instance;
    return &instance;
}

QString Api::admin_tenant_queryTenantByUserName() const
{
    return QString("/admin/tenant/queryTenantByUserName");
}

QString Api::auth_oauth_token() const {
    return QString("/auth/oauth2/token");
}

QString Api::admin_user_details() const
{
    return QString("/admin/user/details");
}

QString Api::admin_tenant_details() const
{
    return QString("/admin/tenant/details");
}

QString Api::admin_user_password() const
{
     return QString("/admin/user/password");
}

QString Api::admin_dept_tree() const
{
    return QString("/admin/dept/tree");
}

QString Api::building_project_page() const
{
    return QString("/building/project/page");
}

QString Api::building_room_projectRoomCount() const
{
    return QString("/building/room/projectRoomCount");
}

QString Api::building_block_page() const
{
    return QString("/building/block/page");
}

QString Api::building_room_blockRoomCount() const
{
    return QString("/building/room/blockRoomCount");
}

QString Api::building_unit_page() const
{
    return QString("/building/unit/page");
}

QString Api::building_floor_page() const
{
    return QString("/building/floor/page");
}

QString Api::building_room_countFloorRoom() const
{
    return QString("/building/room/countFloorRoom");
}

QString Api::building_room_listByFloorId() const
{
    return QString("/building/room/listByFloorId");
}

QString Api::building_roomTask_getRoomTaskInfo() const
{
    return QString("/building/roomTask/getRoomTaskInfo");
}

QString Api::building_measureDevice_searchDevice() const
{
    return QString("/building/measureDevice/searchDevice");
}

QString Api::admin_sys_file_listFileByFileIds() const
{
    return QString("/admin/sys-file/listFileByFileIds");
}

QString Api::admin_sys_file_upload() const
{
    return QString("/admin/sys-file/upload");
}

QString Api::building_roomTaskExecute_calculateStationTask() const
{
    return QString("/building/roomTaskExecute/calculateStationTask");
}

QString Api::building_roomTaskExecute_rerun() const
{
    return QString("/building/roomTaskExecute/rerun");
}

Api::Api(QObject *parent) : QObject(parent) {}
