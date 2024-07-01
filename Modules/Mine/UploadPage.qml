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
    property var pushStackSource: "mine"// mine and home
    property var index: 0
    property var totalUploadSize: 0
    property var totalSize: 0
    property bool isTabbarRootComponent: false

    width:parent.width
    height: parent.width

    TipsPopUp{
        id:tipsPop_del
        onConfirmAction: {
            for(var i =0 ;i < selectList.length; i ++){
                fileManager.removePath(selectList[i].filePath)
                fileManager.removePath(selectList[i].filePath.replace(".fls",".zip"))
            }
            delByPath()
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
            delByPath()
            refreshFileInfo()
        }
    }

    ScanningFaroPop{
        id:upload_pop
        lottieType:1
        title:qsTr(String.upload)
    }

    Http{ id:http }
    /***bug fixing: 不能在这再次调用faroManager.init()*/
    FaroManager {
        id: faroManager
        onConvertFlsToZipPlyResult: {
            console.log("enter ply zip result = " + filePath)
            if(filePath){
                uploadFile(rect_root.index,filePath)
            }else{
                rect_root.failedCount += 1
                if (index + 1 < selectList.length) {
                    callBackUploadFile(index + 1)
                }else{
                    tipsPop_upload_finish.tipsContentStr = String.upload_upload_mid_err_tips.replace("%1d",rect_root.successCount).replace("%2d",rect_root.failedCount)
                    tipsPop_upload_finish.open()
                    upload_pop.close()
                    selectAllGroup(false)
                    selectList = []
                }
                upload_pop.tipsconnect = qsTr(String.upload_progress.replace("%1d",rect_root.successCount + rect_root.failedCount).replace("%2d",rect_root.totalUploadSize))
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
            visible: !isTabbarRootComponent
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    console.log("click quit")
                    if (pushStackSource === "mine") {
                        mineStack.pop()
                    } else {
                        rootStackView.pop()
                    }
                    selectList = []
                    img_select_all.isSelect = false
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
        clip: true
        width: parent.width;
        height: rect_root.height - rect_bottom.height - rect_top.height
        anchors.top: rect_top.bottom
        anchors.topMargin: 4
        anchors.bottom: rect_bottom.top
        Component{
            id:component_data
            ListView {
                id:list_uploadpgae
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
        anchors.bottomMargin: isTabbarRootComponent ? 79 : 0
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
                    var selected = !img_select_all.isSelect
                    console.log("selected = " + selected)
                    img_select_all.isSelect = selected
                    if(selected){
                        selectList = parseAllGroup(groupedList)
                    }else{
                        selectAllGroup(false)
                        selectList = []
                    }
//                    console.log("select data = " + JSON.stringify(selectList))
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
                    var selected = !img_select_all.isSelect

                    if(selected){
                        selectList = parseAllGroup(groupedList)
                    }else{
                        selectAllGroup(false)
                        selectList = []
                    }
                    img_select_all.isSelect = selected
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
                    if(selectList.length == 0){
                        tipsPop_tips.tipsContentStr = String.upload_no_select_tips
                        tipsPop_tips.open()
                    }else{
                        tipsPop_del.tipsContentStr = String.upload_del_tips.replace("%d",selectList.length)
                        tipsPop_del.open()
                    }
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

    function delByPath(){
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
                                      for(var i = 0;i<selectList.length;i++){
                                          if(selectList[i].stageType === itemObj.stageType &&
                                             selectList[i].stationId === itemObj.stationId &&
                                             selectList[i].roomId === itemObj.roomId
                                             ){
                                              itemObj.filePath = ""
                                          }
                                      }
                                      return JSON.stringify(itemObj)
                                  });
                console.log("compress after datas = " + JSON.stringify(datas))
                settingsManager.setValue(settingsManager.fileInfoData,JSON.stringify(datas))
            } else {
                totalFileInfo = []
            }
        }
    }

    function refreshFileInfo(){
        var filejson = settingsManager.getValue(settingsManager.fileInfoData)
        console.log("fileInfoData = " + filejson)
        var totalFileInfo = []
        if (!filejson) {
            totalFileInfo = []
        } else {
            var datas = JSON.parse(filejson)
            if (Array.isArray(datas)){
                console.log("compress after datas = " + JSON.stringify(datas))
                var fileDatas = datas.filter((value, index, self) => {
                                                 console.log("value == " + value)
                                                 var path = JSON.parse(value).filePath
                                                 console.log("filepath = " + path)
                                                 console.log("path isEmpty = " + (path === 'undefined' || !path || !/[^\s]/.test(path)))
                                                 return !(path === 'undefined' || !path || !/[^\s]/.test(path))
                                             });
                totalFileInfo = fileDatas

                if(fileDatas.length < datas.length){
                    settingsManager.setValue(settingsManager.fileInfoData,JSON.stringify(fileDatas))
                }
            } else {
                totalFileInfo = []
            }
        }
        console.log("totalFileInfo length = " + totalFileInfo.length)
        text_count.text = "("+ totalFileInfo.length +")"
        rect_root.totalSize = totalFileInfo.length
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

            rect_root.groupedList = []
            rect_root.groupedList = resultArray
        }else{
            rect_root.groupedList = []
        }
    }

    function uploadAllFile(){
        rect_root.failedCount = 0
        rect_root.successCount = 0
        var totalUploadSize = selectList.length
        rect_root.totalUploadSize = totalUploadSize
        upload_pop.tipsconnect = qsTr(String.upload_progress.replace("%1d",rect_root.successCount + rect_root.failedCount).replace("%2d",totalUploadSize))
        upload_pop.open()
        callBackUploadFile(0,totalUploadSize)
        console.log("successCounr = " + rect_root.successCount + "faildCount = " + rect_root.failedCount + "totalUploadSize = " +totalUploadSize)
    }

    function callBackUploadFile(index,totalUploadSize){
        rect_root.index = index
        console.log("begin totalUploadSize : " + rect_root.totalUploadSize)
        var fileAbsPath = selectList[index].filePath
        faroManager.startConvertFlsToZipPly(fileAbsPath)
    }

    function uploadFile(index,fileAbsPath){
        if(fileAbsPath === ""){
            console.log("enter fileAbsPath empty")
            rect_root.failedCount += 1
            if (index + 1 < selectList.length) {
                callBackUploadFile(index + 1)
            }else{
                upload_pop.close()
                selectAllGroup(false)
                selectList = []
            }
            upload_pop.tipsconnect = qsTr(String.upload_progress.replace("%1d",rect_root.successCount + rect_root.failedCount).replace("%2d",rect_root.totalUploadSize))
            return
        }

        function onReply(reply) {
            http.qtreplySucSignal.disconnect(onReply)
            http.qtreplyFailSignal.disconnect(onFail)
            console.log("upload reply :" + reply)
            var response = JSON.parse(reply)
            if(response.code !== 0){
                 rect_root.failedCount += 1
                if (index + 1 < selectList.length) {
                   callBackUploadFile(index + 1)
                }else{
                    upload_pop.close()
                    tipsPop_upload_finish.tipsContentStr = String.upload_upload_mid_err_tips.replace("%1d",rect_root.successCount).replace("%2d",rect_root.failedCount)
                    tipsPop_upload_finish.open()
                    selectAllGroup(false)
                    selectList = []
                }
                console.log("successCounr = " + rect_root.successCount + "faildCount = " + rect_root.failedCount)
                console.log("upload reply :" + rect_root.totalUploadSize)
                upload_pop.tipsconnect = qsTr(String.upload_progress.replace("%1d",rect_root.successCount + rect_root.failedCount).replace("%2d",rect_root.totalUploadSize))
            }else{
                performCalculation(JSON.stringify(response.data),selectList[index].filePath,JSON.stringify(selectList[index]),index)
            }
        }

        function onFail(reply, code) {
            console.log("upload failed :" + reply, code);
            console.log("upload failed:" + rect_root.totalUploadSize)
            http.qtreplySucSignal.disconnect(onReply)
            http.qtreplyFailSignal.disconnect(onFail)
            rect_root.failedCount += 1
            if (index + 1 < selectList.length) {
                callBackUploadFile(index + 1)
            }else{
                upload_pop.close()
                tipsPop_upload_finish.tipsContentStr = String.upload_upload_mid_err_tips.replace("%1d",rect_root.successCount).replace("%2d",rect_root.failedCount)
                tipsPop_upload_finish.open()
                selectAllGroup(false)
                selectList = []
            }
            upload_pop.tipsconnect = qsTr(String.upload_progress.replace("%1d",rect_root.successCount + rect_root.failedCount).replace("%2d",rect_root.totalUploadSize))
        }

        http.qtreplySucSignal.connect(onReply)
        http.qtreplyFailSignal.connect(onFail)
        http.upload(Api.admin_sys_file_upload, fileAbsPath);
        console.log("upload file abspath = " + fileAbsPath)
    }

    function performCalculation(result,filePath,params,index){
        function onReply(reply){
            faroManager.performCalculationFailResult.disconnect(onFail)
            faroManager.performCalculationSucResult.disconnect(onReply)
            console.log("calculation reply:" + reply)
            console.log("calculation totalCount:" + rect_root.totalUploadSize)
            var replayObj = JSON.parse(reply)
            if(replayObj.code !== 0){
                rect_root.failedCount += 1
            }else{
                rect_root.successCount += 1
                fileManager.removePath(selectList[index].filePath)
                fileManager.removePath(selectList[index].filePath.replace(".fls",".zip"))
                var filejson = settingsManager.getValue(settingsManager.fileInfoData)
                if (filejson) {
                    var datas = JSON.parse(filejson)
                    if (Array.isArray(datas)){
                        datas = datas.map((item)=>{
                                              var itemObj = JSON.parse(item)
                                              var filePath = itemObj.filePath;
                                              if(selectList[index].stageType === itemObj.stageType &&
                                                 selectList[index].stationId === itemObj.stationId &&
                                                 selectList[index].roomId === itemObj.roomId
                                                 ){
                                                  itemObj.filePath = ""
                                              }
                                              return JSON.stringify(itemObj)
                                          });
                        settingsManager.setValue(settingsManager.fileInfoData,JSON.stringify(datas))
                    }
                }
            }
            if (index + 1 < selectList.length) {
               callBackUploadFile(index + 1)
            }else{
                tipsPop_upload_finish.tipsContentStr = String.upload_upload_mid_err_tips.replace("%1d",rect_root.successCount).replace("%2d",rect_root.failedCount)
                tipsPop_upload_finish.open()
                upload_pop.close()
               selectAllGroup(false)
                selectList = []
            }

            upload_pop.tipsconnect = qsTr(String.upload_progress.replace("%1d",rect_root.successCount + rect_root.failedCount).replace("%2d",rect_root.totalUploadSize))
        }

        function onFail(reply,code){
            faroManager.performCalculationFailResult.disconnect(onFail)
            faroManager.performCalculationSucResult.disconnect(onReply)
            console.log("calculation faild reply :" + reply,code)
            console.log("calculation totalCount:" + rect_root.totalUploadSize)
            rect_root.failedCount += 1
            if (index + 1 < selectList.length) {
              callBackUploadFile(index + 1)
            }else{
                tipsPop_upload_finish.tipsContentStr = String.upload_upload_mid_err_tips.replace("%1d",rect_root.successCount).replace("%2d",rect_root.failedCount)
                tipsPop_upload_finish.open()
                upload_pop.close()
                selectAllGroup(false)
                selectList = []
            }
            upload_pop.tipsconnect = qsTr(String.upload_progress.replace("%1d",rect_root.successCount + rect_root.failedCount).replace("%2d",rect_root.totalUploadSize))
        }

        faroManager.performCalculationSucResult.connect(onReply)
        faroManager.performCalculationFailResult.connect(onFail)
        faroManager.performCalculation(result,filePath,params)
    }

    function parseAllGroup(){
        selectAllGroup(true)
        var totalArray = []
        groupedList.forEach((item,index)=>{
          var subArray = item
          if(subArray && subArray.length > 0){
              subArray.forEach((subItem,subIndex)=>{
                 totalArray.push(JSON.parse(subItem))
              })
          }
        })
        return totalArray
    }

    function selectAllGroup(isSelected){
        var newGroupedList = groupedList.map(function(item){
                    return item.map(function(subItem){
                        var subObjItem = JSON.parse(subItem)
                        subObjItem.isSelected = isSelected
                        return JSON.stringify(subObjItem)
                    })
                })
        groupedList = []
        groupedList = newGroupedList
    }
}

