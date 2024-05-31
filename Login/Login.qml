import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.5
import Dialog 1.0
import Api 1.0
import Http 1.0

Rectangle{
    signal completeLogin()
    property alias loginbtn: loginbtn
    property var tenant_id: "1"
    width: 640
    height: 400
    Toast {id: toastPopup}
    Http {id: http}
    Dialog{
        id: dialog
        onConfirmOptionsAction: {
            console.log("dialog selected data: " + JSON.stringify(model))
            hub.open()
            getLoginToken(model.id)
        }
    }
    Hub{id: hub}

    Image {
        id: logoimage
        source: "../images/login_logo.png"
        width: 222;height: 81.5
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
    }


    LoginTextField {
        id: accountfield
        anchors.top: logoimage.bottom
        anchors.topMargin: 57
        inputfield.focus: true
        Keys.onBacktabPressed: passwordfield
        inputfield.placeholderText: qsTr("请输入账号")
        leftimage.source: "../images/login_user.png"
        rightimage.source: "../images/login_close.png"
        focus: true
        inputfield.maximumLength: 11
        inputfield.inputMethodHints: Qt.ImhDigits | Qt.ImhFormattedNumbersOnly
        inputfield.validator: RegExpValidator {
            regExp: /^[A-Za-z0-9]+$/
        }
    }

    LoginTextField {
        id: passwordfield
        anchors.top: accountfield.bottom
        anchors.topMargin: 24
        inputfield.focus: true
        inputfield.placeholderText: qsTr("请输入密码")
        Keys.onBacktabPressed: accountfield
        leftimage.source: "../images/login_lock.png"
        rightimage.source: "../images/login_close.png"
        inputfield.validator: RegExpValidator {
            regExp: /[a-zA-Z0-9-]+/
        }
        inputfield.echoMode: TextInput.Password
    }

    Button{
        id: loginbtn
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: 320
        height: 53
        text: qsTr("登录")
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

    Timer {
        id:timer_logintoken
        property var user_id
        interval: 200
        onTriggered: {
            hub.close()
            getUserDetail(user_id)
        }
    }

    Timer {
        id:timer_userdetail
        property var tenant_id
        interval: 200
        onTriggered: {
            getById(tenant_id)
        }
    }

    function login(){
        if(accountfield.inputfield.text === '') {
            toastPopup.text = "手机号不能为空"
            return
        }
        if(passwordfield.inputfield.text === '') {
            toastPopup.text = "密码不能为空"
            return
        }

        get()
    }

    function get(){
        function onReply(reply){
            console.log(reply)
            http.onReplySucSignal.disconnect(onReply)
            http.replyFailSignal.disconnect(onFail)
            var response = JSON.parse(reply)
            if (response.data.length > 1) {
                dialog.list = response.data
                dialog.open()
            } else if(response.data.length === 1){
                var tenantModel = response.data[0]
                getLoginToken(tenantModel.id)
            } else {
                getLoginToken("1")
            }
        }

        function onFail(reply,code){
            console.log(reply,code)
             http.onReplySucSignal.disconnect(onReply)
            http.replyFailSignal.disconnect(onFail)
        }

        http.onReplySucSignal.connect(onReply)
        http.replyFailSignal.connect(onFail)
        http.get(Api.admin_tenant_queryTenantByUserName,{"username":accountfield.inputfield.text})
    }

    function getLoginToken(tenantId){
        function onLoginTokenReply(reply){
            console.log("LoginTokenReply: "+reply)
            http.replyFailSignal.disconnect(onFail)
            http.onReplySucSignal.disconnect(onLoginTokenReply)
            var user = JSON.parse(reply)
            user.account = accountfield.inputfield.text
            user.loginMode = 0
            user.tenant_id = tenant_id
            settingsManager.setValue(settingsManager.user,JSON.stringify(user))
            timer_logintoken.user_id = user.user_id
            timer_logintoken.start()
        }

        function onFail(reply,code){
            hub.close()
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            http.onReplySucSignal.disconnect(onLoginTokenReply)
            toastPopup.text = "手机号或密码错误"
        }

        tenant_id = tenantId
        http.onReplySucSignal.connect(onLoginTokenReply)
        http.replyFailSignal.connect(onFail)
        http.loginPost(Api.auth_oauth_token,{"username":accountfield.inputfield.text,"password":passwordfield.inputfield.text},
                       {"Tenant-id":tenant_id})
    }

    function getUserDetail(user_id){
        function onUserReply(reply){
            console.log("getUserDetail: "+reply)
            http.replyFailSignal.disconnect(onFail)
             http.onReplySucSignal.disconnect(onUserReply)
            var response = JSON.parse(reply)
            var user = JSON.parse(settingsManager.getValue(settingsManager.user))
            user.userinfo = JSON.stringify(response.data)
            settingsManager.setValue(settingsManager.user,JSON.stringify(user))
            timer_userdetail.tenant_id = user.tenant_id
            timer_userdetail.start()
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
             http.onReplySucSignal.disconnect(onUserReply)
        }

//        var user = JSON.parse(settingsManager.getValue(settingsManager.user))
        console.log("userid: " + user_id)
        http.onReplySucSignal.connect(onUserReply)
        http.replyFailSignal.connect(onFail)
        http.get(Api.admin_user_details+"/"+user_id)
    }

    function getById(tenant_id){
        function onByIdReply(reply){
            http.replyFailSignal.disconnect(onFail)
            http.onReplySucSignal.disconnect(onByIdReply)
            var response = JSON.parse(reply)
            var user = JSON.parse(settingsManager.getValue(settingsManager.user))
            user.company = response.data.name
            settingsManager.setValue(settingsManager.user,JSON.stringify(user))
            console.log("complete user data: "+settingsManager.getValue(settingsManager.user))
            completeLogin()
        }

        function onFail(reply,code){
            console.log(reply,code)
            http.replyFailSignal.disconnect(onFail)
            http.onReplySucSignal.disconnect(onByIdReply)
        }

//        var user = JSON.parse(settingsManager.getValue(settingsManager.user))
//        console.log("userid: " + user.user_id)
        http.onReplySucSignal.connect(onByIdReply)
        http.replyFailSignal.connect(onFail)
        console.log("user.userinfo.tenantId: "+ tenant_id)
        http.get(Api.admin_tenant_details+"/"+tenant_id)
    }
}
