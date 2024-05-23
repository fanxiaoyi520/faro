import QtQuick 2.0
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import Http 1.0
import Api 1.0
import Dialog 1.0
import "../String_Zh_Cn.js" as String

Popup {
    id:popRoot
    width: parent.width
    focus: true
    modal: true
    clip: true
    y:parent.height - popRoot.height
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    background: Rectangle{
        radius: 25
        color: "#FFFFFF"
        Rectangle {
            id: coverRect
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 25
            color: "#FFFFFF"
            border.color: "transparent"
        }
    }

    contentItem: ColumnLayout {
        Rectangle{
            Layout.fillWidth: true
            height: text_title.height
            Text {
                id: text_title
                text: qsTr(String.passchange_pop_title)
                font.pixelSize: 18
                color: "#2c2c2c"
                font.bold: true
                anchors.centerIn: parent
            }
            Image {
                source: "../images/ic_cross_x.png"
                anchors.right: parent.right
                anchors.rightMargin: 16
                width: 16
                height: 16
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        resetPopState()
                        popRoot.close()
                    }
                }
            }

        }
        Rectangle{
            Layout.fillWidth: true
            height: 4
        }

        Rectangle{
            Layout.fillWidth: true
            height: 48
            Text {
                id:text_origin_pass
                width: 48
                text: qsTr(String.passchange_origin_pass)
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            TextField{
                id:textfield_origin_pass
                anchors{
                    right: parent.right
                    left: text_origin_pass.right
                    leftMargin: 16
                    rightMargin: 16
                    verticalCenter: parent.verticalCenter
                }
                Image {
                    source: "../images/login_close.png"
                    anchors.right: textfield_origin_pass.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 16
                    visible: textfield_origin_pass.text != ""
                    width: 16
                    height: 16
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            textfield_origin_pass.text = ""
                        }
                    }
                }
                echoMode: TextInput.Password
                placeholderText: qsTr(String.passchange_origin_pass_hint)
                placeholderTextColor: "#999999"
                color: "#3C3C3C"
                topPadding: 8
                bottomPadding: 8
                focus: false
                background: Rectangle {
                    anchors.fill: parent
                     color: "#FFFFFF"
                    radius: 5
                }
            }
            Rectangle{
                width: parent.width
                height: 1
                color: "#efefef"
                anchors.top: text_origin_pass.bottom
                anchors.topMargin: 16
            }
        }

        Rectangle{
            Layout.fillWidth: true
            height: 48
            Text {
                id:text_newpass
                width: 48
                text: qsTr(String.passchange_newpass)
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            TextField{
                id:textfield_newpass
                anchors{
                    right: parent.right
                    left: text_newpass.right
                    leftMargin: 16
                    rightMargin: 16
                    verticalCenter: parent.verticalCenter
                }
                Image {
                    source: "../images/login_close.png"
                    anchors.right: textfield_newpass.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 16
                    visible: textfield_newpass.text != ""
                    width: 16
                    height: 16
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            textfield_newpass.text = ""
                        }
                    }
                }
                 echoMode: TextInput.Password
                placeholderText: qsTr(String.passchange_newpass_hint)
                placeholderTextColor: "#999999"
                color: "#3C3C3C"
                focus: false
                topPadding: 8
                bottomPadding: 8
                background: Rectangle {
                    anchors.fill: parent
                    color: "#FFFFFF"
                    radius: 5
                }
            }
            Rectangle{
                width: parent.width
                height: 1
                color: "#efefef"
                anchors.top: text_newpass.bottom
                anchors.topMargin: 16
            }
        }

        Rectangle{
            Layout.fillWidth: true
            height: 48
            Text {
                id:text_confirm_pass
                width: 48
                text: qsTr(String.passchange_confirm_pass)
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            TextField{
                id:textfield_confirm_pass
                anchors{
                    right: parent.right
                    left: text_confirm_pass.right
                    leftMargin: 16
                    rightMargin: 16
                    verticalCenter: parent.verticalCenter
                }
                Image {
                    source: "../images/login_close.png"
                    anchors.right: textfield_confirm_pass.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 16
                    visible: textfield_confirm_pass.text != ""
                    width: 16
                    height: 16
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            textfield_confirm_pass.text = ""
                        }
                    }
                }
                echoMode: TextInput.Password
                topPadding: 8
                bottomPadding: 8
                placeholderText: qsTr(String.passchange_confirm_pass_hint)
                placeholderTextColor: "#999999"
                color: "#3C3C3C"
                focus: false
                background: Rectangle {
                    anchors.fill: parent
                    color: "#FFFFFF"
                    radius: 5
                }
            }
        }
        Rectangle{
            Layout.fillWidth: true
            height: 1
        }

        Item {
            id: buttonsContainer
            Layout.fillWidth: true
            height: 48

            Button{
                id: cancelbtn
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 7
                anchors.left: parent.left
                anchors.leftMargin: 60
                width: (parent.width-60*2-24)/2
                height: 41
                text: qsTr("取消")
                font.pixelSize: 16
                font.bold: true
                highlighted: true
                background: Rectangle{
                    id: cancelbtnrect
                    color: "#F5F5F7"
                    radius: 20.5
                }
                contentItem: Text {
                    text: cancelbtn.text
                    color: "#333333"
                    anchors.centerIn: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.MixedCase
                    font.pixelSize: 16
                    font.bold: true
                }
                onClicked: cancelAction()
            }

            Button{
                id: surebtn
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 7
                anchors.right: parent.right
                anchors.rightMargin: 60
                width: (parent.width-60*2-24)/2
                height: 41
                text: qsTr("确定")
                highlighted: true
                font.pixelSize: 16
                font.bold: true
                background: Rectangle{
                    id: surebtnrect
                    color: "#1890FF"
                    radius: 20.5
                }
                contentItem: Text {
                    text: surebtn.text
                    color: "#FFFFFF"
                    anchors.centerIn: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.capitalization: Font.MixedCase
                    font.pixelSize: 16
                    font.bold: true
                }
                onClicked: sureAction()
            }
        }
        Rectangle{
            Layout.fillWidth: true
            height: 16
        }
    }
    height: contentItem.implicitHeight

    function cancelAction(){
        console.log("cancel action click")
        resetPopState()
        popRoot.close()
    }

    function sureAction(){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            hub.close()
            console.log("changepass reply: "+reply)
               var response = JSON.parse(reply)
            if(response !== null && response.code === 1){
                tipspop.tipsContentStr = response.msg
                tipspop.isVisibleCancel = false
                tipspop.open()
            }else{
                tipspop.tipsContentStr = qsTr(String.passchange_update_success)
                tipspop.isVisibleCancel = false
                tipspop.isChangePassSuccess = true
                resetPopState()
                popRoot.close()
                tipspop.open()
            }
        }

        function onFail(reply,code){
            console.log(reply,code)
            var response = JSON.parse(reply)
            tipspop.tipsContentStr = response.msg
            tipspop.isVisibleCancel = false
            tipspop.open()
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        if(checkEmpty()){
            hub.open()
            http.onReplySucSignal.connect(onReply)
            http.replyFailSignal.connect(onFail)
            http.put(Api.admin_user_password, {"newpassword1":textfield_confirm_pass.text.toString(),"password":textfield_origin_pass.text.toString()})
        }
    }

    function resetPopState(){
        textfield_origin_pass.clear()
        textfield_newpass.clear()
        textfield_confirm_pass.clear()
        textfield_origin_pass.focus = false
        textfield_newpass.focus = false
        textfield_confirm_pass.focus = false
    }

    function checkEmpty() {
        function showError(message) {
            tipspop.tipsContentStr = message
            tipspop.isVisibleCancel = false
            tipspop.open()
            return false
        }

        if (textfield_origin_pass.text === "") {
            return showError(String.passchange_origin_pass_empty)
        }

        if (textfield_newpass.text === "") {
            return showError(String.passchange_newpass_empty)
        }

        if (textfield_confirm_pass.text === "" || textfield_confirm_pass.text !== textfield_newpass.text) {
            return showError(String.passchange_confirm_pass_empty)
        }

        return true
    }
}
