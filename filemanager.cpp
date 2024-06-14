#include "filemanager.h"

FileManager* FileManager::instance() {
    static FileManager *instance = nullptr;
    if (!instance) {
        instance = new FileManager;
    }
    return instance;
}

//FileManager::FileManager(QObject *parent) : QObject(parent)
//{

//}

QFileInfoList FileManager::ergodic_compression_file(QZipWriter *writer, const QString &rootPath, QString dirPath)
{
    QDir crrDir(dirPath);
    ///解压失败的文件
    QFileInfoList errFileList;

    ///添加文件
    QFileInfoList fileList = crrDir.entryInfoList(QDir::Files | QDir::Hidden);
    for (const QFileInfo& fileInfo : fileList)
    {
        QString subFilePath = fileInfo.absoluteFilePath();
        QString zipWithinfilePath = subFilePath.mid(rootPath.size() + 1);

        QFile file(subFilePath);
        qint64 size = file.size() / 1024 / 1024;
        if (!file.open(QIODevice::ReadOnly) || size > FILE_MAX_SIZE)
        {
            ///打开文件失败，或者大于1GB导致无法解压的文件
            errFileList.append(fileInfo);
            continue;
        }
        writer->addFile(zipWithinfilePath, file.readAll());
        file.close();
    }

    ///添加文件夹
    QFileInfoList folderList = crrDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QFileInfo& folderInfo : folderList)
    {
        QString subDirPath = folderInfo.absoluteFilePath();
        QString zipWithinDirPath = subDirPath.mid(rootPath.size() + 1);

        writer->addDirectory(zipWithinDirPath);
        QFileInfoList child_file_list = ergodic_compression_file(writer, rootPath, subDirPath);
        errFileList.append(child_file_list);
    }

    return errFileList;
}

bool FileManager::compression_zip_file(const QString &selectFile2DirPath, const QString &savePath)
{
    if (selectFile2DirPath.isEmpty() || savePath.isEmpty())
    {
        qDebug() << "Empty file or save path provided.";
        return false;
    }
    if (!QFile::exists(selectFile2DirPath))
    {
        qDebug() << "File does not exist:" << selectFile2DirPath;
        return false;
    }
    if (!QDir(savePath).exists())
    {
        qDebug() << "Save directory does not exist:" << savePath;
        return false;
    }

    QFileInfo fileInfo(selectFile2DirPath);
    if (fileInfo.isFile())
    {
        QString fileName = QFileInfo(selectFile2DirPath).baseName();
        QString writerFilePath = savePath + "/" + fileName + ".zip";

        QFile selectFile(selectFile2DirPath);
        qint64 size = selectFile.size() / 1024 / 1024;
        if (!selectFile.open(QIODevice::ReadOnly) || size > FILE_MAX_SIZE)
        {
            qDebug() << "Failed to open zip file for writing:" << writerFilePath;
            ///打开文件失败，或者大于1GB导致无法压缩的文件
            return false;
        }
        QString addFileName = QFileInfo(selectFile2DirPath).fileName();
        QZipWriter writer(writerFilePath);
        writer.addFile(addFileName, selectFile.readAll());
        selectFile.close();
        return true;
    }
    else///压缩的是一个文件夹
    {
        QString zipRootFolder = selectFile2DirPath.mid(selectFile2DirPath.lastIndexOf("/") + 1);
        QString selectDirUpDir = selectFile2DirPath.left(selectFile2DirPath.lastIndexOf("/"));
        qDebug() << "zipRootFolder =" << zipRootFolder;
        qDebug() << "selectDirUpDir =" << selectDirUpDir;
        QString saveFilePath = savePath + "/" + zipRootFolder + ".zip";

        QZipWriter writer(saveFilePath);
//        writer.addDirectory(zipRootFolder);
        QFileInfoList fileList = ergodic_compression_file(&writer, selectDirUpDir, selectFile2DirPath);
        writer.close();
        if (0 == fileList.size())
            return true;
        return false;
    }
}

bool FileManager::decompression_zip_file(const QString &selectZipFilePath, const QString &savePath)
{
    if (selectZipFilePath.isEmpty() || savePath.isEmpty())
    {
        qDebug() << "Selected ZIP file path or save path is empty.";
        return false;
    }
    if (!QFileInfo(selectZipFilePath).isFile() || !QFileInfo(savePath).isDir())
    {
        qDebug() << "Selected ZIP file is not a file or save path is not a directory.";
        return false;
    }

    bool ret = true;
    QZipReader zipReader(selectZipFilePath);
    QVector<QZipReader::FileInfo> zipAllFiles = zipReader.fileInfoList();
    qDebug() << "Found" << zipAllFiles.size() << "files/directories in the ZIP archive.";

    for (const QZipReader::FileInfo& zipFileInfo : zipAllFiles)
    {
        const QString currDir2File = savePath + "/" + zipFileInfo.filePath;
        qDebug() << "Processing:" << currDir2File;

        if (zipFileInfo.isSymLink)
        {
            QString destination = QFile::decodeName(zipReader.fileData(zipFileInfo.filePath));
            if (destination.isEmpty())
            {
                ret = false;
                qDebug() << "Skipping symlink:" << zipFileInfo.filePath;
                continue;
            }

            QFileInfo linkFi(currDir2File);
            if (!QFile::exists(linkFi.absolutePath()))
                QDir::root().mkpath(linkFi.absolutePath());
            if (!QFile::link(destination, currDir2File))
            {
                ret = false;
                continue;
            }
        }
        if (zipFileInfo.isDir)
        {
            if (!QDir().mkpath(currDir2File))
            {
                qDebug() << "Failed to create directory:" << currDir2File;
                return false;
            }
            qDebug() << "Directory created:" << currDir2File;
        }
        if (zipFileInfo.isFile)
        {
            QByteArray dt = zipFileInfo.filePath.toUtf8();
            QString strtmp = QString::fromLocal8Bit(dt);

            QFile currFile(currDir2File);
            if (!currFile.isOpen())
            {
                currFile.open(QIODevice::WriteOnly);
            }
            else {
                ret = false;
                continue;
            }

            qint64 size = zipFileInfo.size / 1024 / 1024;
            if (size > FILE_MAX_SIZE)
            {
                ret = false;
                continue;
            }
            QByteArray byteArr = zipReader.fileData(strtmp);
            currFile.write(byteArr);
            currFile.setPermissions(zipFileInfo.permissions);
            currFile.close();
        }
    }
    zipReader.close();
    return ret;
}

QString FileManager::compression_zip_by_filepath(const QString &filePath)
{
    QString resultPath = "";
    QString originPath = filePath;
    originPath.replace(0,7,Util::getDriveLetter());
    qDebug() << "new usbPath = " << originPath;
    QDir originDir = QDir(originPath);
    originDir.cdUp();
    QString parentPath = originDir.absolutePath();
    bool ret = FileManager::compression_zip_file(originPath,parentPath);
    if(ret){
        QString zipRootFolder = filePath.mid(filePath.lastIndexOf("/") + 1);
        resultPath = parentPath + "/" + zipRootFolder + ".zip";
        qDebug() << "new zipPath = " << resultPath;
    }
    return resultPath;
}

QString FileManager::getFlsPath()
{
    QString appDirPath = "C:";//QCoreApplication::applicationDirPath();
    QString zipFilePath = appDirPath+"/"+FLSDIRECTORY+"/"+QString::number(Util::getTimestampMilliseconds())+"/"+Util::generateUuid();
    QString flsDirectory = QDir(zipFilePath).filePath(QString());
    QDir dir;
    if (!dir.exists(flsDirectory)) {
        if (!dir.mkpath (flsDirectory)) {
            qDebug() << "Failed to create directory:" << flsDirectory;
        } else {
            qDebug() << "Directory created:" << flsDirectory;
        }
    }
    return flsDirectory;
}

bool FileManager::removePath(const QString &path)
{
//    return true;
    qDebug() << "Trying to remove path:" << path;
    QFileInfo fileInfo(path);
    if (fileInfo.exists()) {
        if (fileInfo.isDir()) {
            // 删除目录及其内容
            QDir dir(path);
            bool success = dir.removeRecursively();
            if (!success) {
                qDebug() << "Failed to remove directory";
            }
            return success;
        } else {
            // 删除文件
            QFile file(path);
            bool success = file.remove();
            if (!success) {
                qDebug() << "Failed to remove file:" << file.errorString();
            }
            return success;
        }
    }
    // 路径不存在，返回 false
    qDebug() << "Path does not exist:" << path;
    return false;
}

bool FileManager::isFileExist(const QString &path)
{
    QFileInfo fileInfo(path);
    return fileInfo.exists();
}

QString FileManager::getZipFilePath(const QString &path)
{
    QFileInfo fileInfo(path);

    if (fileInfo.exists() && fileInfo.isDir()) {
        QDir dir(path);

        QStringList filters;
        filters << "*.zip";
        dir.setNameFilters(filters);

        QFileInfoList fileList = dir.entryInfoList();

        return fileList[0].absoluteFilePath();
    }

    return "";
}

QStringList FileManager::getFilesInDirectory(const QString &dirPath, const QStringList &filters)
{
    QDir dir(dirPath);
    if (!dir.exists()) {
        qWarning() << "Directory does not exist:" << dirPath;
        return QStringList();
    }

    // 如果提供了过滤器，则只返回匹配的文件
    QStringList fileList = dir.entryList(filters, QDir::Files | QDir::NoSymLinks | QDir::NoDotAndDotDot);

    // 如果没有提供过滤器，则获取目录下所有文件
    if (filters.isEmpty()) {
        fileList = dir.entryList(QDir::Files | QDir::NoSymLinks | QDir::NoDotAndDotDot);
    }

    // 如果需要完整的文件路径，可以遍历 fileList 并拼接
    QStringList fullPathList;
    for (const QString &fileName : fileList) {
        fullPathList << dir.filePath(fileName);
    }

    // 返回文件列表（或完整路径列表）
    return fullPathList.isEmpty() ? fileList : fullPathList;
}

bool FileManager::createEmptyFile(const QString &fileName) {
    QString appDirPath = "D:";
    QString PLYFilePath = appDirPath+"/"+PLYDIRECTORY+"/"+QString::number(Util::getTimestampMilliseconds())+"/"+Util::generateUuid();
    QString PLYDirectory = QDir(PLYFilePath).filePath(QString());

    QDir dir;
    if (!dir.exists(PLYDirectory)) {
        if (!dir.mkpath (PLYDirectory)) {
            qDebug() << "Failed to create directory:" << PLYDirectory;
        } else {
            qDebug() << "Directory created:" << PLYDirectory;
        }
    }

    QString filePath = dir.filePath(fileName);
    QFile file(filePath);
    if (!file.exists()) {
        if (!file.open(QIODevice::WriteOnly)) {
            return false;
        }
        file.close();
    }
    return true;
}