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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    visible: getanddostuff.isFreeImageSupportEnabled()

    Row {

        spacing: 20

        EntryTitle {

            id: titletext
            title: "FreeImage image library"
            helptext: em.pty+qsTr("FreeImage is an open source image library supporting a number of image formats, many of which have been successfully tested in PhotoQt.") +
                      "<br><br>" +
                      em.pty+qsTr("Use left click to check/uncheck an individual entry, and right click to check/uncheck all endings related to the same image type.")
            imageSource: "qrc:/img/settings/imageformats/freeimage.jpg"
            fontcolor: enabled ? colour.text : colour.text_disabled

        }

        EntrySetting {

            Column {

                spacing: 10

                Item {

                    width: childrenRect.width
                    height: but1.height

                    Row {

                        spacing: 10

                        SettingsText {
                            id: txt1
                            y: (but1.height-height)/2
                            horizontalAlignment: Text.AlignRight
                            text: em.pty+qsTr("File endings:")
                        }
                        CustomButton {
                            id: but1
                            text: em.pty+qsTr("Use default")
                            onClickedButton: formatsPopupEndings.setDefault()
                        }
                        CustomButton {
                            //: Used as in 'Use none of the available file endings'
                            text: em.pty+qsTr("Use none")
                            onClickedButton: formatsPopupEndings.setNone()
                        }
                        CustomButton {
                            //: 'fine tuning' refers to selecting the individual file endings recognised by PhotoQt
                            text: em.pty+qsTr("Advanced fine tuning")
                            onClickedButton: formatsPopupEndings.show()
                        }

                        SettingsText {
                            y: (but1.height-height)/2
                            text: em.pty+qsTr("There are currently %1 file endings selected").arg("<b>"+formatsPopupEndings.numItemsChecked+"</b>")
                        }

                    }

                }

                Item {

                    width: childrenRect.width
                    height: but2.height

                    Row {

                        spacing: 10

                        SettingsText {
                            id: txt2
                            y: (but1.height-height)/2
                            horizontalAlignment: Text.AlignRight
                            text: em.pty+qsTr("Mime types:")
                        }
                        CustomButton {
                            id: but2
                            //: Used as in 'Use set of default file endings'
                            text: em.pty+qsTr("Use default")
                            onClickedButton: formatsPopupMimetypes.setDefault()
                        }
                        CustomButton {
                            //: Used as in 'Use none of the available file endings'
                            text: em.pty+qsTr("Use none")
                            onClickedButton: formatsPopupMimetypes.setNone()
                        }
                        CustomButton {
                            //: 'fine tuning' refers to selecting the individual file endings recognised by PhotoQt
                            text: em.pty+qsTr("Advanced fine tuning")
                            onClickedButton: formatsPopupMimetypes.show()
                        }

                        SettingsText {
                            y: (but2.height-height)/2
                            text: em.pty+qsTr("There are currently %1 mime types selected").arg("<b>"+formatsPopupMimetypes.numItemsChecked+"</b>")
                        }

                    }

                }

                Component.onCompleted: {
                    but1.width = Math.max(but1.width, but2.width)
                    but2.width = Math.max(but1.width, but2.width)
                    txt1.width = Math.max(txt1.width, txt2.width)
                    txt2.width = Math.max(txt1.width, txt2.width)
                }

            }

        }

    }

    PopupImageFormats {

        id: formatsPopupEndings
        title: titletext.title
        availableFormats: imageformats.getAvailableEndingsWithDescriptionFreeImage()
        enabledFormats: imageformats.enabledFileformatsFreeImage
        defaultFormats: imageformats.getDefaultEnabledEndingsFreeImage()

        Connections {
            target: imageformats
            onEnabledFileformatsChanged:
                formatsPopupEndings.enabledFormats = imageformats.enabledFileformatsFreeImage
        }

        onVisibleChanged: settings_top.imageFormatsAdvancedTuningPopupVisible = visible

    }

    PopupMimeTypes {

        id: formatsPopupMimetypes
        title: titletext.title
        availableFormats: mimetypes.getAvailableMimeTypesWithDescriptionFreeImage()
        enabledFormats: mimetypes.enabledMimeTypesFreeImage
        defaultFormats: mimetypes.getDefaultEnabledMimeTypesFreeImage()

        Connections {
            target: mimetypes
            onEnabledMimeTypesChanged:
                formatsPopupMimetypes.enabledFormats = mimetypes.enabledMimeTypesFreeImage
        }

        onVisibleChanged: settings_top.imageFormatsAdvancedTuningPopupVisible = visible

    }

    function setData() {
        formatsPopupEndings.setCurrentlySet()
        formatsPopupEndings.setCurrentlySet()
    }

    function saveData() {
        imageformats.enabledFileformatsFreeImage = formatsPopupEndings.getEnabledFormats()
        mimetypes.enabledMimeTypesFreeImage = formatsPopupMimetypes.getEnabledFormats()
    }

}
