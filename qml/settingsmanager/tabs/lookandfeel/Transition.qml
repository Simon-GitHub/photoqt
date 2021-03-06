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

import "../../../elements"
import "../../"

Entry {

    //: The transition refers to images fading into one another when switching between them
    title: em.pty+qsTr("Smooth Transition")
    helptext: em.pty+qsTr("Switching between images can be done smoothly, the new image can be set to fade into the old image.\
 'No transition' means, that the previous image is simply replaced instantly by the new image.")

    content: [

        Row {

            spacing: 10

            Text {
                id: txt_no
                color: colour.text
                //: No transition means that images are simply replaced when switching between them, no cross-fading
                text: em.pty+qsTr("No Transition")
                font.pointSize: 10
            }

            CustomSlider {

                id: transition

                width: Math.min(200, Math.max(200, parent.width-txt_no.width-txt_long.width-50))
                height: txt_long.height

                minimumValue: 0
                maximumValue: 15

                stepSize: 1
                scrollStep: 1

            }

            Text {
                id: txt_long
                color: colour.text
                //: A very long transition between images, they slowly fade into each other
                text: em.pty+qsTr("Long Transition")
                font.pointSize: 10
            }

        }

    ]

    function setData() {
        transition.value = settings.imageTransition
    }

    function saveData() {
        settings.imageTransition = transition.value
    }

}
