#include "imageprocessor.h"
#include <QDebug>
ImageProcessor::ImageProcessor(QObject *parent) : QObject(parent) {
}

void ImageProcessor::changeImageColor(const QString &imagePath, const QString &hexColor) {
    QImage image(imagePath);
    if (!image.isNull()) {
        QColor color(hexColor.toStdString().c_str());
        if (color.isValid()) {
            modifiedImage = changeColor(image, color);
            emit modifiedImageChanged(modifiedImage);
        }
    }
}

QImage ImageProcessor::changeColor(const QImage &image, const QColor &color) {
    QImage result = image;
    QRgb newColor = color.rgb();

    for (int y = 0; y < result.height(); ++y) {
        for (int x = 0; x < result.width(); ++x) {
            QRgb pixel = result.pixel(x, y);
            int gray = qGray(pixel);
            // 这里只是一个简单的示例，可以根据需要实现更复杂的颜色映射算法
            // 例如，你可以根据原始颜色的亮度来设置新的颜色
            QRgb newPixel = QColor(newColor).lighter(gray * 1.5).rgb(); // 假设这里根据灰度来调整新颜色的亮度
            result.setPixel(x, y, newPixel);
        }
    }
    return result;
}

QImage ImageProcessor::getModifiedImage() const {
    return modifiedImage;
}
