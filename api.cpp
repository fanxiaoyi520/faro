﻿#include "api.h"

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

Api::Api(QObject *parent) : QObject(parent) {}
