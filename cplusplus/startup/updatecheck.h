/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
 ** Contact: http://photoqt.org                                          **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

#ifndef STARTUPCHECK_STARTUPUPDATECHECK_H
#define STARTUPCHECK_STARTUPUPDATECHECK_H

#include <QString>
#include <QFile>
#include <QTextStream>
#include "../logger.h"
#include "../settings/settings.h"

namespace StartupCheck {

    namespace UpdateCheck {

        // 0 = nothing, 1 = update, 2 = install
        static int checkForUpdateInstall(Settings *settings) {

            bool debug = (qgetenv("PHOTOQT_DEBUG") == "yes");

            if(debug) LOG << CURDATE << "StartupCheck::UpdateCheck" << NL;

            if(settings->getVersionInTextFile() == "") {
                if(debug) LOG << CURDATE << "PhotoQt newly installed!" << NL;
                settings->setVersion(VERSION);
                return 2;
            }

            if(debug) LOG << CURDATE << "Checking if first run of new version" << NL;

            // If it doesn't contain current version (some previous version)
            if(settings->getVersion() != settings->getVersionInTextFile()) {

                if(debug) LOG << CURDATE << "PhotoQt updated" << NL;

                settings->setVersion(VERSION);

                return 1;

            }

            return 0;

        }

    }

}

#endif // STARTUPCHECK_STARTUPUPDATECHECK_H
