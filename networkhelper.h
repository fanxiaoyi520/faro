#ifndef NETWORKHELPER_H
#define NETWORKHELPER_H

#include <QObject>
#include <QNetworkConfigurationManager>
#include <QDebug>
#include <QMutex>
#include <functional>
class NetworkHelper : public QObject
{
    Q_OBJECT
public:
    static bool checkNetworkStatus();

    // 提供一个信号来通知网络状态的变化
    static void registerNetworkStatusChangedCallback(const std::function<void(bool)>& callback);

private:
    static QNetworkConfigurationManager *networkConfigurationManager;
    static QMutex mutex; // 用于保护静态变量，确保线程安全
    static std::vector<std::function<void(bool)>> callbacks; // 存储所有注册的回调函数

    // 静态成员需要在类外进行初始化
    static void initStaticMembers();

    // 槽函数，响应网络配置变化
private slots:
    static void onNetworkConfigurationChanged(const QNetworkConfiguration &config);

};

#endif // NETWORKHELPER_H
