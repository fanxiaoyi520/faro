import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import Lottie 1.0
import "../../String_Zh_Cn.js" as String

Popup {
    id:popup_wifi
    property int lottieType: 0
    property var tipsconnect: String.starting_connection_to_machine
    property var title: String.scan_station_id
    property bool isVisibleCancle: false

    signal cancleBlock()
    modal: true
    width: parent.width
    height: parent.height
    background: Rectangle{
        anchors.fill: parent
        color: "#CCefefef"
    }
    Timer {
        id: timer
        interval: 24 * 60 * 60 * 1000 //超时时间
        repeat: false

        onTriggered: popup_wifi.close()
    }

    Rectangle{
        id:rect_content
        anchors.centerIn: parent
        width: parent.width / 2.5
        height: parent.width / 2.5
        color: "#FFFFFF"
        radius: 12

        Text {
            id: text_title
            text: qsTr(title)
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 16
            font.bold: true
            color: "#333333"
        }

        Text {
            id: cancelBtn
            text: qsTr(String.cancel)
            anchors.verticalCenter: text_title.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 16
            font.pixelSize: 16
            font.bold: true
            color: "#1890FF"
            visible: isVisibleCancle
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    cancleBlock()
                }
            }
        }

        Rectangle{
            id:rect_dive
            width: parent.width
            height: 1
            color: "#efefef"
            anchors{
                top: text_title.bottom
                topMargin: 8
            }
        }

        LottieAnimation{
            anchors{
                top: rect_dive.bottom
                topMargin: 8
                bottom: text_tips.top
                leftMargin: 16
                rightMargin: 16
                bottomMargin: 8
            }
            anchors.horizontalCenter: parent.horizontalCenter
            id:lottieScaning
            width:  parent.width
            height: parent.height - text_title.height - text_tips.height - 57
            loops: Animation.Infinite
            fillMode: Image.PreserveAspectFit
            source: getCurrentLottieType(lottieType)
            running: true
        }

        Text {
            id: text_tips
            text: qsTr(tipsconnect)
            anchors{
                bottom: parent.bottom
                bottomMargin: 16
            }
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#333333"
        }

    }

    onOpened: {
        console.log("open......")
        timer.start()

        lottieScaning.source = getCurrentLottieType(lottieType)
        lottieScaning.start()
    }

    onClosed: {
        console.log("close......")
        lottieScaning.stop()
        timer.stop()
    }

    function getCurrentLottieType(lottieType){
        if (lottieType === 0) return Qt.resolvedUrl("../../images/json/wating.json")
        if (lottieType === 1) return Qt.resolvedUrl("../../images/json/upload_file.json")
        if (lottieType === 2) return Qt.resolvedUrl("../../images/json/scaning.json")
        return Qt.resolvedUrl("../../images/json/wating.json")
    }
}
