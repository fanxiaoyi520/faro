import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import "../../Util/GlobalFunc.js" as GlobalFunc

Popup{
    id: popup
    property var imgUrl
    width: parent.width
    height: parent.height
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    background: Rectangle{
        anchors.fill: parent
        color: "#000000"
        Image{
            id: imageViewer
            anchors.top: parent.top
            source: imgUrl ? imgUrl : ""
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            scale: 1.0
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
        MouseArea{
            anchors.fill: parent
            onClicked: {
                popup.close()
            }
            onDoubleClicked: {
                contentItem.scale += 0.1;
                console.log("Double clicked!")
            }
        }

        PinchArea {
            anchors.fill: parent
            pinch.target: imageViewer
            onPinchUpdated: {
                imageViewer.scale *= pinch.scale
                pinch.scale = 1.0
            }
        }
    }
    padding: 0
}
