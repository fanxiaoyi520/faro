import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import "../../String_Zh_Cn.js" as SettingString
Popup {
    property var titleStr: "选择测量模式"
    property var tipsContentStr: ""
    property bool switchvisible: false
    property var list/*: SettingString.selectedMeasureMode*/
    signal confirmAction()

    id: popup
    y: parent.height * 0.1
    x: parent.width * 0.1
    width: parent.width * 0.8
    height: parent.height * 0.8
    onListChanged: setDefaultData()
        /**
     * select measure mode params
     * @masonry_mode    识别砌体
     * @xy_crop_dist    平面
     * @z_crop_dist     高度
     * @map_mode        测量下尺模式
     * @scanningMode    扫描密度
     */
    property string stageType
    property int stationType

    property int masonry_mode: 0
    property int xy_crop_dist: 6
    property int z_crop_dist: 3
    property int map_mode: 2
    property string scanningMode: "1/20"
    property int scanningIndex: 7

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    background: Rectangle{
        radius: 25
        color: "transparent"
    }

    contentItem:     Rectangle{
        anchors.fill: parent
        radius: 25
        color: "#FFFFFF"

        Text {
            id: title
            text: titleStr
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 17
            font.pointSize: 18
            color: "#2C2C2C"
            font.weight: Font.Bold
        }
        Image {
            id: closeimg
            source: "../../images/measure_other/measure_back.png"
            width: 17;height: 17
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: title.verticalCenter
            MouseArea{
                anchors.fill: parent
                onClicked: popup.close()
            }
        }
        Rectangle {
            id: bottomLine
            anchors.top: title.bottom
            anchors.topMargin: 17
            width: parent.width
            height: 1
            color: "#80EAEAEA"
        }
        ListView /**PullListViewV2*/ {
            id: listView
            anchors.top: bottomLine.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: buttonsContainer.top
            clip: true
            model: list
            delegate:itemDelegate
        }
        Component{
            id: itemDelegate
            SelectMeasureModeCell{
                cellModel: JSON.parse(modelData)
                sub_map_mode: map_mode
                sub_masonry_mode: masonry_mode
                sub_scanningMode: scanningMode
                sub_scanningIndex: scanningIndex
                sub_xy_crop_dist: xy_crop_dist
                sub_z_crop_dist: z_crop_dist
                sub_stageType: stageType
            }
        }
        Item {
            id: buttonsContainer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 51

            Button{
                id: surebtn
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.top: parent.top
                width: (parent.width-24*2)/2
                height: 41
                text: qsTr("确定")
                highlighted: true
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
                    font.pixelSize: 15
                }
                onClicked: sureAction()
            }
        }
    }

    function setDefaultData(){
        var selectedMeasureData = JSON.parse(settingsManager.getValue(settingsManager.selectedMeasureData))
        if (selectedMeasureData){
            masonry_mode = selectedMeasureData.masonry_mode
            if (stationType === 1) {
                if(stageType === "2") {
                    if(selectedMeasureData.masonry_mode === 1 && selectedMeasureData.scanningIndex > 7){
                        scanningMode = "1/16"
                    }
                } else {
                    scanningMode = selectedMeasureData.scanningIndex > 7 ? "1/16" : selectedMeasureData.scanningMode
                }
            } else {
                scanningMode = stageType === "2" ? ((masonry_mode === 1 && selectedMeasureData.scanningIndex > 7) ? "1/16" : selectedMeasureData.scanningMode) : selectedMeasureData.scanningMode
            }
        } else {
            var defaultParams = {
                "activeColoring": "0",
                "map_mode": 4,
                "scanningMode": "1/16",
                "scanningIndex": 7,
                "masonry_mode": 0,
                "xy_crop_dist": 6,
                "z_crop_dist": 3,
            }
            settingsManager.setValue(settingsManager.selectedMeasureData,JSON.stringify(defaultParams))
            map_mode = 1
            masonry_mode = stageType === "2" ? 1 : 0
            if(stationType === 1) {
                scanningMode = "1/16"
            } else {
                scanningMode = stageType === "2" ? "1/16" : "1/20"
            }
        }
    }

    function parent_switchAction(checked){
        console.log("switch checked: "+checked)
        masonry_mode = checked
    }

    function parent_measureTheBottomRulerMode(index,model){
        console.log("measure the bottom ruler mode index: "+index+" model: "+model)
        map_mode = index+1
    }

    function parent_onInputTextChanged(index,text){
        console.log("input: "+index)
        console.log("text: "+text)
        if(index === 1) {
            xy_crop_dist = !text || text === "" ? 1 : text
        } else {
            z_crop_dist = !text || text === "" ? 1 : text
        }
    }

    function parent_scanningDensity(index,model){
        console.log("scanning density: "+index+" model: "+model)
        scanningMode = model
        scanningIndex = index
    }

    function sureAction(){
        popup.close()
        var selectedMeasureData = {
            "masonry_mode": masonry_mode,
            "xy_crop_dist": xy_crop_dist,
            "z_crop_dist": z_crop_dist,
            "map_mode": Number.isInteger(map_mode) ? map_mode : 1,
            "scanningMode": scanningMode,
            "scanningIndex": scanningIndex,
            "activeColoring": "0",
        }
        console.log("selected measure data: "+JSON.stringify(selectedMeasureData))
        settingsManager.setValue(settingsManager.selectedMeasureData,JSON.stringify(selectedMeasureData))
    }
}





