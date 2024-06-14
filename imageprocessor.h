#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H

#include <QObject>
#include <QImage>

class ImageProcessor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QImage modifiedImage READ getModifiedImage NOTIFY modifiedImageChanged)

public:
    explicit ImageProcessor(QObject *parent = nullptr);

    Q_INVOKABLE void changeImageColor(const QString &imagePath, const QString &hexColor);
    QImage getModifiedImage() const;

signals:
    void modifiedImageChanged(const QImage &image);

private:
    QImage modifiedImage;

    QImage changeColor(const QImage &image, const QColor &color);
};

#endif // IMAGEPROCESSOR_H
