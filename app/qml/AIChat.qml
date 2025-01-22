import QtQuick 2.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQml 2.0
import QtQuick.Controls.Material 2.0

Item {
    id: root

    signal messageReceived(string message)
    signal errorOccurred(string error)

    property bool isProcessing: false
    property var messageHistory: []

    function sendMessage(message) {
        if (!appSettings.aiApiKey) {
            errorOccurred("API Key not set. Please set it in Settings -> AI tab")
            return
        }

        isProcessing = true
        messageHistory.push({"role": "user", "content": message})

        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isProcessing = false
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText)
                    var aiMessage = response.choices[0].message.content
                    messageHistory.push({"role": "assistant", "content": aiMessage})
                    messageReceived(aiMessage)
                } else {
                    var errorMsg = "Error: " + xhr.status + " " + xhr.statusText
                    try {
                        var error = JSON.parse(xhr.responseText)
                        if (error.error && error.error.message) {
                            errorMsg = error.error.message
                        }
                    } catch(e) {}
                    errorOccurred(errorMsg)
                }
            }
        }

        xhr.open("POST", appSettings.aiBaseUrl + "/chat/completions")
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("Authorization", "Bearer " + appSettings.aiApiKey)

        var data = {
            "model": appSettings.aiModelName,
            "messages": [
                {"role": "system", "content": appSettings.aiSystemPrompt},
                ...messageHistory
            ],
            "stream": appSettings.aiStreamOutput
        }

        xhr.send(JSON.stringify(data))
    }

    function clearHistory() {
        messageHistory = []
    }
} 