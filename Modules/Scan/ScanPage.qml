import QtQuick 2.0
import Modules 1.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Http 1.0
import Api 1.0
import Dialog 1.0
import QtGraphicalEffects 1.0
import "../../String_Zh_Cn.js" as SettingString
import "../../Util/GlobalFunc.js" as GlobalFunc
StackView{
    id: scanstack
    initialItem: scanview
    property string navigationBarTitle: SettingString.quick_scan
    //公布stackView，让其在所有子控件可以访问到homestack
    property var rootStackView: scanstack
    Toast {id: toastPopup}
    Http {id: http}
    Dialog{id: dialog}
    Hub{id: hub}
    Loader {id: searchview}
    SelectMeasureModePopUp{
        id: selectMeasureModePopUp
    }
    ScanSelectTaskDialog{
        id: scanSelectTaskDialog
        onConfirmOptionsAction: scanConfirmOptionsAction(model)
        onPopUpclickSelectTask: scanPopUpclickSelectTask(index)
    }
    ScanSelectPop {
        id: scanSelectPop
    }

    Component {
        id: scanview
        Rectangle{
            id: rect
            Layout.fillHeight: true
            Layout.fillWidth: true
            BaseNavigationBar{
                id: navigationBar
                title: navigationBarTitle
                isVisibleBackBtn: false

                Image{
                    id: searchimage
                    source: "../../images/home_page_slices/measure_search.png"
                    width: 20;height: 20
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    MouseArea{
                        anchors.fill: parent
                        onClicked: jumpToSearchView()
                    }
                }
            }

            Text{
                id: title
                text: SettingString.scanning_tasks
                anchors.top: navigationBar.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 20
                font.bold: true
                font.pixelSize: 19
            }

            ScrollView {
                id: scrollView
                clip: true
                anchors.top: title.bottom
                anchors.topMargin: 15
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 79
                ColumnLayout{
                    id: column
                    anchors.fill: parent
                    ScanHeaderView{
                        id: scanHeaderView
                        Layout.fillWidth: true
                        height: 119.5
                        onSetupMeasureData: scanSetupMeasureData()
                        onClickSelectTask: scanClickSelectTask()
                        onClickSelectStationNo: scanClickSelectStationNo()
                    }

                    Rectangle{
                        Layout.fillWidth: true
                        height: 200
                        Button{
                            id: startScanBtn
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 30
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.4
                            height: 53
                            text: qsTr(SettingString.start_scan)
                            font.capitalization: Font.MixedCase
                            font.pixelSize: 18
                            highlighted: true
                            palette.buttonText: "#FFFFFF"
                            background: Rectangle{
                                id: btnrect
                                color: "#1890FF"
                                radius: 12
                            }
                            layer.enabled: true
                            layer.effect: DropShadow{
                                horizontalOffset: 0
                                verticalOffset: 12
                                radius: 50
                                color: "#1A1890FF"
                            }
                            onClicked: login()
                        }
                    }
                }
            }
        }
    }

    //MARK: jump
    //跳转到搜索
    function jumpToSearchView(){
        //使用的时候再加载
        searchview.source = "../Home/SearchView.qml"
        scanstack.push(searchview)
    }

    function scanSetupMeasureData() {
        var params = settingsManager.getValue(settingsManager.selectedStageType)
        if (!params) {
            settingsManager.setValue(settingsManager.selectedStageType,SettingString.stageType[0])
        }
        var selectedStageType = JSON.parse(settingsManager.getValue(settingsManager.selectedStageType))
        selectMeasureModePopUp.stageType = selectedStageType.index+1
        selectMeasureModePopUp.stationType = 2

        var selectedMeasureData = JSON.parse(settingsManager.getValue(settingsManager.selectedMeasureData))
        var dataList = SettingString.selectedMeasureMode.map(function(itemString) {
            var itemObject = JSON.parse(itemString);
            itemObject.xy_crop_dist = selectedMeasureData.xy_crop_dist;
            itemObject.z_crop_dist = selectedMeasureData.z_crop_dist;
            return JSON.stringify(itemObject);
        });
        console.log("dataList: "+JSON.stringify(dataList))
        selectMeasureModePopUp.list = []
        selectMeasureModePopUp.list = dataList
        selectMeasureModePopUp.open()
    }

    function scanClickSelectTask() {
        console.log("click select task")
        scanSelectTaskDialog.list = SettingString.selectTask
        scanSelectTaskDialog.open()
    }

    function scanClickSelectStationNo() {
        console.log("click select stationNo")
    }

    function scanConfirmOptionsAction(model) {
        console.log("select task sure")
    }

    function scanPopUpclickSelectTask(index) {
        console.log("scan pop up click select task")
        scanSelectPop.open()
    }
}
