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
    Q_PROPERTY(QString building_project_page READ building_project_page CONSTANT)
    Q_PROPERTY(QString building_room_projectRoomCount READ building_room_projectRoomCount CONSTANT)
public:
    static Api* instance();
    QString admin_tenant_queryTenantByUserName() const;
    QString auth_oauth_token() const;
    QString admin_user_details() const;
    QString admin_tenant_details() const;
    QString admin_dept_tree() const;
    QString building_project_page() const;
    QString building_room_projectRoomCount() const;
private:
    Api(QObject *parent = nullptr);
    Q_DISABLE_COPY(Api)
};

#endif // API_H
