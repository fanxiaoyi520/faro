import QtQuick 2.0
import Http 1.0
import Api 1.0
import Dialog 1.0
import WifiHlper 1.0
import "../../String_Zh_Cn.js" as String

Rectangle {
    id:root
    property var showDive: true
    property var settingInfo
    property var iconPath:""
    property var rightText: ""
    property var contentName: ""
    property var refreshContentName: false
    width: parent.width
    height: 39
    color: "white"

    Http{id:http}
    Loader{ id : userInfoLoader}
    WifiHelper{
        id:wifiHelper
        onNetworksResult: {
            scanningwifi_pop.close()
            console.log("get network result  = " + JSON.stringify(list))
            var wifiResultList = [];

            for(let item of list){
                if(item.includes("LLS")){
                    var myObject = {
                        name: item
                    }
                    wifiResultList.push(myObject);
                }
            }
            console.log("get network filter  = " + JSON.stringify(wifiResultList))
            console.log("wifiresultlist size =" + wifiResultList.size)
            console.log("wifiresultlist length =" + wifiResultList.length)
            if(wifiResultList.length > 0){
                wifiResultPop.list = wifiResultList
                wifiResultPop.titleStr = qsTr(String.wifiscan_result_title)
                wifiResultPop.open()
            }else{
                mineTipsPop.tipsContentStr = qsTr(String.wifiscan_result_empty_tips)
                mineTipsPop.open()
            }
        }
    }

    Rectangle{
        id:rect_setting_item
        width: parent.width
        height: 32
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        Image {
            id: img_type_icon
            source: settingInfo.icon_path
            anchors.left: parent.left
            width: 20
            height: 20
             anchors.verticalCenter:parent.verticalCenter
        }
        Text{
            text: settingInfo.icon_name
            anchors.leftMargin: 16
            anchors.left: img_type_icon.right
            anchors.verticalCenter:parent.verticalCenter
        }

        Text{
            text:contentName
            color: "#999999"
            anchors.rightMargin: 16
            anchors.right: img_arrow.left
            anchors.verticalCenter:parent.verticalCenter
        }

        Image {
            id:img_arrow
            source: "../../images/home_page_slices/select_building_arrow.png"
            anchors.right: parent.right
            anchors.rightMargin: 16
             anchors.verticalCenter:parent.verticalCenter
             width: 8
             height: 10
//             visible: index != 2
        }
        Rectangle{
            id : rect_dive
            width: parent.width
            height: 1
            anchors.top: img_type_icon.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 6
            color: "#efefef"
            visible: showDive
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(index == 0){
                    jumpToUserInfo()
                }
                if(index == 3 && visible){
                    scanningwifi_pop.open()
                    wifiHelper.startWork()
                }
                if(index == 1){
                    userInfoLoader.source = "UploadPage.qml"
                    mineStack.push(userInfoLoader)
                }
            }
        }
    }

    onVisibleChanged: {
        if(visible && !loaded){
            refreshContent()
        }
    }

    onRefreshContentNameChanged: {
        refreshContent()
    }

    function refreshContent(){
        if(index == 2){
            loadTenantName()
        }
        if(index == 0){
            loadUserName()
        }
        if(index == 3){
            var wifi = settingsManager.getValue(settingsManager.currentDevice)
            console.log("wifi info =" + wifi)
            contentName = JSON.parse(wifi).wifiName
        }
    }

    property var loaded: false

    function jumpToUserInfo(){
        var user = JSON.parse(settingsManager.getValue(settingsManager.user))
        userInfoLoader.source = "UserInfoPage.qml"
        console.log("user_id = " + user.user_id)
        userInfoLoader.item.user_id = user.user_id
        mineStack.push(userInfoLoader)
    }

    function loadUserName(){
        var user = JSON.parse(settingsManager.getValue(settingsManager.user))
        console.log("user  ==========" + JSON.stringify(user))
        contentName = user.username
        loaded = true
    }

    function loadTenantName(){
        var user = JSON.parse(settingsManager.getValue(settingsManager.user))
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            http.onReplyFailSignal.disconnect(onFail)
            hub.close()
//            console.log("tenant reply: "+reply)
            var response = JSON.parse(reply)
            var tenantName = response.data.name
            root.contentName = tenantName
            loaded = true
        }


        function onFail(reply,code){
            console.log(reply,code)
            http.onReplySucSignal.disconnect(onReply)
            http.onReplyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.onReplyFailSignal.connect(onFail)
        http.get(Api.admin_tenant_details + "/" + user.tenant_id)
    }
}
