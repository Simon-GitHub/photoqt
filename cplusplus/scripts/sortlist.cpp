#include "sortlist.h"

void Sort::list(QFileInfoList *list, QString sortby, bool sortbyAscending) {

    QCollator collator;
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);

    if(sortby == "name") {

        collator.setNumericMode(false);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(file1.fileName(),
                                        file2.fileName()) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(file2.fileName(),
                                        file1.fileName()) < 0;
            });

    } else if(sortby == "date") {

        collator.setNumericMode(true);

#if (QT_VERSION >= QT_VERSION_CHECK(5, 10, 0))

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.metadataChangeTime().toMSecsSinceEpoch()),
                                        QString::number(file2.metadataChangeTime().toMSecsSinceEpoch())) < 0;
            });
        else
            std::sort(list->rbegin(), list->rend(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.metadataChangeTime().toMSecsSinceEpoch()),
                                        QString::number(file2.metadataChangeTime().toMSecsSinceEpoch())) < 0;
            });

#else // Qt < 5.10

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.created().toMSecsSinceEpoch()),
                                        QString::number(file2.created().toMSecsSinceEpoch())) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file2.created().toMSecsSinceEpoch()),
                                        QString::number(file1.created().toMSecsSinceEpoch())) < 0;
            });

#endif // (QT_VERSION >= QT_VERSION_CHECK(5, 10, 0))

    } else if(sortby == "size") {

        collator.setNumericMode(true);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file1.size()),
                                        QString::number(file2.size())) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(QString::number(file2.size()),
                                        QString::number(file1.size())) < 0;
            });

    } else { // default to naturalname

        collator.setNumericMode(true);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(file1.fileName(),
                                        file2.fileName()) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) {
                return collator.compare(file2.fileName(),
                                        file1.fileName()) < 0;
            });

    }

}

void Sort::list(QVariantList *list, QString sortby, bool sortbyAscending) {

    QCollator collator;
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    collator.setIgnorePunctuation(true);

    if(sortby == "name") {

        collator.setNumericMode(false);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(file1.toString(),
                                        file2.toString()) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(file2.toString(),
                                        file1.toString()) < 0;
            });

    } else if(sortby == "date") {

        collator.setNumericMode(true);

#if (QT_VERSION >= QT_VERSION_CHECK(5, 10, 0))

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file1.toString()).metadataChangeTime().toMSecsSinceEpoch()),
                                        QString::number(QFileInfo(file2.toString()).metadataChangeTime().toMSecsSinceEpoch())) < 0;
            });
        else
            std::sort(list->rbegin(), list->rend(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file1.toString()).metadataChangeTime().toMSecsSinceEpoch()),
                                        QString::number(QFileInfo(file2.toString()).metadataChangeTime().toMSecsSinceEpoch())) < 0;
            });

#else // Qt < 5.10

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file1.toString()).created().toMSecsSinceEpoch()),
                                        QString::number(QFileInfo(file2.toString()).created().toMSecsSinceEpoch())) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file2.toString()).created().toMSecsSinceEpoch()),
                                        QString::number(QFileInfo(file1.toString()).created().toMSecsSinceEpoch())) < 0;
            });

#endif // (QT_VERSION >= QT_VERSION_CHECK(5, 10, 0))

    } else if(sortby == "size") {

        collator.setNumericMode(true);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file1.toString()).size()),
                                        QString::number(QFileInfo(file2.toString()).size())) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(QString::number(QFileInfo(file2.toString()).size()),
                                        QString::number(QFileInfo(file1.toString()).size())) < 0;
            });

    } else { // default to naturalname

        collator.setNumericMode(true);

        if(sortbyAscending)
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(file1.toString(),
                                        file2.toString()) < 0;
            });
        else
            std::sort(list->begin(), list->end(), [&collator](const QVariant &file1, const QVariant &file2) {
                return collator.compare(file2.toString(),
                                        file1.toString()) < 0;
            });

    }

}