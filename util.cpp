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

QStandardItemModel* Util::jsonStringToStandardModel(const QString& jsonString) {
    QStandardItemModel* model = new QStandardItemModel();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonString.toUtf8());
    if (!jsonDoc.isObject()) {
        qDebug() << "JSON is not an object";
        return nullptr;
    }

    QJsonObject jsonObject = jsonDoc.object();
    for (auto it = jsonObject.constBegin(); it != jsonObject.constEnd(); ++it) {
        QList<QStandardItem*> rowItems;
        rowItems.append(new QStandardItem(it.key()));

        QJsonValue value = it.value();
        if (value.isString()) {
            rowItems.append(new QStandardItem(value.toString()));
        } else {
            rowItems.append(new QStandardItem(QString("Non-string value")));
        }

        model->appendRow(rowItems);
    }

    // 设置模型的水平头
    model->setHorizontalHeaderLabels(QStringList() << "Key" << "Value");
    return model;
}

QString Util::standardModelToJsonString(const QStandardItemModel* model) {
    QJsonObject jsonObject;

    for (int row = 0; row < model->rowCount(); ++row) {
        QJsonObject itemObject;
        itemObject[model->index(row, 0).data().toString()] = QJsonValue(model->index(row, 1).data().toString());
        jsonObject[QString::number(row)] = itemObject;
    }

    QJsonDocument jsonDoc(jsonObject);
    return jsonDoc.toJson(QJsonDocument::Indented);
}

