#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>
#include <QDir>
#include <QFileInfo>
#include <QtZlib/zlib.h>
#include <QDebug>
#include <QString>
#include "util.h"
#include "QtGui/private/qzipreader_p.h"
#include "QtGui/private/qzipwriter_p.h"
#define	FILE_MAX_SIZE 1024*1024
#define FLSDIRECTORY "fls"
#define ZIPDIRECTORY "zip"
class FileManager : public QObject
{
    Q_OBJECT
public:
    explicit FileManager(QObject *parent = nullptr);
    QFileInfoList ergodic_compression_file(QZipWriter *writer, const QString& rootPath, QString dirPath);
    bool compression_zip_file(const QString& selectFile2DirPath, const QString& savePath);
    bool decompression_zip_file(const QString& selectZipFilePath, const QString& savePath);

    static QString getFlsPath();
    static bool removePath(const QString &path);
    static QStringList getFilesInDirectory(const QString &dirPath, const QStringList &filters = QStringList());
signals:

};

#endif // FILEMANAGER_H
