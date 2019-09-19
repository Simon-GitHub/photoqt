#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtDebug>

#include "variables.h"
#include "startup.h"
#include "startup/exportimport.h"
#include "settings/settings.h"
#include "scripts/handlingfiledialog.h"
#include "scripts/handlinggeneral.h"
#include "scripts/handlingshortcuts.h"
#include "scripts/localisation.h"
#include "scripts/imageproperties.h"
#include "settings/imageformats.h"
#include "scripts/filewatcher.h"
#include "scripts/filefoldermodel.h"
#include "singleinstance/singleinstance.h"
#include "settings/windowgeometry.h"
#include "scripts/metadata.h"

#include "imageprovider/imageprovidericon.h"
#include "imageprovider/imageproviderthumb.h"
#include "imageprovider/imageproviderfull.h"
#include "imageprovider/imageproviderhistogram.h"

#ifdef GM
#include <GraphicsMagick/Magick++.h>
#endif

#ifdef DEVIL
#include <IL/il.h>
#endif

int main(int argc, char **argv) {

    // this forces the default style as some themes (e.g., from plasma) mess with some customizations (bug reported to KDE)
    QApplication::setDesktopSettingsAware(false);

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    PQSingleInstance app(argc, argv);

    // We store this as a QString, as this way we don't have to explicitely cast VERSION to a QString below
    QString version = VERSION;

    // Set app name and version
    QGuiApplication::setApplicationName("PhotoQt");
    QGuiApplication::setOrganizationName("");
    QGuiApplication::setOrganizationDomain("photoqt.org");
    QGuiApplication::setApplicationVersion(version);

    if(app.exportAndQuit != "") {
        PQStartup::Export::perform(app.exportAndQuit);
        std::exit(0);
    } else if(app.importAndQuit != "") {
        PQStartup::Import::perform(app.importAndQuit);
        std::exit(0);
    }

#ifdef GM
    // Initialise Magick as early as possible
    Magick::InitializeMagick(*argv);
#endif

#ifdef DEVIL
    ilInit();
#endif

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/mainwindow.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    PQStartup::PQStartup();

    qmlRegisterType<PQHandlingFileDialog>("PQHandlingFileDialog", 1, 0, "PQHandlingFileDialog");
    qmlRegisterType<PQHandlingGeneral>("PQHandlingGeneral", 1, 0, "PQHandlingGeneral");
    qmlRegisterType<PQHandlingShortcuts>("PQHandlingShortcuts", 1, 0, "PQHandlingShortcuts");
    qmlRegisterType<PQLocalisation>("PQLocalisation", 1, 0, "PQLocalisation");
    qmlRegisterType<PQImageProperties>("PQImageProperties", 1, 0, "PQImageProperties");
    qmlRegisterType<PQFileWatcher>("PQFileWatcher", 1, 0, "PQFileWatcher");
    qmlRegisterType<PQWindowGeometry>("PQWindowGeometry", 1, 0, "PQWindowGeometry");
    qmlRegisterType<PQMetaData>("PQCppMetaData", 1, 0, "PQCppMetaData");

    engine.rootContext()->setContextProperty("PQSettings", &PQSettings::get());
    engine.rootContext()->setContextProperty("PQCppVariables", &PQVariables::get());
    engine.rootContext()->setContextProperty("PQImageFormats", &PQImageFormats::get());

    qmlRegisterType<PQFileFolderModel>("PQFileFolderModel", 1, 0, "PQFileFolderModel");

    engine.addImageProvider("icon",new PQImageProviderIcon);
    engine.addImageProvider("thumb",new PQAsyncImageProviderThumb);
    engine.addImageProvider("full",new PQImageProviderFull);
    engine.addImageProvider("hist",new PQImageProviderHistogram);

    engine.load(url);

    return app.exec();
}
