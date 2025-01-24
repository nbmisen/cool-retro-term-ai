/*******************************************************************************
* Copyright (c) 2013-2024 "Filippo Scognamiglio"
* https://github.com/Swordfish90/cool-retro-term
*
* This file is part of cool-retro-term.
*
* cool-retro-term is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*******************************************************************************/
import QtQuick 2.15
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQml 2.0

import "Components"

ColumnLayout {
    id: root

    // Add reference to storage
    property var storage: appSettings.storage

    GroupBox {
        Layout.fillWidth: true
        title: qsTr("AI Model Settings")

        GridLayout {
            anchors.fill: parent
            columns: 2

            Label {
                text: qsTr("Base URL")
            }
            TextField {
                id: baseUrlField
                Layout.fillWidth: true
                text: appSettings.aiBaseUrl
                selectByMouse: true
                Keys.onPressed: (event) => {
                    if ((event.key === Qt.Key_A) && (event.modifiers & Qt.ControlModifier)) {
                        baseUrlField.selectAll()
                    }
                }
                onEditingFinished: {
                    storage.setSetting("aiBaseUrl", text)
                    appSettings.aiBaseUrl = text
                }
                placeholderText: "https://api.openai.com/v1"
            }

            Label {
                text: qsTr("Model Name")
            }
            TextField {
                id: modelNameField
                Layout.fillWidth: true
                text: appSettings.aiModelName
                selectByMouse: true
                Keys.onPressed: (event) => {
                    if ((event.key === Qt.Key_A) && (event.modifiers & Qt.ControlModifier)) {
                        modelNameField.selectAll()
                    }
                }
                onEditingFinished: {
                    storage.setSetting("aiModelName", text)
                    appSettings.aiModelName = text
                }
                placeholderText: "gpt-4o"
            }

            Label {
                text: qsTr("API Key")
            }
            TextField {
                id: apiKeyField
                Layout.fillWidth: true
                text: appSettings.aiApiKey
                echoMode: TextInput.Password
                selectByMouse: true
                Keys.onPressed: (event) => {
                    if ((event.key === Qt.Key_A) && (event.modifiers & Qt.ControlModifier)) {
                        apiKeyField.selectAll()
                    }
                }
                onEditingFinished: {
                    storage.setSetting("aiApiKey", text)
                    appSettings.aiApiKey = text
                }
                placeholderText: "sk-..."
            }
        }
    }

    GroupBox {
        Layout.fillWidth: true
        title: qsTr("AI Behavior")

        ColumnLayout {
            anchors.fill: parent

            // CheckBox {
            //     id: streamOutput
            //     text: qsTr("Enable streaming output")
            //     checked: appSettings.aiStreamOutput
            //     onCheckedChanged: {
            //         storage.setSetting("aiStreamOutput", checked.toString())
            //         appSettings.aiStreamOutput = checked
            //     }
            // }

            Label {
                text: qsTr("System Prompt")
            }
            TextArea {
                id: systemPromptField
                Layout.fillWidth: true
                text: appSettings.aiSystemPrompt
                wrapMode: TextEdit.Wrap
                onTextChanged: {
                    storage.setSetting("aiSystemPrompt", text)
                    appSettings.aiSystemPrompt = text
                }
                placeholderText: "Enter system prompt here..."
            }
        }
    }
} 