import QtQuick 2.2
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Rectangle {
    id: root
    color: "#2b2b2b"

    // Add markdown to html conversion function
    function markdownToHtml(text) {
        if (!text) return "";
        
        // Convert code blocks
        text = text.replace(/```([^`]+)```/g, '<pre style="background-color: #363636; padding: 8px; border-radius: 4px;"><code>$1</code></pre>');
        
        // Convert inline code
        text = text.replace(/`([^`]+)`/g, '<code style="background-color: #363636; padding: 2px 4px; border-radius: 2px;">$1</code>');
        
        // Convert bold
        text = text.replace(/\*\*([^*]+)\*\*/g, '<b>$1</b>');
        
        // Convert italic
        text = text.replace(/\*([^*]+)\*/g, '<i>$1</i>');
        
        // Convert links
        text = text.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" style="color: #58a6ff;">$1</a>');
        
        // Convert bullet lists
        text = text.replace(/^\s*-\s+(.+)$/gm, '• $1');
        
        // Convert headers
        text = text.replace(/^### (.+)$/gm, '<h3 style="margin: 4px 0;">$1</h3>');
        text = text.replace(/^## (.+)$/gm, '<h2 style="margin: 6px 0;">$1</h2>');
        text = text.replace(/^# (.+)$/gm, '<h1 style="margin: 8px 0;">$1</h1>');
        
        // Convert newlines to <br>
        text = text.replace(/\n/g, '<br>');
        
        return text;
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
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            Label {
                text: qsTr("AI Chat")
                color: "white"
                font.pixelSize: 16
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Clear")
                onClicked: {
                    chatView.model.clear()
                    aiChat.clearHistory()
                }
            }

            Button {
                text: qsTr("Settings")
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
                height: messageText.height + 20
                color: model.isUser ? "#3b3b3b" : "#2b2b2b"
                radius: 4
                
                TextEdit {
                    id: messageText
                    text: markdownToHtml(model.message)
                    color: "white"
                    width: parent.width - 20
                    anchors.centerIn: parent
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                    textFormat: Text.RichText
                    readOnly: true
                    selectByMouse: true
                    selectedTextColor: "white"
                    selectionColor: "#666666"
                    mouseSelectionMode: TextEdit.SelectCharacters
                    persistentSelection: true

                    // 添加键盘快捷键
                    Keys.onPressed: function(event) {
                        if ((event.key === Qt.Key_C) && (event.modifiers & Qt.ControlModifier || event.modifiers & Qt.MetaModifier)) {
                            messageText.copy();
                            event.accepted = true;
                        } else if ((event.key === Qt.Key_A) && (event.modifiers & Qt.ControlModifier || event.modifiers & Qt.MetaModifier)) {
                            messageText.selectAll();
                            event.accepted = true;
                        }
                    }

                    // 添加右键菜单
                    Menu {
                        id: contextMenu
                        MenuItem {
                            text: qsTr("Copy")
                            enabled: messageText.selectedText
                            onTriggered: {
                                messageText.copy()
                                messageText.deselect()
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
                        onClicked: {
                            if (mouse.button === Qt.RightButton)
                                contextMenu.popup()
                        }
                        onPressAndHold: contextMenu.popup()
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
                placeholderText: qsTr("Type your message...")
                color: "white"
                enabled: !aiChat.isProcessing
                selectByMouse: true
                background: Rectangle {
                    color: "#3b3b3b"
                    radius: 4
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

            BusyIndicator {
                visible: aiChat.isProcessing
                running: visible
                width: 32
                height: 32
            }

            Button {
                text: qsTr("Send")
                enabled: !aiChat.isProcessing && messageInput.text.trim() !== ""
                onClicked: messageInput.accepted()
            }
        }
    }
} 