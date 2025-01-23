import QtQuick 2.2
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
                isUser: false
            })
            chatView.positionViewAtEnd()
        }
        onErrorOccurred: function(error) {
            chatView.model.append({
                message: "❌ " + error,
                isUser: false
            })
            chatView.positionViewAtEnd()
        }
        onStreamUpdate: function(content) {
            // 如果是第一个流式片段，创建新的消息项
            if (chatView.model.count === 0 || chatView.model.get(chatView.model.count - 1).isUser) {
                chatView.model.append({
                    message: content,
                    isUser: false
                })
            } else {
                // 否则更新最后一条消息
                var lastIndex = chatView.model.count - 1
                var currentMessage = chatView.model.get(lastIndex).message
                chatView.model.setProperty(lastIndex, "message", currentMessage + content)
            }
            chatView.positionViewAtEnd()
        }
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
            delegate: Rectangle {
                width: chatView.width
                height: messageText.height + 24
                color: model.isUser ? "#404040" : "#2d2d30"
                radius: 8
                layer.enabled: true
                layer.effect: DropShadow {
                    color: "#20000000"
                    radius: 6
                    samples: 13
                    verticalOffset: 2
                }
                
                TextEdit {
                    id: messageText
                    text: model.message
                    color: model.isUser ? "white" : "#e1e1e1"
                    width: parent.width - 24
                    anchors.centerIn: parent
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                    textFormat: Text.PlainText
                    selectByMouse: true
                    selectedTextColor: "white"
                    selectionColor: "#666666"
                    mouseSelectionMode: TextEdit.SelectCharacters
                    persistentSelection: false

                    // 防止用户直接编辑
                    onTextChanged: {
                        if (text !== model.message) {
                            text = model.message
                        }
                    }

                    // 添加右键菜单
                    Menu {
                        id: contextMenu
                        MenuItem {
                            text: qsTr("Copy")
                            enabled: messageText.selectedText
                            onTriggered: {
                                messageText.copy();
                            }
                        }
                        MenuItem {
                            text: qsTr("Select All")
                            onTriggered: messageText.selectAll()
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        hoverEnabled: true
                        onClicked: {
                            if (mouse.button === Qt.RightButton)
                                contextMenu.popup()
                        }
                        onPressAndHold: contextMenu.popup()
                        cursorShape: Qt.IBeamCursor
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            TextField {
                id: messageInput
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                placeholderText: qsTr("Type your message...")
                placeholderTextColor: "#888"
                color: "white"
                enabled: !aiChat.isProcessing
                selectByMouse: true
                font.pixelSize: 15
                background: Rectangle {
                    color: "#2d2d30"
                    radius: 8
                    border.color: "#404040"
                    border.width: 1
                }

                // 添加键盘快捷键
                Keys.onPressed: function(event) {
                    if ((event.key === Qt.Key_A) && (event.modifiers & Qt.ControlModifier || event.modifiers & Qt.MetaModifier)) {
                        messageInput.selectAll();
                        event.accepted = true;
                    }
                }

                onAccepted: {
                    if (text.trim() !== "") {
                        chatView.model.append({
                            message: text,
                            isUser: true
                        })
                        chatView.positionViewAtEnd()
                        aiChat.sendMessage(text)
                        text = ""
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
                            isUser: true
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