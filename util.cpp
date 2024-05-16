#include "util.h"

// 实现静态方法
QJsonObject Util::parseJsonStringToObject(const QString &jsonString) {
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(jsonString.toUtf8(), &error);
    if (error.error != QJsonParseError::NoError) {
        // 处理错误
        return QJsonObject();
    }
    return doc.object();
}

QString Util::mapToJson(const QMap<QString, QVariant> &map) {
    QJsonDocument doc = QJsonDocument::fromVariant(QVariant(map));
    QByteArray bJson = doc.toJson();
    QString sJson = QString(bJson);
    return sJson;
}


void Util::populateModel(QStandardItemModel *model, const QJsonObject &data, QStandardItem *parent)
{
    QStandardItem *item = new QStandardItem(data["name"].toString());
    item->setData(data["id"].toString(), Qt::UserRole);

    if (parent) {
        parent->appendRow(item);
    } else {
        model->appendRow(item);
    }

    if (data.contains("children") && data["children"].isArray()) {
        const QJsonArray &children = data["children"].toArray();
        for (const auto &childData : children) {
            QJsonObject childObject = childData.toObject();
            populateModel(model, childObject, item);
        }
    }
}

