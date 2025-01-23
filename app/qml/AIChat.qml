import QtQuick 2.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQml 2.0
import QtQuick.Controls.Material 2.0

Item {
    id: root

    signal messageReceived(string message)
    signal errorOccurred(string error)
    signal streamUpdate(string content)

    property bool isProcessing: false
    property var messageHistory: []

    // 用于在 onprogress 时存储尚未处理完的流数据
    property string partialBuffer: ""

    function sendMessage(message) {
        if (!appSettings.aiApiKey) {
            errorOccurred("API Key not set. Please set it in Settings -> AI tab")
            return
        }

        isProcessing = true
        messageHistory.push({"role": "user", "content": message})

        var xhr = new XMLHttpRequest()

        // 调试输出：在数据传输过程中实时打印到控制台（或日志）
        xhr.onprogress = function() {
            // 每次 onprogress 调用时，获取新增加的部分
            var newChunk = xhr.responseText.substr(partialBuffer.length)
            partialBuffer += newChunk

            // 简单地按行分割（注意：OpenAI 通常返回的流是 SSE 格式，可按 "data: " 解析）
            var lines = partialBuffer.split("\n")
            // 逐行处理，由于最后一行可能是不完整的，所以只遍历到倒数第二行
            for (var i = 0; i < lines.length - 1; i++) {
                var line = lines[i].trim()
                console.log("-- Debug stream line:", line) // 调试输出
                // SSE 通常以 "data: " 开头，如需更精确拆分可在此做更详细的处理
                if (line.indexOf("data: ") === 0) {
                    var jsonData = line.slice(6).trim()
                    if (jsonData === "[DONE]") {
                        // 流结束标志
                        console.log("Stream completed.")
                    } else {
                        try {
                            var chunkObj = JSON.parse(jsonData)
                            // 在此处理 chunkObj，例如获取 chunkObj.choices[0].delta.content
                            console.log("Chunk content:", chunkObj.choices[0].delta ? chunkObj.choices[0].delta.content : "")
                            if (chunkObj.choices && chunkObj.choices[0].delta && chunkObj.choices[0].delta.content) {
                                // 发送流式更新信号
                                streamUpdate(chunkObj.choices[0].delta.content)
                            }
                        } catch (e) {
                            console.log("Chunk parse error:", e)
                        }
                    }
                }
            }
            // 将不完整的部分保留到 partialBuffer
            partialBuffer = lines[lines.length - 1]
        }

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isProcessing = false
                // 请求结束后无论成功与否，都先打印所有剩余数据
                console.log("Final response text:", xhr.responseText)

                if (xhr.status === 200) {
                    // 流式返回可能会有多段，这里只处理最终结果
                    // 如果返回的最后有效 JSON 里含有完整内容，可以在此解析并更新 messageHistory
                    var response = JSON.parse(xhr.responseText)
                    // 这里试图获取最终的回答
                    var aiMessage = response.choices ? response.choices[0].message.content : ""
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

        // 如果需要流式返回，请确保 appSettings.aiStreamOutput = true
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