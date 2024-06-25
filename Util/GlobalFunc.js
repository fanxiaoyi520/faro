
const MMProjectStatus = {
    NotTurnedOn: 0,
    InProgress: 1,
    Completed: 2,
    Close: 3,
};


const MMStageType = {
    One: 1,
    Two: 2,
    Three: 3,
    Four: 4,
    Five: 5
};

function getStageTypeStr(modelData){
    switch(modelData.stageType){
    case MMStageType.One:
        return "一阶段"
    case MMStageType.Two:
        return "二阶段"
    case MMStageType.Three:
        return "三阶段"
    case MMStageType.Four:
        return "四阶段"
    case MMStageType.Five:
        return "五阶段"
    default: break
    }

}

function getStageTypeColor(stageType){
    if (stageType) {
        switch(stageType){
        case MMStageType.One:
            return "#1FA3FF"
        case MMStageType.Two:
            return "#FE9623"
        case MMStageType.Three:
            return "#44D7B6"
        case MMStageType.Four:
            return "#32C5FF"
        case MMStageType.Five:
            return "#38BE76"
        default: break
        }
    } else {
        return "#1FA3FF"
    }
}

function setStatusImageSource(modelData){

    if (modelData) {
        var status = modelData.status;
        switch (modelData.status){
        case MMProjectStatus.NotTurnedOn:
            return "../../images/measure_other/measure_ic_not_created@2x.png"
        case MMProjectStatus.InProgress:
            return "../../images/measure_other/measure_ic_progress@2x.png"
        case MMProjectStatus.Completed:
            return "../../images/measure_other/measure_complete@2x.png"
        case MMProjectStatus.Close:
            return "../../images/measure_other/measure_ic_calculation_failed@2x.png"
        default: break
        }
    } else {
        return "../../images/measure_other/measure_ic_not_created@2x.png"
    }
}

function setStationType(modelData){
    if (modelData) {
        var stationType = modelData;
        switch (stationType){
        case 1:
            return "客厅"
        case 2:
            return "卧室"
        case 3:
            return "厨房"
        case 4:
            return "卫生间"
        case 5:
            return "阳台"
        case 6:
            return "玄关"
        case 7:
            return "过道"
        default:  return "其他"
        }
    } else {
        return "其他"
    }
}

function setStatusStr(modelData){

    if (modelData && modelData.reduceItem) {
        var status = modelData.reduceItem.status;
        switch (modelData.reduceItem.status){
        case MMProjectStatus.NotTurnedOn:
            return "未开启"
        case MMProjectStatus.InProgress:
            return "进行中"
        case MMProjectStatus.Completed:
            return "已完成"
        case MMProjectStatus.Close:
            return "已关闭"
        default: break
        }
    } else {
        return "未开启"
    }
}

function roundToTwoDecimalPlaces(num) {
    return +(Math.round(num + "e+2")  + "e-2");
}

function getStationType(stationType){
   if (stationType === 1) return "客厅";
   if (stationType === 2) return "卧室";
   if (stationType === 3) return "厨房";
   if (stationType === 4) return "卫生间";
   if (stationType === 5) return "阳台";
   if (stationType === 6) return "玄关";
   if (stationType === 7) return "过道";

   return "其它"
}

function isJson(str) {
    try {
        JSON.parse(str);
        return true;
    } catch (e) {
        return false;
    }
}

function isEmpty(variable) {
    return variable === null || variable === undefined || variable === '';
}
