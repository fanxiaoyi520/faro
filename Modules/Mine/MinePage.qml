import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "../../String_Zh_Cn.js" as SettingString
import Dialog 1.0
import Http 1.0
import Api 1.0

StackView{
    id: minestack
    property var mineStack: minestack
    initialItem: mineview
    Component {
        id: mineview
        Rectangle{
            id:root
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "white"
            property var settingItems: []
            TipsPopUp{
                id:logoutTipsPop
                onConfirmAction: {
                    while (mineStack.depth > 1) {
                        mineStack.pop();
                    }
                    rootWindow.toggleView()
                    settingsManager.setValue(settingsManager.user,null)
                }
            }
            TipsPopUp{
                id:mineTipsPop
                isVisibleCancel:false
            }
            Http{id:http}
            Dialog{
                id:wifiResultPop
                onConfirmOptionsAction: {
                    console.log("get wifi click " + model.name)
                    getDevicePass(model.name);
                }
            }

            BaseNavigationBar{
                id: navigationBar
                title: qsTr("系统设置")
                isVisibleBackBtn: false
            }

            ScrollView{
                id:scrollview
                anchors.top: navigationBar.bottom
                anchors.topMargin: 4
                width: parent.width
                height: root.height - navigationBar.height + 4

                Column{
                    id:column
                    width: parent.width
                    Repeater{
                        model: SettingString.setting_lists.length
                        delegate:SettingItem{
                            id:settingItem
                            settingInfo: JSON.parse(SettingString.setting_lists[index])
                            iconPath : ""
                            showDive: index != SettingString.setting_lists.length - 1
                            Component.onCompleted: {
                                settingItems.push(settingItem);
                            }
                        }
                    }
                }

                Rectangle{
                    anchors.top: column.bottom
                    width: parent.width
                    height: scrollview.height - column.height
                    color: "#f3f3f3"

                    Rectangle{
                        id:rect_logout
                        anchors.top: parent.top
                        anchors.topMargin: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 120
                        height: 32
                        color: "white"
                        border.color: "#999999"
                        border.width: 0.5
                        radius: 10
                         property var loaded: false
                        Text{
                            anchors.centerIn: parent
                            text: qsTr(SettingString.setting_logout)
                        }

                        MouseArea{
                            anchors.fill: parent
                            onPressed: {
                                rect_logout.color = "cyan"
                            }
                            onReleased: {
                                rect_logout.color = "white"
                            }
                            onClicked: {
                                logoutTipsPop.tipsContentStr = qsTr(SettingString.setting_logout_tips)
                                logoutTipsPop.open()
                            }
                        }
                    }
                }
            }

            function getDevicePass(deviceName){
                var user = JSON.parse(settingsManager.getValue(settingsManager.user))
                function onReply(reply){
                    http.onReplySucSignal.disconnect(onReply)
                     http.replyFailSignal.disconnect(onFail)
                    console.log("device response: "+reply)
                    var response = JSON.parse(reply)
                    if (response.data) {
                        var myWifiObject = {
                            wifiName : deviceName,
                            wifiPass : response.data
                        }
                        settingsManager.setValue(settingsManager.currentDevice,JSON.stringify(myWifiObject))
                        mineTipsPop.tipsContentStr = qsTr(SettingString.wifiscan_result_success_tips)
                        root.settingItems[3].refreshContentName = !(root.settingItems[3].refreshContentName)
                    } else {
                         mineTipsPop.tipsContentStr = qsTr(SettingString.wifiscan_result_faild_tips)
                    }
                    mineTipsPop.open()
                }

                function onFail(reply,code){
                    console.log(reply,code)
                    http.onReplySucSignal.disconnect(onReply)
                     http.replyFailSignal.disconnect(onFail)
                    hub.close()
                }

                http.onReplySucSignal.connect(onReply)
                http.onReplyFailSignal.connect(onFail)
                http.get(Api.building_measureDevice_searchDevice + "?deviceCode=" + deviceName)
            }
        }
    }
}
