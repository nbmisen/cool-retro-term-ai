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
import QtQuick 2.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQml 2.0

import "Components"

ColumnLayout {
    id: root

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
                onEditingFinished: appSettings.aiBaseUrl = text
                placeholderText: "https://api.openai.com/v1"
            }

            Label {
                text: qsTr("Model Name")
            }
            TextField {
                id: modelNameField
                Layout.fillWidth: true
                text: appSettings.aiModelName
                onEditingFinished: appSettings.aiModelName = text
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
                onEditingFinished: appSettings.aiApiKey = text
                placeholderText: "sk-..."
            }
        }
    }

    GroupBox {
        Layout.fillWidth: true
        title: qsTr("AI Behavior")

        ColumnLayout {
            anchors.fill: parent

            CheckBox {
                id: streamOutput
                text: qsTr("Enable streaming output")
                checked: appSettings.aiStreamOutput
                onCheckedChanged: appSettings.aiStreamOutput = checked
            }

            Label {
                text: qsTr("System Prompt")
            }
            TextArea {
                id: systemPromptField
                Layout.fillWidth: true
                text: appSettings.aiSystemPrompt
                wrapMode: TextEdit.Wrap
                onEditingFinished: appSettings.aiSystemPrompt = text
                placeholderText: "Enter system prompt here..."
            }
        }
    }
} 