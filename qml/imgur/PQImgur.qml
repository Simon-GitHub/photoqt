import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

import "../elements"
import "../loadfiles.js" as LoadFile

Rectangle {

    id: imgur_top

    color: "#dd000000"

    width: parentWidth
    height: parentHeight

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.animationDuration*100 } }
    visible: opacity!=0

    property bool anonymous: false
    property string accountname: ""

    PQMouseArea {
        anchors.fill: parent
        hoverEnabled: true
        enabled: !PQSettings.imgurPopoutElement
        onClicked:
            abortUpload()
    }

    Item {

        id: insidecont

        x: ((parent.width-width)/2)
        y: ((parent.height-height)/2)
        width: parent.width
        height: childrenRect.height

        clip: true

        PQMouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        Column {

            spacing: 10

            Text {
                x: (insidecont.width-width)/2
                color: "white"
                font.pointSize: 20
                font.bold: true
                visible: !report.visible
                text: "Upload to imgur.com"
            }

            Text {
                x: (insidecont.width-width)/2
                color: "white"
                font.pointSize: 15
                font.bold: true
                font.italic: true
                visible: !report.visible
                text: anonymous ? "anonymously" : accountname
            }

            Item {
                width: 1
                height: 10
            }

            Item {

                width: childrenRect.width
                height: childrenRect.height
                x: (insidecont.width-width)/2

                PQProgress {

                    id: progress
                    anchors.centerIn: report

                    visible: !report.visible && !error.visible && !nointernet.visible

                    onProgressChanged:
                            opacity = (progress.progress == 100) ? 0 : 1

                }

                Text {
                    anchors.centerIn: report
                    opacity: 1-progress.opacity
                    visible: !report.visible && !error.visible && !nointernet.visible
                    color: "white"
                    font.pointSize: 12
                    text: "Obtaining image url..."
                }

                Text {
                    id: longtime
                    anchors.top: progress.bottom
                    opacity: 1-progress.opacity
                    visible: !report.visible && !error.visible && !nointernet.visible
                    color: "red"
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 12
                    text: "This seems to take a long time...<br>There might be a problem with your internet connection or the imgur.com servers."
                }

                Text {
                    id: error
                    property int code: 0
                    anchors.centerIn: report
                    visible: false
                    color: "red"
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 12
                    text: "An Error occured while uploading image!<br>Error code: " + code
                }

                Text {
                    id: nointernet
                    property int code: 0
                    anchors.centerIn: report
                    visible: false
                    color: "red"
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 12
                    text: "You don't seem to be connected to the internet...<br>Unable to upload!"
                }

                Item {
                    id: report
                    x: (longtime.width-width)/2
                    property string accessurl: "http://imgur.com/........"
                    property string deleteurl: "http://imgur.com/........"
                    visible: true

                    width: childrenRect.width
                    height: childrenRect.height

                    Column {

                        spacing: 10

                        width: childrenRect.width
                        height: childrenRect.height

                        Text {
                            color: "white"
                            text: "Access Image"
                            font.pointSize: 15
                            font.bold: true
                        }

                        Text {
                            color: "white"
                            text: report.accessurl
                            font.pointSize: 15
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                tooltip: "Click to open in browser"
                                onClicked:
                                    Qt.openUrlExternally(parent.text)
                            }
                        }

                        PQButton {
                            text: "Copy to clipboard"
                            onClicked:
                                handlingGeneral.copyTextToClipboard(report.accessurl)
                        }

                        Item {
                            width: 1
                            height: 10
                        }

                        Text {
                            color: "white"
                            text: "Delete Image"
                            font.pointSize: 15
                            font.bold: true
                        }

                        Text {
                            color: "white"
                            text: report.deleteurl
                            font.pointSize: 15
                            PQMouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                tooltip: "Click to open in browser"
                                onClicked:
                                    Qt.openUrlExternally(parent.text)
                            }
                        }

                        PQButton {
                            text: "Copy to clipboard"
                            onClicked:
                                handlingGeneral.copyTextToClipboard(report.deleteurl)
                        }

                    }

                }

            }

            Item {
                width: 1
                height: 10
            }

            PQButton {

                x: (insidecont.width-width)/2
                text: report.visible ? "Close" : "Cancel upload"
                onClicked:
                    abortUpload()
            }

        }

    }

    Connections {
        target: handlingShareImgur
        onImgurUploadProgress: {
            progress.progress = perc*100
            error.visible = false
            report.visible = false
            nointernet.visible = false
        }
        onFinished: {
            error.visible = false
            nointernet.visible = false
            report.visible = true
        }
        onImgurUploadError: {
            error.code = err
            error.visible = true
            report.visible = false
            nointernet.visible = false
        }
        onImgurImageUrl: {
            report.accessurl = url
        }

        onImgurDeleteHash: {
            report.deleteurl = "http://imgur.com/delete/" + url
        }

    }

    Connections {
        target: loader
        onImgurPassOn: {
            if(what == "show" || what == "show_anonym") {

                if(variables.indexOfCurrentImage == -1)
                    return

                anonymous = (what == "show_anonym")
                progress.progress = 0
                longtime.visible = false
                error.visible = false
                nointernet.visible = false
                report.visible = false

                if(!handlingGeneral.checkIfConnectedToInternet())
                    nointernet.visible = true

                handlingShareImgur.authorizeHandlePin("68713a8441")

                opacity = 1
                variables.visibleItem = "imgur"

                if(!anonymous) {
                    var ret = handlingShareImgur.authAccount()
                    if(ret !== 0) {
                        console.log("Imgur authentication failed!!")
                        abortUpload()
                    }
                    accountname = handlingShareImgur.getAccountUsername()
                    handlingShareImgur.upload(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                } else {
                    accountname = ""
                    handlingShareImgur.anonymousUpload(variables.allImageFilesInOrder[variables.indexOfCurrentImage])
                }

            } else if(what == "hide") {
                abortUpload()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    abortUpload()
            }
        }
    }



    Shortcut {
        sequence: "Esc"
        enabled: PQSettings.imgurPopoutElement
        onActivated: abortUpload()
    }

    function abortUpload() {
        handlingShareImgur.abort()
        opacity = 0
        variables.visibleItem = ""
    }

}