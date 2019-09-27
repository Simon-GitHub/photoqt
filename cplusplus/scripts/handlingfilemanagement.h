#ifndef PQHANDLINGFILEMANAGEMENT_H
#define PQHANDLINGFILEMANAGEMENT_H

#include <QObject>
#include <QFile>
#include <QUrl>
#include <QStorageInfo>
#include <unistd.h>

#include "../logger.h"

class PQHandlingFileManagement : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE bool renameFile(QString dir, QString oldName, QString newName);
    Q_INVOKABLE bool deleteFile(QString filename, bool permanent);
};

#endif // PQHANDLINGFILEMANAGEMENT_H