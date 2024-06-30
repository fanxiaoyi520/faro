#ifndef QTENUMCLASS_H
#define QTENUMCLASS_H

#include <QObject>
class QtEnumClass : public QObject
{
    Q_OBJECT
public:
    explicit QtEnumClass(QObject *parent = nullptr);

    enum LoginMode {
        Ordinary,
        Major
    };
    Q_ENUM(LoginMode)
signals:

};

#endif // QTENUMCLASS_H
