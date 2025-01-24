import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    color: "#1e1e1e"
    radius: 0
    layer.enabled: true
    layer.effect: DropShadow {
        color: "#40000000"
        radius: 12
        samples: 25
        verticalOffset: 4
    }

    signal settingsClicked()

    AIChat {
        id: aiChat
        onMessageReceived: function(message) {
            chatView.model.append({
                message: message,
                streamContent: "",
                isUser: false,
                isMarkdown: true
            })
            chatView.positionViewAtEnd()
        }
        onErrorOccurred: function(error) {
            chatView.model.append({
                message: "❌ " + error,
                streamContent: "",
                isUser: false,
                isMarkdown: true
            })
            chatView.positionViewAtEnd()
        }
        onStreamUpdate: function(content) {
            if (chatView.model.count === 0 || chatView.model.get(chatView.model.count - 1).isUser) {
                chatView.model.append({
                    message: "",
                    streamContent: content,
                    isUser: false,
                    isMarkdown: false
                })
            } else {
                var lastIndex = chatView.model.count - 1
                var currentContent = chatView.model.get(lastIndex).streamContent
                chatView.model.setProperty(lastIndex, "streamContent", currentContent + content)
            }
            chatView.positionViewAtEnd()
        }
        onStreamEnd: function() {
            var lastIndex = chatView.model.count - 1
            if (!aiChat.isProcessing && lastIndex >= 0) {
                var item = chatView.model.get(lastIndex)
                chatView.model.setProperty(lastIndex, "message", item.streamContent)
                chatView.model.setProperty(lastIndex, "isMarkdown", true)
            }
        }
    }

    // 修改渐变边框效果
    Item {
        id: borderEffect
        anchors.fill: parent
        z: 1
        visible: aiChat.isProcessing  // 只在处理时显示

        Rectangle {
            id: gradientMask
            anchors.fill: parent
            color: "transparent"
            border.width: 2
            radius: 2

            // 第一层渐变
            LinearGradient {
                id: gradientBorder
                anchors.fill: parent
                visible: true
                source: gradientMask
                
                start: Qt.point(0, 0)
                end: Qt.point(borderEffect.width, borderEffect.height)
                
                property color currentColor: Qt.rgba(0.8, 0.2, 0.2, 0.8)
                
                gradient: Gradient {
                    GradientStop { 
                        position: 0.0
                        color: gradientBorder.currentColor
                        SequentialAnimation on color {
                            loops: Animation.Infinite
                            ColorAnimation { 
                                to: Qt.rgba(0.2, 0.8, 0.2, 0.8)
                                duration: 1000  // 从2000改为1000
                                onRunningChanged: if(running) gradientBorder.currentColor = Qt.rgba(0.2, 0.8, 0.2, 0.8)
                            }
                            ColorAnimation { 
                                to: Qt.rgba(0.2, 0.2, 0.8, 0.8)
                                duration: 1000  // 从2000改为1000
                                onRunningChanged: if(running) gradientBorder.currentColor = Qt.rgba(0.2, 0.2, 0.8, 0.8)
                            }
                            ColorAnimation { 
                                to: Qt.rgba(0.8, 0.2, 0.2, 0.8)
                                duration: 1000  // 从2000改为1000
                                onRunningChanged: if(running) gradientBorder.currentColor = Qt.rgba(0.8, 0.2, 0.2, 0.8)
                            }
                        }
                    }
                    GradientStop { 
                        position: 1.0
                        color: Qt.rgba(0.2, 0.8, 0.8, 0.8)
                        SequentialAnimation on color {
                            loops: Animation.Infinite
                            ColorAnimation { to: Qt.rgba(0.8, 0.2, 0.8, 0.8); duration: 1000 }  // 从2000改为1000
                            ColorAnimation { to: Qt.rgba(0.8, 0.8, 0.2, 0.8); duration: 1000 }  // 从2000改为1000
                            ColorAnimation { to: Qt.rgba(0.2, 0.8, 0.8, 0.8); duration: 1000 }  // 从2000改为1000
                        }
                    }
                }
            }

            // 添加第二层渐变
            LinearGradient {
                id: secondGradient
                anchors.fill: parent
                visible: true
                source: gradientMask
                opacity: 0.5  // 设置透明度使两层效果能够混合
                
                start: Qt.point(borderEffect.width, 0)
                end: Qt.point(0, borderEffect.height)
                
                property color currentColor: Qt.rgba(0.8, 0.4, 0.1, 0.8)
                
                gradient: Gradient {
                    GradientStop { 
                        position: 0.0
                        color: secondGradient.currentColor
                        SequentialAnimation on color {
                            loops: Animation.Infinite
                            ColorAnimation { 
                                to: Qt.rgba(0.1, 0.4, 0.8, 0.8)
                                duration: 1500  // 从3000改为1500
                                onRunningChanged: if(running) secondGradient.currentColor = Qt.rgba(0.1, 0.4, 0.8, 0.8)
                            }
                            ColorAnimation { 
                                to: Qt.rgba(0.8, 0.1, 0.4, 0.8)
                                duration: 1500  // 从3000改为1500
                                onRunningChanged: if(running) secondGradient.currentColor = Qt.rgba(0.8, 0.1, 0.4, 0.8)
                            }
                            ColorAnimation { 
                                to: Qt.rgba(0.8, 0.4, 0.1, 0.8)
                                duration: 1500  // 从3000改为1500
                                onRunningChanged: if(running) secondGradient.currentColor = Qt.rgba(0.8, 0.4, 0.1, 0.8)
                            }
                        }
                    }
                    GradientStop { 
                        position: 1.0
                        color: Qt.rgba(0.4, 0.1, 0.8, 0.8)
                        SequentialAnimation on color {
                            loops: Animation.Infinite
                            ColorAnimation { to: Qt.rgba(0.1, 0.8, 0.4, 0.8); duration: 1500 }  // 从3000改为1500
                            ColorAnimation { to: Qt.rgba(0.4, 0.1, 0.8, 0.8); duration: 1500 }  // 从3000改为1500
                            ColorAnimation { to: Qt.rgba(0.8, 0.4, 0.1, 0.8); duration: 1500 }  // 从3000改为1500
                        }
                    }
                }
            }
        }

        // 发光效果同时混合两层渐变的颜色
        layer.enabled: true
        layer.effect: Glow {
            samples: 8
            radius: 6
            color: Qt.rgba(
                (gradientBorder.currentColor.r + secondGradient.currentColor.r) / 2,
                (gradientBorder.currentColor.g + secondGradient.currentColor.g) / 2,
                (gradientBorder.currentColor.b + secondGradient.currentColor.b) / 2,
                0.8
            )
            spread: 0.3
        }
    }

    // 主内容区域
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        color: root.color
        radius: root.radius
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            Label {
                text: qsTr("AI Chat")
                visible: false
                color: "white"
                font.pixelSize: 16
                font.bold: true
            }

            Button {
                text: ""
                flat: true
                icon.source: "qrc:/icons/collapse.png"
                icon.color: "white"
                padding: 0
                implicitHeight: 40
                implicitWidth: 40
                contentItem: Item {
                    Image { 
                        id: collapseIcon
                        source: parent.parent.icon.source
                        width: 24
                        height: 24
                        anchors.centerIn: parent
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: collapseIcon
                        source: collapseIcon
                        color: "#e1e1e1"
                    }
                }
                background: Rectangle {
                    color: "transparent"
                    radius: 4
                }
                onClicked: {
                    terminalWindow.width = terminalWindow.height * 4/3
                    terminalWindow.isAIPanelOpen = false
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: ""
                flat: true
                icon.source: "qrc:/icons/clear.png"
                icon.color: "white"
                padding: 0
                implicitHeight: 40
                implicitWidth: 40
                contentItem: Item {
                    Image { 
                        id: clearIcon
                        source: parent.parent.icon.source
                        width: 24
                        height: 24
                        anchors.centerIn: parent
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: clearIcon
                        source: clearIcon
                        color: "#e1e1e1"
                    }
                }
                background: Rectangle {
                    color: "transparent"
                    radius: 4
                }
                onClicked: {
                    chatView.model.clear()
                    aiChat.clearHistory()
                }
            }

            Button {
                text: ""
                flat: true
                icon.source: "qrc:/icons/settings.png"
                icon.color: "white"
                padding: 0
                implicitHeight: 40
                implicitWidth: 40
                contentItem: Item {
                    Image { 
                        id: settingsIcon
                        source: parent.parent.icon.source
                        width: 24
                        height: 24
                        anchors.centerIn: parent
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: settingsIcon
                        source: settingsIcon
                        color: "#e1e1e1"
                    }
                }
                background: Rectangle {
                    color: "transparent"
                    radius: 4
                }
                onClicked: root.settingsClicked()
            }
        }

        ListView {
            id: chatView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: ListModel {}
            
            // 根据消息类型选择不同的delegate
            delegate: Loader {
                width: chatView.width
                sourceComponent: model.isUser ? userMessageDelegate : aiMessageDelegate
                property var messageData: model
            }

            // 用户消息delegate
            Component {
                id: userMessageDelegate
                Rectangle {
                    width: chatView.width
                    height: userMessageText.height + 24
                    color: "#404040"
                    radius: 8
                    layer.enabled: true
                    layer.effect: DropShadow {
                        color: "#20000000"
                        radius: 6
                        samples: 13
                        verticalOffset: 2
                    }

                    TextEdit {
                        id: userMessageText
                        text: messageData.message
                        color: "white"
                        width: parent.width - 24
                        anchors.centerIn: parent
                        wrapMode: Text.WordWrap
                        font.pixelSize: 15
                        textFormat: Text.MarkdownText
                        selectByMouse: true
                        selectedTextColor: "white"
                        selectionColor: "#666666"
                        mouseSelectionMode: TextEdit.SelectCharacters
                        persistentSelection: false

                        Menu {
                            id: userContextMenu
                            MenuItem {
                                text: qsTr("Copy")
                                enabled: userMessageText.selectedText
                                onTriggered: userMessageText.copy()
                            }
                            MenuItem {
                                text: qsTr("Select All")
                                onTriggered: userMessageText.selectAll()
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            hoverEnabled: true
                            onClicked: {
                                if (mouse.button === Qt.RightButton)
                                    userContextMenu.popup()
                            }
                        }
                    }
                }
            }

            // AI消息delegate
            Component {
                id: aiMessageDelegate
                Rectangle {
                    width: chatView.width
                    height: markdownMessageText.height + 24
                    color: "#2d2d30"
                    radius: 8
                    layer.enabled: true
                    layer.effect: DropShadow {
                        color: "#20000000"
                        radius: 6
                        samples: 13
                        verticalOffset: 2
                    }

                    // Markdown文本显示
                    TextEdit {
                        id: markdownMessageText
                        text: messageData.streamContent
                        color: "#e1e1e1"
                        width: parent.width - 24
                        anchors.centerIn: parent
                        wrapMode: Text.WordWrap
                        font.pixelSize: 15
                        textFormat: Text.MarkdownText
                        selectByMouse: true
                        selectedTextColor: "white"
                        selectionColor: "#666666"
                        mouseSelectionMode: TextEdit.SelectCharacters
                        persistentSelection: false

                        Menu {
                            id: markdownContextMenu
                            MenuItem {
                                text: qsTr("Copy")
                                enabled: markdownMessageText.selectedText
                                onTriggered: markdownMessageText.copy()
                            }
                            MenuItem {
                                text: qsTr("Select All")
                                onTriggered: markdownMessageText.selectAll()
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            hoverEnabled: true
                            onClicked: {
                                if (mouse.button === Qt.RightButton)
                                    markdownContextMenu.popup()
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            TextArea {
                id: messageInput
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                placeholderText: qsTr("Type your message...")
                placeholderTextColor: "#888"
                color: "white"
                enabled: !aiChat.isProcessing
                selectByMouse: true
                wrapMode: TextArea.Wrap
                font.pixelSize: 15
                padding: 10
                verticalAlignment: TextArea.AlignVCenter

                background: Rectangle {
                    color: "#2d2d30"
                    radius: 8
                    border.color: "#404040"
                    border.width: 1
                }

                // 处理所有按键事件
                Keys.onPressed: function(event) {
                    // Ctrl+A / Cmd+A 全选
                    if ((event.key === Qt.Key_A) && (event.modifiers & Qt.ControlModifier || event.modifiers & Qt.MetaModifier)) {
                        messageInput.selectAll();
                        event.accepted = true;
                        return;
                    }
                    
                    // Enter键处理
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        event.accepted = true;
                        
                        // Shift+Enter插入换行
                        if (event.modifiers & Qt.ShiftModifier) {
                            var pos = cursorPosition;
                            var beforeText = text.substring(0, pos);
                            var afterText = text.substring(pos);
                            text = beforeText + "\n" + afterText;
                            cursorPosition = pos + 1;
                        } 
                        // 普通Enter发送消息
                        else {
                            if (text.trim() !== "") {
                                chatView.model.append({
                                    message: text,
                                    streamContent: "",
                                    isUser: true,
                                    isMarkdown: false
                                })
                                chatView.positionViewAtEnd()
                                aiChat.sendMessage(text)
                                text = ""
                            }
                        }
                    }
                }
            }


            Button {
                id: sendButton
                text: ""
                flat: true
                icon.source: "qrc:/icons/send.png"
                icon.color: "white"
                padding: 0
                implicitHeight: 44
                implicitWidth: 44
                enabled: !aiChat.isProcessing && messageInput.text.trim() !== ""
                
                states: [
                    State {
                        name: "loading"
                        when: aiChat.isProcessing
                        PropertyChanges {
                            target: sendIcon
                            opacity: 0
                        }
                        PropertyChanges {
                            target: loadingIndicator
                            opacity: 1
                        }
                    },
                    State {
                        name: "disabled"
                        when: !aiChat.isProcessing && messageInput.text.trim() === ""
                        PropertyChanges {
                            target: sendIcon
                            opacity: 1
                        }
                        PropertyChanges {
                            target: iconOverlay
                            color: "#888"
                        }
                        PropertyChanges {
                            target: loadingIndicator
                            opacity: 0
                        }
                    },
                    State {
                        name: "enabled"
                        when: !aiChat.isProcessing && messageInput.text.trim() !== ""
                        PropertyChanges {
                            target: sendIcon
                            opacity: 1
                        }
                        PropertyChanges {
                            target: iconOverlay
                            color: "#e1e1e1"
                        }
                        PropertyChanges {
                            target: loadingIndicator
                            opacity: 0
                        }
                    }
                ]
                
                transitions: [
                    Transition {
                        from: "*"; to: "*"
                        NumberAnimation {
                            properties: "opacity,color"
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                ]

                contentItem: Item {
                    Image { 
                        id: sendIcon
                        source: parent.parent.icon.source
                        width: 24
                        height: 24
                        anchors.centerIn: parent
                        visible: false
                    }
                    ColorOverlay {
                        id: iconOverlay
                        anchors.fill: sendIcon
                        source: sendIcon
                        color: "#e1e1e1"
                    }

                    BusyIndicator {
                        id: loadingIndicator
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        running: aiChat.isProcessing
                        opacity: 0
                        palette.dark: "#888888"
                    }
                }
                
                background: Rectangle {
                    color: "transparent"
                    radius: 8
                }
                
                onClicked: {
                    if (messageInput.text.trim() !== "") {
                        chatView.model.append({
                            message: messageInput.text,
                            streamContent: "",
                            isUser: true,
                            isMarkdown: false
                        })
                        chatView.positionViewAtEnd()
                        aiChat.sendMessage(messageInput.text)
                        messageInput.text = ""
                    }
                }
            }
        }
    }
} 