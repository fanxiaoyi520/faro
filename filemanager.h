#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>
#include <QDir>
#include <QFileInfo>
#include <QtZlib/zlib.h>
#include <QDebug>
#include "QtGui/private/qzipreader_p.h"
#include "QtGui/private/qzipwriter_p.h"
#define	FILE_MAX_SIZE 1024*1024
class FileManager : public QObject
{
    Q_OBJECT
public:
    explicit FileManager(QObject *parent = nullptr);
    QFileInfoList ergodic_compression_file(QZipWriter *writer, const QString& rootPath, QString dirPath);
    bool compression_zip_file(const QString& selectFile2DirPath, const QString& savePath);
    bool decompression_zip_file(const QString& selectZipFilePath, const QString& savePath);
signals:

};

#endif // FILEMANAGER_H
