#include "filemanager.h"

FileManager::FileManager(QObject *parent) : QObject(parent)
{

}

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
        QString saveFilePath = savePath + "/" + zipRootFolder + ".zip";

        QZipWriter writer(saveFilePath);
        writer.addDirectory(zipRootFolder);
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
        return false;
    }
    if (!QFileInfo(selectZipFilePath).isFile() || !QFileInfo(savePath).isDir())
    {
        return false;
    }

    bool ret = true;
    QZipReader zipReader(selectZipFilePath);
    QVector<QZipReader::FileInfo> zipAllFiles = zipReader.fileInfoList();
    for (const QZipReader::FileInfo& zipFileInfo : zipAllFiles)
    {
        const QString currDir2File = savePath + "/" + zipFileInfo.filePath;
        if (zipFileInfo.isSymLink)
        {
            QString destination = QFile::decodeName(zipReader.fileData(zipFileInfo.filePath));
            if (destination.isEmpty())
            {
                ret = false;
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
            QDir(savePath).mkpath(currDir2File);
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
