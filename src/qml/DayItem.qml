import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCharts

Rectangle {
    id: root
    property int customWidth: (width / 4) * 3
    property bool isActive: false
    color: isActive ? parent.daysBgColor : "transparent"
    property string title: ""
    property string temp: ""
    property string img: ""
    property bool loading: true

    signal clicked();
    radius: 8

    ColumnLayout {
        anchors.fill: parent
        spacing: 2

        Rectangle {
            color: "transparent"
            Layout.topMargin: 8
            Layout.preferredWidth: parent.parent.customWidth
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignHCenter

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                text: root.title
                font.pointSize: 18
            }
        }

        Rectangle {
            color: "white"
            Layout.preferredWidth: parent.parent.customWidth
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
        }

        Image {
            Layout.topMargin: 6
            Layout.bottomMargin: 6
            Layout.preferredWidth: parent.parent.customWidth
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
            source: root.img.startsWith("qrc") ? root.img : "qrc:/Main/assets/Glance/" + root.img
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            color: "transparent"
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            Layout.preferredWidth: parent.parent.customWidth
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignHCenter

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                text: root.temp + "°"
                font.pointSize: 16
            }
        }
    }

    MouseArea {
        enabled: !root.loading
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.clicked();
        }
    }
}