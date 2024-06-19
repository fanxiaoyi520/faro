import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import "../../Util/GlobalFunc.js" as GlobalFunc

Popup{
    id: popup
    property var model
    property var imgUrl
    width: parent.width
    height: parent.height
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    property var imageType: 0
    property var image: Image {
        source: imgUrl ? imgUrl : ""
        visible: false
        onStatusChanged: {
            if (status == Image.Ready) {
                canvas.requestPaint();
            }
        }
    }

    property var logoImage: Image {
        id: logoImageId
        source: "../../images/ic_location_green.svg"
        visible: false
        onStatusChanged: {
            if (status == Image.Ready) {
                canvas.requestPaint();
            }
        }
    }

    property var arrowImage: Image {
        source: "../../images/svglarge.svg"
        visible: false
        onStatusChanged: {
            if (status == Image.Ready) {
                canvas.requestPaint();
            }
        }
    }

    background: Rectangle{
        id: backimage
        anchors.fill: parent
        color: "#000000"
        Canvas {
            id: canvas
            anchors.fill: parent
            width: imageBackWidth
            height: imageBackWidth
            onPaint: canvasPaint(getContext("2d"))
            Component.onCompleted: {
                image.asynchronous = true;
            }
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                popup.close()
            }
            onDoubleClicked: {
                contentItem.scale += 0.1;
                console.log("Double clicked!")
            }
        }

        PinchArea {
            anchors.fill: parent
            enabled: true
            pinch.target: backimage
        }
    }
    padding: 0

    function canvasPaint(context){
        console.log("canvas model large: "+JSON.stringify(model))
        if (!model) return

        var ctx = context;
        ctx.clearRect(0, 0, width, height);
        var imgWidth = image.width;
        var imgHeight = image.height;
        var canvasWidth = canvas.width;
        var canvasHeight = canvas.height;

        // 计算缩放比例
        var scaleWidth = canvasWidth / imgWidth;
        var scaleHeight = canvasHeight / imgHeight;
        var scale = Math.min(scaleWidth, scaleHeight); // 选择较小的缩放比例以保持图片比例

        // 计算绘制宽度和高度
        var drawWidth = imgWidth * scale;
        var drawHeight = imgHeight * scale;

        // 计算绘制位置（居中显示）
        var drawX = (canvasWidth - drawWidth) / 2;
        var drawY = (canvasHeight - drawHeight) / 2;
        ctx.drawImage(image, drawX, drawY, drawWidth, drawHeight);

        model.stations.map(function(station) {
            var x = 0
            var y = 0
            if (station.vectorCoordinateX === null || station.vectorCoordinateY === null) {
                x = station.x
                y = station.y
            } else {
                x = station.vectorCoordinateX
                y = station.vectorCoordinateY
            }
            if (x === 0 || y === 0) return
            var type = 0
            if (station.status === 0) {
                type = 3
            } else {
                if (!station.percentageScore && station.calculationStatus === 3) {
                    type = 2
                } else if (station.calculationStatus === 2) {
                    if (station.percentageScore > 90) {
                        type = 1
                    } else if (station.percentageScore < 90){
                        type = 2
                    }
                } else if (station.calculationStatus === 1) {
                    type = 0
                }
            }
            var drawX = (canvasWidth - drawWidth) / 2;
            var drawY = (canvasHeight - drawHeight) / 2;
            var oldlogoWidth = drawWidth / 20
            if (station.vectorCoordinateX !== 0 || station.vectorCoordinateY !== 0) {
                if (station.ifNeedMark){
                    var degrees = Math.atan2((station.cadMapCenterY-station.northCenterY), (station.cadMapCenterX-station.northCenterX)) * 180.0 / Math.PI;
                    if (degrees < 0) degrees += 360;
                    var arrowX = drawX + station.x * scale;
                    var arrowY = drawY + station.y * scale - oldlogoWidth+oldlogoWidth / 2;
                    ctx.save();
                    ctx.translate(arrowX, arrowY);
                    ctx.rotate((degrees-90)*(Math.PI / 180.0));
                    ctx.drawImage(arrowImage,-oldlogoWidth / 2, -oldlogoWidth, oldlogoWidth, oldlogoWidth);
                    ctx.restore();
                }
            }
            var logoWidth = drawWidth / 12
            var logoHeight = logoWidth * 46 / 38
            ctx.globalAlpha = 0.8;
            logoImageId.source = getColor(type)
            ctx.drawImage(logoImage, drawX+station.x*scale-logoWidth/2, drawY+station.y*scale-logoHeight, logoWidth, logoHeight);
            ctx.globalAlpha = 1.0;
            ctx.font = logoWidth/2+"px Arial";
            ctx.fillStyle = "#0000FF";
            ctx.fillText(station.stationNo, drawX+station.x*scale-logoWidth/2+(logoWidth-logoWidth/3)/2, drawY+station.y*scale-logoHeight+logoHeight/2+logoHeight/8);
        });
    }

    function getColor(type){
        if(type === 0) return "../../images/ic_location_orange.svg"
        if(type === 1) return "../../images/ic_location_green.svg"
        if(type === 2) return "../../images/ic_location_red.svg"
        if(type === 3) return "../../images/ic_location_gray.svg"
    }
}
