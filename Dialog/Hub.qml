import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Lottie 1.0

Popup  {
    id: popup
    width: parent.width
    height: parent.height
    background: Rectangle{
        anchors.fill: parent
        color: "#CCFFFFFF"
    }

    Timer {
        id: timer
        interval: 1000 * 10 //超时时间
        repeat: false
        onTriggered: popup.close()
    }

    LottieAnimation {
        id: fancyAnimation
        anchors.centerIn: parent
        width: 100
        height: 100
        loops: Animation.Infinite
        fillMode: Image.PreserveAspectFit
        running: true
    }

    onOpened: {
        console.log("......")
        fancyAnimation.start()
        fancyAnimation.source = Qt.resolvedUrl("../images/json/net_loading.json")
        timer.start()
    }

    onClosed: {
        console.log("已经关闭")
        fancyAnimation.stop()
        timer.stop()
    }
}
