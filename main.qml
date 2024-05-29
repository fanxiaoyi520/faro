import QtQuick 2.12
import QtQuick.Window 2.12
import Login 1.0
import QtQuick.XmlListModel 2.12
import Modules 1.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Dialog 1.0

Window {
    id: rootWindow
    visible: true
    width: 640
    height: 400
    //visibility: "Maximized"
    title: qsTr("Measure")
    property var currentView: login

    Component.onCompleted: {
        initData()
        initView()
    }

    //initialize default select measure data
    function initData(){
        var selectedMeasureData = settingsManager.getValue(settingsManager.selectedMeasureData)
        //if (!selectedMeasureData) {
            var defaultParams = {
                "activeColoring": "0",
                "map_mode": 1,
                "scanningMode": 4,
                "masonry_mode": 0,
                "xy_crop_dist": 6,
                "z_crop_dist": 3,
            }
            settingsManager.setValue(settingsManager.selectedMeasureData,JSON.stringify(defaultParams))
        //}
    }

    function initView(){
        var user;
        var userString = settingsManager.getValue(settingsManager.user);
        console.log("setting user == " + userString)
        if (userString) {
            try {
                user = JSON.parse(userString);
            } catch (error) {
                console.error("Error parsing user data:", error);
            }
        }

        if (user && user.access_token !== "") {
            console.log("enter mainview")
            currentView = mainview;
        } else {
            console.log("enter loginview")
            currentView = login;
        }
    }

    function toggleView() {
        if(currentView === login){
            currentView = mainview
        }else{
            currentView = login
        }
    }

    Hub{id:hub}
    Component {
        id: login
        Item {
            anchors.fill: parent
            Login {
                anchors.centerIn: parent
                onCompleteLogin: toggleView()
            }
        }
    }

    Component {
        id: mainview
        Rectangle{
            anchors.fill: parent
            StackLayout {
                anchors.fill: parent
                currentIndex: tabbar.currentIndex
                HomePage{
                    id: homeTab
                    onDepthChanged: {
                        console.log("home page current depth:"+depth)
                        tabbar.visible = depth === 1
                    }
                }
                ScanPage{
                    id: scanTab
                    onDepthChanged: {
                        console.log("scan page current depth:"+depth)
                        tabbar.visible = depth === 1
                    }
                }
                ResultPage{
                    id: resultTab
                    onDepthChanged: {
                        console.log("result page current depth:"+depth)
                        tabbar.visible = depth === 1
                    }
                }
                MinePage{
                    id: mineTab
                    onDepthChanged: {
                        console.log("mine page current depth:"+depth)
                        tabbar.visible = depth === 1
                    }
                }
            }

            BaseTabBar{
                id: tabbar
                onTabBarAction: {
                    console.log("switch selected tabbar: "+currentIndex)
                }
            }
        }
    }

    Loader {
        id: viewLoader
        anchors.fill: parent
        sourceComponent: currentView
    }
}
