import QtQuick 2.4
import QtQuick.Controls 2.5
import Modules 1.0
import QtQuick.Layouts 1.12
import Http 1.0
import Api 1.0
import Dialog 1.0
import "../../String_Zh_Cn.js" as String

Column{
    id:root
    width: parent.width
    spacing: 16
    property var user_id : -1
    property var userinfo : null
    BaseNavigationBar{
        Layout.fillWidth: true
        title: qsTr(String.userinfo_title)
        isVisibleBackBtn: true
        onBackAction: {
            mineStack.pop()
        }
    }
    Http{id:http}
    TipsPopUp{
        id:tipspop
        property var isChangePassSuccess: false
        onClosed: {
            if(isChangePassSuccess){
                myConfirmAction()
            }
        }

        function myConfirmAction(){
            while (mineStack.depth > 1) {
                mineStack.pop();
            }
            rootWindow.toggleView()
            settingsManager.setValue(settingsManager.user,null)
        }
    }

    ChangepassPop{
        id:passPop
    }

    Rectangle{
        id:rect_name
        width:root.width
        height: 32
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 32
            id: username_title
            text: qsTr(String.userinfo_username)
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 32
            id: username
            color: "#999999"
            text: qsTr((userinfo === null) ? "" : ((userinfo.name === null) ? "" : userinfo.name))
        }
        Rectangle{
            width: parent.width
            height: 1
            color: "#efefef"
            anchors.top: username_title.bottom
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
        }
    }
    Rectangle{
        id:rect_phone
        width:root.width
        height: 32
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 32
            id: phone_title
            text: qsTr(String.userinfo_phone)
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 32
            id: phone
            color: "#999999"
            text: qsTr((userinfo === null) ? "" : ((userinfo.phone === null) ? "" : userinfo.phone))
        }
        Rectangle{
            width: parent.width
            height: 1
            color: "#efefef"
            anchors.top: phone_title.bottom
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
        }
    }

    Rectangle{
        id:rect_email
        width:root.width
        height: 32
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 32
            id: email_title
            text: qsTr(String.userinfo_email)
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 32
            id: email
            color: "#999999"
            text: qsTr((userinfo === null) ? "" : ((userinfo.email === null) ? "" : userinfo.email))
        }
        Rectangle{
            width: parent.width
            height: 1
            color: "#efefef"
            anchors.top: email_title.bottom
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
        }
    }

    Rectangle{
        id:rect_pass
        width:root.width
        height: 32
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 32
            id: pass_title
            text: qsTr(String.userinfo_pass)
        }

        Text {
            id:text_update
            anchors.right: parent.right
            anchors.rightMargin: 32
            color: "#1890FF"
            text: qsTr(String.userinfo_update)
        }

        Rectangle{
            width: parent.width
            height: 1
            color: "#efefef"
            anchors.top: pass_title.bottom
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 16
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                passPop.open()
            }
        }
    }

    onUser_idChanged: {
        loadUserInfo()
    }

    function loadUserInfo(){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
            console.log("userinfo reply: "+reply)
            var response = JSON.parse(reply)
            root.userinfo = response.data
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.onReplySucSignal.disconnect(onReply)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }
        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.get(Api.admin_user_details + "/" + root.user_id)
    }
}
