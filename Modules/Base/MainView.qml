import QtQuick 2.0
import Modules 1.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

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
