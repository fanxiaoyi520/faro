import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import "../../Util/GlobalFunc.js" as GlobalFunc

Rectangle{
    property var model
    property var imgUrl

    id: headerRect
    width: parent.width
    height: imageBackHeight+90
    Rectangle{
        id: imageBackView
        width: imageBackWidth
        height: imageBackHeight
        y: 20
        x: (parent.width - imageBackWidth)/2
        Image{            id: imageViewer
            anchors.top: parent.top
            source: imgUrl
            asynchronous: true;
            fillMode: Image.PreserveAspectFit;
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            onStatusChanged: {
                if(status === Image.Loading){
                    console.log("LOADING......")
                    hub.open()
                }else if(status === Image.Ready){
                    console.log("READY......")
                    hub.close()
                    listView.contentY = -imageBackHeight-90
                }else if(status === Image.Error){
                    console.log("ERROR......")
                    hub.close()
                }
            }
        }
    }
    Image{
        id: enlargeImage
        source: "../../images/home_page_slices/home_enlarge@2x.png"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 64
        anchors.right: parent.right
        width: 74.5;height: 74.5
        MouseArea{
            anchors.fill: parent
            onClicked: enlargeImageAction(imgUrl)
        }
    }
    Rectangle{
        anchors.top: imageBackView.bottom
        anchors.topMargin: 13
        anchors.left: parent.left
        anchors.right: parent.right
        height: 57
        radius: 20
        color: "#FFFFFF"
        layer.enabled: true
        layer.effect: DropShadow{
            horizontalOffset: 0
            verticalOffset: -2.5
            radius: 20
            color: "#1A1890FF"
        }
        Text{
            id:sectionText
            text: qsTr("测站信息")
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.weight: Font.Bold
            color: "#000000"
            font.pixelSize: 18
        }
        Rectangle{
            id: rotundity
            anchors.verticalCenter: parent.verticalCenter
            width: 7;height: 7
            anchors.left: sectionText.right
            anchors.leftMargin: 13
            radius: 3.5
            color: "#FFEAD3"
        }
        Text{
            id:sectionSubText
            text: qsTr("测站带原位标记")
            anchors.left: rotundity.right
            anchors.leftMargin: 1
            anchors.verticalCenter: parent.verticalCenter
            font.weight: Font.Normal
            color: "#999999"
            font.pixelSize: 12
        }
    }
}
