import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import QtQml 2.15
import QtQuick.Controls.Material 2.15
import QtQml.Models 2.15
import CoolRetroTerm 1.0

Item {
    id: root

    signal messageReceived(string message)
    signal errorOccurred(string error)
    signal streamUpdate(string content)
    signal streamEnd()

    property bool isProcessing: aiManager.isProcessing
    property var messageHistory: aiManager.messageHistory

    AIChatManager {
        id: aiManager
        onMessageReceived: root.messageReceived(message)
        onErrorOccurred: root.errorOccurred(error)
        onStreamUpdate: root.streamUpdate(content)
        onStreamEnd: root.streamEnd()
    }

    function sendMessage(message) {
        if (!appSettings.aiApiKey) {
            errorOccurred("API Key not set. Please set it in Settings -> AI tab")
            return
        }

        aiManager.setApiKey(appSettings.aiApiKey)
        aiManager.setBaseUrl(appSettings.aiBaseUrl)
        aiManager.setModelName(appSettings.aiModelName)
        aiManager.setSystemPrompt(appSettings.aiSystemPrompt)
        aiManager.sendMessage(message)
    }

    function clearHistory() {
        aiManager.clearHistory()
    }
} 