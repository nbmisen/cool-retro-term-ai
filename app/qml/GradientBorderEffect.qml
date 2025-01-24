import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Item {
    id: borderEffect
    
    property bool active: false
    
    opacity: active ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { 
            duration: 300
            easing.type: Easing.InOutQuad 
        }
    }

    Rectangle {
        id: gradientMask
        anchors.fill: parent
        color: "transparent"
        border.width: 2
        radius: 2
        Rectangle {
            id: actualBorder
            anchors.fill: parent
            color: "transparent"
            border.color: gradientBorder.currentColor
            border.width: 2
            radius: parent.radius
        }

        LinearGradient {
            id: gradientBorder
            anchors.fill: parent
            visible: true
            source: gradientMask
            opacity: 0.8
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: gradientMask
            }
            
            start: Qt.point(0, 0)
            end: Qt.point(borderEffect.width, borderEffect.height)
            
            property color currentColor: Qt.rgba(0.8, 0.2, 0.2, 0.8)

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: borderEffect.active
                NumberAnimation { 
                    from: 0.8
                    to: 1.0
                    duration: 1500
                    easing.type: Easing.InOutSine
                }
                NumberAnimation { 
                    from: 1.0
                    to: 0.8
                    duration: 1500
                    easing.type: Easing.InOutSine
                }
            }
            
            gradient: Gradient {
                GradientStop { 
                    position: 0.0
                    color: gradientBorder.currentColor
                    SequentialAnimation on color {
                        loops: Animation.Infinite
                        ColorAnimation { 
                            to: Qt.rgba(0.2, 0.8, 0.2, 0.8)
                            duration: 1000
                            onRunningChanged: if(running) gradientBorder.currentColor = Qt.rgba(0.2, 0.8, 0.2, 0.8)
                        }
                        ColorAnimation { 
                            to: Qt.rgba(0.2, 0.2, 0.8, 0.8)
                            duration: 1000
                            onRunningChanged: if(running) gradientBorder.currentColor = Qt.rgba(0.2, 0.2, 0.8, 0.8)
                        }
                        ColorAnimation { 
                            to: Qt.rgba(0.8, 0.2, 0.2, 0.8)
                            duration: 1000
                            onRunningChanged: if(running) gradientBorder.currentColor = Qt.rgba(0.8, 0.2, 0.2, 0.8)
                        }
                    }
                }
                GradientStop { 
                    position: 1.0
                    color: Qt.rgba(0.2, 0.8, 0.8, 0.8)
                    SequentialAnimation on color {
                        loops: Animation.Infinite
                        ColorAnimation { to: Qt.rgba(0.8, 0.2, 0.8, 0.8); duration: 1000 }
                        ColorAnimation { to: Qt.rgba(0.8, 0.8, 0.2, 0.8); duration: 1000 }
                        ColorAnimation { to: Qt.rgba(0.2, 0.8, 0.8, 0.8); duration: 1000 }
                    }
                }
            }
        }
    }

    layer.enabled: true
    layer.effect: Item {
        property real glowRadius: 16

        SequentialAnimation on glowRadius {
            loops: Animation.Infinite
            running: borderEffect.active
            NumberAnimation { 
                from: 16
                to: 20
                duration: 1500
                easing.type: Easing.InOutSine
            }
            NumberAnimation { 
                from: 20
                to: 16
                duration: 1500
                easing.type: Easing.InOutSine
            }
        }

        Rectangle {
            id: maskRect
            anchors.fill: parent
            color: "transparent"
            border.width: 2
            radius: 2
        }

        Glow {
            id: borderGlow
            anchors.fill: parent
            source: actualBorder
            samples: 20
            radius: parent.glowRadius
            color: gradientBorder.currentColor
            spread: 0.3
            cached: true
            opacity: 0.8

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: borderEffect.active
                NumberAnimation { 
                    from: 0.8
                    to: 1.0
                    duration: 1500
                    easing.type: Easing.InOutSine
                }
                NumberAnimation { 
                    from: 1.0
                    to: 0.8
                    duration: 1500
                    easing.type: Easing.InOutSine
                }
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: maskRect.width
                    height: maskRect.height
                    color: "white"
                    border.width: parent.radius * 2
                    radius: maskRect.radius
                }
            }
        }
    }
}