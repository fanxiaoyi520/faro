import QtQuick 2.0
import QtGraphicalEffects 1.0
import Dialog 1.0
import Modules 1.0
import Http 1.0
import Api 1.0
import FaroManager 1.0
import Util 1.0
import "../../String_Zh_Cn.js" as String

Rectangle{
    id:rect_root
    property var groupedList: []
    property var selectList: []
    property var listItems: []
    property var successCount: 0
    property var failedCount: 0

    width:parent.width
    height: parent.width

    TipsPopUp{
        id:tipsPop_del
        onConfirmAction: {
            for(var i =0 ;i < selectList.length; i ++){
                fileManager.removePath(selectList[i].filePath)
            }
            selectList = []
            listItemSelectAll(false)
            refreshFileInfo()
        }
    }

    TipsPopUp{
        id:tipsPop_upload
        onConfirmAction: {
            uploadAllFile()
        }
    }

    TipsPopUp{
        id:tipsPop_tips
        isVisibleCancel : false
    }

    TipsPopUp{
        id:tipsPop_upload_finish
        onConfirmAction: {
            refreshFileInfo()
        }
    }

    ScanningFaroPop{
        id:upload_pop
        lottieType:1
        title:qsTr(String.upload)
    }

    Http{ id:http }
    FaroManager {
        id: faroManager
        Component.onCompleted: {
            if(faroManager.init()) {
                console.log("--------------初始化成功--------------")
            }
        }
    }
    Rectangle{
        id:rect_top
        color: "#FFFFFF"
        anchors.top: parent.top
        width: parent.width
        height: 36
        layer.enabled: true
        layer.effect: DropShadow{
            horizontalOffset: 0
            verticalOffset: 5.5
            radius: 5.5
            color: "#0A000000"
        }

        Image {
            id:img_back
            source: "../../images/measure_other/measure_back.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 16
            width: 16
            height: 16
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    console.log("click quit")
                    mineStack.pop()
                }
            }
        }

        Row{
            anchors.centerIn: parent
            Text {
                id: text_title
                text: qsTr(String.upload)
                font.bold: true
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: text_count
                text: ""
                font.pixelSize: 16
                color: "#666666"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Rectangle{
        id:rect_content
        width: parent.width;
        height: rect_root.height - rect_bottom.height - rect_top.height
        anchors.top: rect_top.bottom
        anchors.topMargin: 4
        anchors.bottom: rect_bottom.top
        Component{
            id:component_data
            ListView {
                width: parent.width;
                height: rect_content.height
                model: groupedList
                delegate:  UploadItemView{
                    id:uploadItemview
                    datas:groupedList[index]
                    Component.onCompleted: {
                        listItems.push(uploadItemview)
                    }
                }
            }
        }

        Component{
            id: noDataViewComponent
            NoDataView{
                width: rect_content.width
                height: rect_content.height
                id: noDataView
                textStr: qsTr("暂无项目数据")
            }
        }

        Loader{
            id:loder_content
            anchors.fill : parent
            anchors.margins: 16
            sourceComponent: (groupedList.length > 0)? component_data : noDataViewComponent
        }

    }

    Rectangle {
        id:rect_bottom
        color: "#FFFFFF"
        width: parent.width
        height: 60
        anchors.bottom: parent.bottom
        layer.enabled: true
        layer.effect: DropShadow{
            horizontalOffset: 0
            verticalOffset: -5.5
            radius: 5.5
            color: "#0A000000"
        }

        Image {
            id: img_select_all
            source: !isSelect? "../../images/mine/ic_unselected.png" : "../../images/mine/ic_selected.png"
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 24
            property var isSelect: false

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    img_select_all.isSelect = !img_select_all.isSelect
                    listItemSelectAll(img_select_all.isSelect)
                }
            }
        }
        Text {
            id:text_all_selected
            text: qsTr(String.all_selected)
            anchors.left: img_select_all.right
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 16
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    img_select_all.isSelect = !img_select_all.isSelect
                    listItemSelectAll(img_select_all.isSelect)
                }
            }
        }

        Rectangle{
            id:rect_del
            radius: 14
            color: "#FF4D4F"
            width: ((rect_bottom.width - text_all_selected.width - 24 -  img_select_all.width - 24) / 2) - 36
            height: parent.height - 24
            anchors.left: text_all_selected.right
            anchors.leftMargin: 36
            anchors.verticalCenter: parent.verticalCenter
            Text {
                id: text_del
                text: qsTr(String.upload_del)
                color: "#FFFFFF"
                font.pixelSize: 16
                font.bold: true
                anchors.centerIn: parent
            }
            MouseArea{
                anchors.fill: parent
                onPressed: {
                    rect_del.color = "#03DAC5"
                }
                onReleased: {
                    rect_del.color = "#FF4D4F"
                }
                onClicked: {
                    console.log("uploadPage: " + JSON.stringify(selectList))
//                    if(selectList.length == 0){
//                        tipsPop_tips.tipsContentStr = String.upload_no_select_tips
//                        tipsPop_tips.open()
//                    }else{
//                        tipsPop_del.tipsContentStr = String.upload_del_tips.replace("%d",selectList.length)
//                        tipsPop_del.open()
//                    }
                    fileManager.removePath(selectList[0].filePath)
                }
            }
        }

        Rectangle{
            id:rect_upload
            radius: 14
            color: "#1890FF"
            width: ((rect_bottom.width - text_all_selected.width - 24 -  img_select_all.width - 24) / 2) - 36
            height: parent.height - 24
            anchors.left: rect_del.right
            anchors.leftMargin: 36
            anchors.verticalCenter: parent.verticalCenter
            Text {
                id: text_upload
                text: qsTr(String.upload_up)
                color: "#FFFFFF"
                font.pixelSize: 16
                font.bold: true
                anchors.centerIn: parent
            }
            MouseArea{
                anchors.fill: parent
                onPressed: {
                    rect_upload.color = "#03DAC5"
                }
                onReleased: {
                    rect_upload.color = "#1890FF"
                }
                onClicked: {
                    console.log("upload select = " + JSON.stringify(selectList))
                    if(selectList.length == 0){
                        tipsPop_tips.tipsContentStr = String.upload_no_select_tips
                        tipsPop_tips.open()
                    }else{
                        tipsPop_upload.tipsContentStr = String.upload_upload_tips.replace("%d",selectList.length)
                        tipsPop_upload.open()
                    }
                }
            }
        }
    }

    property var loaded: false

    Component.onCompleted: {
        refreshFileInfo()
    }

    onVisibleChanged: {
        if(visible){
            refreshFileInfo()
        }
    }

    function listItemSelectAll(select){
        for(var i = 0 ;i< listItems.length;i++){
            listItems[i].selectAll = select
        }
    }

    /**
      *刷新页面数据，如果文件被删除了更新数据显示
      */
    function refreshFileInfo(){
        var filejson = settingsManager.getValue(settingsManager.fileInfoData)
        console.log("fileInfoData = " + filejson)
        var totalFileInfo = []
        if (!filejson) {
            totalFileInfo = []
        } else {
            var datas = JSON.parse(filejson)
            if (Array.isArray(datas)){
                datas = datas.map((item)=>{
                                      var itemObj = JSON.parse(item)
                                      var filePath = itemObj.filePath;
                                      if(!filePath.includes("zip")){
                                          console.log("filePath = " + filePath)
                                          itemObj.filePath = fileManager.compression_zip_by_filepath(filePath)
                                      }
                                      return JSON.stringify(itemObj)
                                  });
                console.log("compress after datas = " + JSON.stringify(datas))
                var fileDatas = datas.filter((value, index, self) => {
//                                                 console.log("filepath = " + JSON.parse(value).filePath)
//                                                 console.log(fileManager.isFileExist(JSON.parse(value).filePath))
//                                                 return fileManager.isFileExist(JSON.parse(value).filePath)
                                                 return true
                                             });
                totalFileInfo = fileDatas
                if(fileDatas.length < datas.length){
//                    settingsManager.setValue(settingsManager.fileInfoData,JSON.stringify(fileDatas))
                }
            } else {
                totalFileInfo = []
            }
        }
        text_count.text = "("+ totalFileInfo.length +")"

        if(totalFileInfo.length > 0){
            var resultArray = totalFileInfo.reduce(function(acc, curr) {
                var foundItem = acc.find(function(item) {
                    var itemObj = JSON.parse(item[0])
                    var currObj = JSON.parse(curr)
                    return itemObj.roomId === currObj.roomId && itemObj.stageType === currObj.stageType;
                });

                if (foundItem) {
                    foundItem.push(curr);
                } else {
                    acc.push([curr]);
                }

                return acc;
            }, []);


            rect_root.groupedList = resultArray
        }else{
            rect_root.groupedList = []
        }
    }

    function uploadAllFile(){
        rect_root.failedCount = 0
        rect_root.successCount = 0
        var totalUploadSize = selectList.length
        upload_pop.tipsconnect = qsTr(String.upload_progress.replace("%1d",rect_root.successCount + rect_root.failedCount).replace("%2d",totalUploadSize))
        upload_pop.open()
        uploadFile(0)
    }

    function uploadFile(index,totalUploadSize){
        function onReply(reply) {
            console.log("upload reply :" + reply)
            var response = JSON.parse(reply)
            performCalculation(JSON.stringify(response.data),selectList[index].filePath,totalUploadSize,JSON.stringify(selectList[index]),index)
            http.qtreplySucSignal.disconnect(onReply)
            http.qtreplyFailSignal.disconnect(onFail)
        }

        function onFail(reply, code) {
            console.log("upload failed :" + reply, code);
            http.qtreplySucSignal.disconnect(onReply)
            http.qtreplyFailSignal.disconnect(onFail)
            rect_root.failedCount += 1
            if (index + 1 < selectList.length) {
                uploadFile(index + 1);
            }else{
                upload_pop.close()
                tipsPop_upload_finish.tipsContentStr = String.upload_upload_mid_err_tips.replace("%1d",rect_root.successCount).replace("%2d",rect_root.failedCount)
                tipsPop_upload_finish.open()
                //结束清除所有当前选中
                listItemSelectAll(false)
            }
            upload_pop.tipsconnect = qsTr(String.upload_progress.replace("%1d",rect_root.successCount + rect_root.failedCount + 1).replace("%2d",totalUploadSize))
        }

        http.qtreplySucSignal.connect(onReply)
        http.qtreplyFailSignal.connect(onFail)
        var fileAbsPath = selectList[index].filePath
        http.upload(Api.admin_sys_file_upload, fileAbsPath);
        console.log("upload file abspath = " + fileAbsPath)
    }

    function performCalculation(result,filePath,totalUploadSize,params,index){
        function onReply(reply){
            faroManager.performCalculationFailResult.disconnect(onFail)
            faroManager.performCalculationSucResult.disconnect(onReply)
            console.log("calculation reply:" + reply)
            var replayObj = JSON.parse(reply)
            if(replayObj.code !== 0){
                rect_root.failedCount += 1
            }else{
                rect_root.successCount += 1
                fileManager.removePath(selectList[index].filePath)
            }
            if (index + 1 < selectList.length) {
                uploadFile(index + 1);
            }else{
                tipsPop_upload_finish.tipsContentStr = String.upload_upload_mid_err_tips.replace("%1d",rect_root.successCount).replace("%2d",rect_root.failedCount)
                tipsPop_upload_finish.open()
                upload_pop.close()
                //结束清除所有当前选中
                listItemSelectAll(false)
            }

            upload_pop.tipsconnect = qsTr(String.upload_progress.replace("%1d",rect_root.successCount + rect_root.failedCount + 1).replace("%2d",totalUploadSize))
        }

        function onFail(reply,code){
            faroManager.performCalculationFailResult.disconnect(onFail)
            faroManager.performCalculationSucResult.disconnect(onReply)
            console.log("calculation faild reply :" + reply,code)
            rect_root.failedCount += 1
            if (index + 1 < selectList.length) {
                uploadFile(index + 1);
            }else{
                tipsPop_upload_finish.tipsContentStr = String.upload_upload_mid_err_tips.replace("%1d",rect_root.successCount).replace("%2d",rect_root.failedCount)
                tipsPop_upload_finish.open()
                upload_pop.close()
            }
            upload_pop.tipsconnect = qsTr(String.upload_progress.replace("%1d",rect_root.successCount + rect_root.failedCount + 1).replace("%2d",totalUploadSize))
        }

        faroManager.performCalculationSucResult.connect(onReply)
        faroManager.performCalculationFailResult.connect(onFail)
        faroManager.performCalculation(result,filePath,params)
    }
}

