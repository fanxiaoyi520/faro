#ifndef APPLICATIONCONTROLLER_H
#define APPLICATIONCONTROLLER_H

#include <QObject>
#include <QProcess>
#include <QCoreApplication>
class ApplicationController : public QObject
{
    Q_OBJECT
public:
    explicit ApplicationController(QObject *parent = nullptr);

public slots:
    void restartApplication() {
        QCoreApplication::quit();

        QString appPath = QCoreApplication::applicationFilePath();
        QStringList arguments;
        QProcess::startDetached(appPath, arguments);
    }
};

#endif // APPLICATIONCONTROLLER_H
