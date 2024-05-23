import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12

Popup{
   width: parent.width
   height: parent.height
   modal: true
   focus: true
   closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
   background: Rectangle{
       radius: 25
       color: "transparent"
   }
    Rectangle{
       color: "cyan"
       radius: 25
       width: 300
       implicitHeight: text_name.height
        anchors.centerIn: parent
       Text {
           id: text_name
           width: parent.width
           height: 100
           text: qsTr("text")
           verticalAlignment: Text.AlignVCenter
           horizontalAlignment: Text.AlignHCenter
           anchors.centerIn: parent.Center
       }
   }
}
