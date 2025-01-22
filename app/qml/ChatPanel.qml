import QtQuick 2.2
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Rectangle {
    id: root
    color: "#2b2b2b"

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
                    text: model.message
                    color: "white"
                    width: parent.width - 20
                    anchors.centerIn: parent
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                    textFormat: Text.StyledText
                    readOnly: true
                    selectByMouse: true
                    selectedTextColor: "white"
                    selectionColor: "#666666"
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
                background: Rectangle {
                    color: "#3b3b3b"
                    radius: 4
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