#ifndef AICHATMANAGER_H
#define AICHATMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

class AIChatManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isProcessing READ isProcessing NOTIFY isProcessingChanged)
    Q_PROPERTY(QVariantList messageHistory READ messageHistory NOTIFY messageHistoryChanged)

public:
    explicit AIChatManager(QObject *parent = nullptr);
    
    bool isProcessing() const { return m_isProcessing; }
    QVariantList messageHistory() const { return m_messageHistory; }

public slots:
    void sendMessage(const QString &message);
    void clearHistory();
    void setApiKey(const QString &key) { m_apiKey = key; }
    void setBaseUrl(const QString &url) { m_baseUrl = url; }
    void setModelName(const QString &model) { m_modelName = model; }
    void setSystemPrompt(const QString &prompt) { m_systemPrompt = prompt; }

signals:
    void messageReceived(const QString &message);
    void errorOccurred(const QString &error);
    void streamUpdate(const QString &content);
    void streamEnd();
    void isProcessingChanged();
    void messageHistoryChanged();

private slots:
    void handleNetworkReply();
    void handleReadyRead();

private:
    QNetworkAccessManager *m_networkManager;
    QNetworkReply *m_currentReply;
    bool m_isProcessing;
    QVariantList m_messageHistory;
    QString m_apiKey;
    QString m_baseUrl;
    QString m_modelName;
    QString m_systemPrompt;
    QString m_partialBuffer;

    void processStreamData(const QByteArray &data);
};

#endif // AICHATMANAGER_H 