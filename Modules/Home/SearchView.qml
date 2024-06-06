import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Http 1.0
import Api 1.0
import Dialog 1.0
import "../../Util/GlobalFunc.js" as GlobalFunc

ScrollView{
    property var list: []

    id: searchview
    Layout.fillWidth: true
    Layout.fillHeight: true
    Toast {id: toastPopup}
    Http {id: http}
    Dialog{id: dialog}
    Hub{id: hub}
    background: Rectangle{
        color: "#FFFFFF"
    }
    BaseNavigationBar{
        id: navigationBar
        title: qsTr("选择项目")
        onBackAction: {
            searchview.parent.parent.pop()
        }
    }

    SearchBar{
        id: searchbar
        height: 73
        anchors.top: navigationBar.bottom
    }

    TreeView{
        id: item_tree
        width: parent.width
        anchors{
            left: parent.left
            right: parent.right
            top: searchbar.bottom
            bottom: parent.bottom
        }
    }

    Component.onCompleted: {
        var tree = settingsManager.getValue(settingsManager.organizationalTree)
        if (GlobalFunc.isJson(tree)) {
            var organizationalTree = JSON.parse(settingsManager.getValue(settingsManager.organizationalTree))
            if (organizationalTree.length > 0) {
                list = organizationalTree.data[0].children
                item_tree.model = list
            } else {
                hub.open()
                getNumberOfOrganizations()
            }
        } else {
            hub.open()
            getNumberOfOrganizations()
        }
    }

    onListChanged: {
        console.log("searchview menuitems data is changed")
    }

    function getNumberOfOrganizations(){
        function onReply(reply){
            http.onReplySucSignal.disconnect(onReply)
            hub.close()
            var response = JSON.parse(reply)
            if (response.data.length <=0) return;
            list = response.data[0].children
            item_tree.model = list
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            hub.close()
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.get(Api.admin_dept_tree)
    }

    /**
     *测试数据
    function setTestDataA(){
        item_tree.model=JSON.parse('[{"id":"2","parentId":"1","weight":2,"name":"华东大区","isLock":false,"createTime":"2023-04-03 13:04:47","children":[{"id":"7","parentId":"2","weight":7,"name":"研发部","isLock":false,"createTime":"2023-04-03 13:04:47","children":[{"id":"8","parentId":"7","weight":11,"name":"UI设计部","isLock":false,"createTime":"2023-04-03 13:04:47"}]},{"id":"9","parentId":"2","weight":12,"name":"产品部","isLock":false,"createTime":"2023-04-03 13:04:47"}]},{"id":"3","parentId":"1","weight":3,"name":"华西大区","isLock":false,"createTime":"2023-04-03 13:04:47","children":[{"id":"11","parentId":"3","weight":14,"name":"推广部","isLock":false,"createTime":"2023-04-03 13:04:47"}]},{"id":"4","parentId":"1","weight":4,"name":"华南大区","isLock":false,"createTime":"2023-04-03 13:04:47","children":[{"id":"12","parentId":"4","weight":15,"name":"客服部","isLock":false,"createTime":"2023-04-03 13:04:47"}]},{"id":"5","parentId":"1","weight":5,"name":"华北大区","isLock":false,"createTime":"2023-04-03 13:04:47","children":[{"id":"13","parentId":"5","weight":16,"name":"财务会计部","isLock":false,"createTime":"2023-04-03 13:04:47"},{"id":"14","parentId":"5","weight":17,"name":"审计风控部","isLock":false,"createTime":"2023-04-03 13:04:47"}]},{"id":"1744253269858799617","parentId":"1","weight":9999,"name":"华中大区","isLock":false,"createTime":"2023-04-03 13:04:47"},{"id":"1744253432757178370","parentId":"1","weight":9999,"name":"深圳大区","isLock":false,"createTime":"2023-04-03 13:04:47","children":[{"id":"1744610596449402882","parentId":"1744253432757178370","weight":9999,"name":"RD_group","isLock":false,"createTime":"2024-01-09 14:42:34"}]},{"id":"1774636640608239618","parentId":"1","weight":9999,"name":"人才安居","isLock":false,"createTime":"2024-04-01 11:15:21"}]')
    }
    */
}
