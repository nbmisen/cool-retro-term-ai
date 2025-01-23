#include "aichatmanager.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkRequest>
#include <QDebug>

AIChatManager::AIChatManager(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_currentReply(nullptr)
    , m_isProcessing(false)
{
}

void AIChatManager::sendMessage(const QString &message)
{
    if (m_apiKey.isEmpty()) {
        emit errorOccurred("API Key not set. Please set it in Settings -> AI tab");
        return;
    }

    QVariantMap userMessage;
    userMessage["role"] = "user";
    userMessage["content"] = message;
    m_messageHistory.append(userMessage);
    emit messageHistoryChanged();

    m_isProcessing = true;
    emit isProcessingChanged();

    QNetworkRequest request(QUrl(m_baseUrl + "/chat/completions"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", QString("Bearer %1").arg(m_apiKey).toUtf8());

    QJsonObject data;
    data["model"] = m_modelName;
    data["stream"] = true;

    QJsonArray messages;
    // Add system prompt if available
    if (!m_systemPrompt.isEmpty()) {
        QJsonObject systemMsg;
        systemMsg["role"] = "system";
        systemMsg["content"] = m_systemPrompt;
        messages.append(systemMsg);
    }

    // Add message history
    for (const QVariant &msg : m_messageHistory) {
        QVariantMap msgMap = msg.toMap();
        QJsonObject jsonMsg;
        jsonMsg["role"] = msgMap["role"].toString();
        jsonMsg["content"] = msgMap["content"].toString();
        messages.append(jsonMsg);
    }

    data["messages"] = messages;

    if (m_currentReply) {
        m_currentReply->abort();
        m_currentReply->deleteLater();
    }

    m_currentReply = m_networkManager->post(request, QJsonDocument(data).toJson());
    m_partialBuffer.clear();

    connect(m_currentReply, &QNetworkReply::readyRead, this, &AIChatManager::handleReadyRead);
    connect(m_currentReply, &QNetworkReply::finished, this, &AIChatManager::handleNetworkReply);
}

void AIChatManager::handleReadyRead()
{
    if (!m_currentReply) return;

    QByteArray newData = m_currentReply->readAll();
    processStreamData(newData);
}

void AIChatManager::processStreamData(const QByteArray &data)
{
    m_partialBuffer += QString::fromUtf8(data);
    QStringList lines = m_partialBuffer.split("\n", Qt::SkipEmptyParts);
    
    // Keep the last potentially incomplete line in the buffer
    if (!m_partialBuffer.endsWith("\n")) {
        m_partialBuffer = lines.takeLast();
    } else {
        m_partialBuffer.clear();
    }

    QString currentContent;
    for (const QString &line : lines) {
        QString trimmedLine = line.trimmed();
        if (trimmedLine.startsWith("data: ")) {
            QString jsonStr = trimmedLine.mid(6);
            if (jsonStr == "[DONE]") continue;

            QJsonDocument doc = QJsonDocument::fromJson(jsonStr.toUtf8());
            if (doc.isObject()) {
                QJsonObject obj = doc.object();
                if (obj.contains("choices") && obj["choices"].isArray()) {
                    QJsonArray choices = obj["choices"].toArray();
                    if (!choices.isEmpty()) {
                        QJsonObject delta = choices[0].toObject()["delta"].toObject();
                        if (delta.contains("content")) {
                            QString content = delta["content"].toString();
                            currentContent += content;
                            emit streamUpdate(content);
                        }
                    }
                }
            }
        }
    }
}

void AIChatManager::handleNetworkReply()
{
    m_isProcessing = false;
    emit isProcessingChanged();

    if (!m_currentReply) return;

    if (m_currentReply->error() == QNetworkReply::NoError) {
        // Add the complete assistant message to history
        QVariantMap assistantMessage;
        assistantMessage["role"] = "assistant";
        assistantMessage["content"] = m_partialBuffer;
        m_messageHistory.append(assistantMessage);
        emit messageHistoryChanged();
    } else {
        QString errorMessage = m_currentReply->errorString();
        QByteArray responseData = m_currentReply->readAll();
        
        try {
            QJsonDocument errorDoc = QJsonDocument::fromJson(responseData);
            if (errorDoc.isObject()) {
                QJsonObject errorObj = errorDoc.object();
                if (errorObj.contains("error")) {
                    QJsonObject error = errorObj["error"].toObject();
                    if (error.contains("message")) {
                        errorMessage = error["message"].toString();
                    }
                }
            }
        } catch (...) {
            qDebug() << "Error parsing error response:" << responseData;
        }
        
        emit errorOccurred(errorMessage);
    }

    m_currentReply->deleteLater();
    m_currentReply = nullptr;
}

void AIChatManager::clearHistory()
{
    m_messageHistory.clear();
    emit messageHistoryChanged();
} 