import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCharts

import "."

Rectangle {
    id: root
    anchors.fill: parent

    property string graphType: "temp"
    property bool graphLoading: false
    property string backgroundColor: "#202124"

    property string borderColorTemp: "#fdd663"
    property string borderColorWind: "#8ab4f8"
    property string areaColorTemp: "#4d431d"
    property string areaColorWind: "#1e3559"

    property string borderColor: graphType === "temp" ? borderColorTemp : borderColorWind
    property string areaColor: graphType === "temp" ? areaColorTemp : areaColorWind

    property string textInactiveColor: "grey"
    property string textActiveColor: "white"

    property int cDay: 0
    property int cHour: 0

    property alias metaIcon: metaIcon
    property alias metaLocationStr: metaLocationStr
    property alias metaPrecStr: metaPrecStr
    property alias metaWindStr: metaWindStr

    property alias metaTempStr: metaTempStr
    property alias metaWMOStr: metaWMOStr
    property alias metaDateStr: metaDateStr

    property alias dayButton1: dayButton1
    property alias dayButton2: dayButton2
    property alias dayButton3: dayButton3
    property alias dayButton4: dayButton4
    property alias dayButton5: dayButton5
    property alias dayButton6: dayButton6
    property alias dayButton7: dayButton7
    property var dayButtons: [root.dayButton1, root.dayButton2, root.dayButton3, root.dayButton4, root.dayButton5, root.dayButton6, root.dayButton7]

    visible: true
    property bool loading: true

    color: backgroundColor
    signal onExample(int idx)

    function setTempType(val) {
        mainWindow.setLoadingText(true);
        ctx.tempType = val;
        areaFlick.fillGraphTexts();
        root.gotoTime(root.cDay, root.cHour);
        mainWindow.setLoadingText(false);
    }

    function gotoTime(day, hour, force) {
        if(day === 0 && !force)
            hour = new Date().getHours();

        const dataIdx = (day * 24) + hour;
        const obj = openMeteo.data.items[dataIdx];
        if(obj === undefined) return;

        // areaFlick
        areaFlick.gotoTime(day, hour);

        // global vars (dirty)
        root.cDay = day
        root.cHour = hour

        // highlight the correct day button
        dayButton1.isActive = day === 0;
        dayButton2.isActive = day === 1;
        dayButton3.isActive = day === 2;
        dayButton4.isActive = day === 3;
        dayButton5.isActive = day === 4;
        dayButton6.isActive = day === 5;
        dayButton7.isActive = day === 6;

        // set header
        root.metaTempStr.text = ctx.tempType === "celcius" ? obj.temp_celcius : obj.temp_fahrenheit;
        root.metaWMOStr.text = obj.wmo_str;
        root.metaDateStr.text = obj.dayName + " " + obj.hour + ":00";
        root.metaPrecStr.text = "Precipitation: " + obj.precipitation_probability + "%";
        root.metaWindStr.text = "Wind: " + obj.windspeed_kmph + " km/h";
        root.metaLocationStr.text = openMeteo.data.name + ", " + openMeteo.data.country;
        root.metaIcon.source = "qrc:/Main/assets/Glance/" + openMeteo.WMO2Icon(obj.wmo);
    }

    ColumnLayout {
        id: headerContainer
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.topMargin: 16
            Layout.bottomMargin: 8
            Layout.leftMargin: 8
            Layout.rightMargin: 32
            Layout.preferredHeight: 128
            Layout.maximumHeight: 128
            Layout.preferredWidth: parent.width
            spacing: 0

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: (headerContainer.width / 3) * 2
                Layout.fillHeight: true
                spacing: 0

                RowLayout {
                    id: tempHeaderContainer
                    spacing: 0
                    property int itemHeight: 76
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.preferredHeight: tempHeaderContainer.itemHeight
                    Layout.maximumHeight: tempHeaderContainer.itemHeight

                    RowLayout {
                        spacing: 0
                        Layout.fillWidth: true
                        Layout.preferredHeight: tempHeaderContainer.itemHeight
                        Layout.maximumHeight: tempHeaderContainer.itemHeight

                        Image {
                            id: metaIcon
                            Layout.preferredHeight: tempHeaderContainer.itemHeight
                            Layout.preferredWidth: tempHeaderContainer.itemHeight
                            source: "qrc:/Main/assets/Glance/na.png"
                            fillMode: Image.PreserveAspectFit
                        }

                        Rectangle {
                            color: "transparent"
                            Layout.preferredHeight: tempHeaderContainer.itemHeight
                            Layout.preferredWidth: 102

                            Text {
                                id: metaTempStr
                                anchors.top: parent.top
                                anchors.topMargin: -8
                                anchors.horizontalCenter: parent.horizontalCenter
                                font.pointSize: 52
                                color: root.textActiveColor
                                text: "0"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        RowLayout {
                            Layout.preferredHeight: tempHeaderContainer.itemHeight
                            Layout.fillWidth: true
                            spacing: 0

                            Rectangle {
                                property bool isActive: ctx.tempType === "celcius"
                                Layout.preferredHeight: tempHeaderContainer.itemHeight
                                Layout.preferredWidth: 68
                                Layout.rightMargin: 4
                                color: "transparent"

                                Text {
                                    text: "°C"
                                    font.pointSize: 32
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: parent.isActive ? root.textActiveColor: root.textInactiveColor
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        root.setTempType("celcius");
                                    }
                                }
                            }

                            ColumnLayout {
                                spacing: 0
                                Layout.preferredHeight: tempHeaderContainer.itemHeight
                                Layout.preferredWidth: 1

                                Rectangle {
                                    Layout.preferredHeight: 56
                                    Layout.preferredWidth: 1
                                    color: root.textInactiveColor
                                }

                                Item {
                                    Layout.preferredWidth: 1
                                    Layout.fillHeight: true
                                }
                            }

                            Rectangle {
                                property bool isActive: ctx.tempType === "fahrenheit"
                                Layout.preferredHeight: tempHeaderContainer.itemHeight
                                Layout.preferredWidth: 68
                                Layout.rightMargin: 6
                                color: "transparent"

                                Text {
                                    color: parent.isActive ? root.textActiveColor: root.textInactiveColor
                                    text: "°F"
                                    font.pointSize: 32
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        root.setTempType("fahrenheit");
                                    }
                                }
                            }

                            ColumnLayout {
                                spacing: 0
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 24
                                    color: "transparent"

                                    Text {
                                        id: metaLocationStr
                                        color: root.textInactiveColor
                                        text: "-"
                                        font.pointSize: 16

                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 24
                                    color: "transparent"

                                    Text {
                                        id: metaPrecStr
                                        color: root.textInactiveColor
                                        text: "-"
                                        font.pointSize: 16

                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 24
                                    color: "transparent"

                                    Text {
                                        id: metaWindStr
                                        color: root.textInactiveColor
                                        text: "-"
                                        font.pointSize: 16

                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.preferredHeight: 32
                    spacing: 0

                    ColumnLayout {
                        id: tempHeaderBtnContainer
                        property bool isActive: true
                        Layout.preferredWidth: tempHeaderBtnText.implicitWidth
                        Layout.fillHeight: true
                        spacing: 0

                        Rectangle {
                            Layout.preferredWidth: parent.Layout.preferredWidth
                            Layout.fillHeight: true
                            color: "transparent"

                            Text {
                                id: tempHeaderBtnText
                                color: tempHeaderBtnContainer.isActive ? root.textActiveColor : root.textInactiveColor
                                text: "Temperature"
                                font.pointSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: !root.loading
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onClicked: {
                                    if(root.graphLoading || root.graphType === "temp") return;
                                    root.graphLoading = true;
                                    mainWindow.setLoadingText(true);

                                    root.graphType = "temp";
                                    tempHeaderBtnContainer.isActive = true;
                                    windHeaderBtnContainer.isActive = false;
                                    areaFlick.redrawChart();
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: parent.Layout.preferredWidth
                            Layout.preferredHeight: 5
                            color: tempHeaderBtnContainer.isActive ? root.borderColor : "transparent"
                        }
                    }

                    Rectangle {
                        // grey border
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 24
                        Layout.topMargin: -6
                        color: root.textInactiveColor
                    }

                    ColumnLayout {
                        id: windHeaderBtnContainer
                        property bool isActive: false
                        Layout.preferredWidth: windHeaderBtnText.implicitWidth
                        Layout.fillHeight: true
                        spacing: 0

                        Rectangle {
                            Layout.preferredWidth: parent.Layout.preferredWidth
                            Layout.fillHeight: true
                            color: "transparent"

                            Text {
                                id: windHeaderBtnText
                                color: windHeaderBtnContainer.isActive ? root.textActiveColor : root.textInactiveColor
                                text: "wind (km/h)"
                                font.pointSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: !root.loading
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onClicked: {
                                    if(root.graphLoading || root.graphType === "wind") return;
                                    root.graphLoading = true;
                                    mainWindow.setLoadingText(true);

                                    root.graphType = "wind";
                                    tempHeaderBtnContainer.isActive = false;
                                    windHeaderBtnContainer.isActive = true;
                                    areaFlick.redrawChart();
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: parent.Layout.preferredWidth
                            Layout.preferredHeight: 5
                            color: windHeaderBtnContainer.isActive ? root.borderColor : "transparent"
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: (headerContainer.width / 3) * 1
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    Layout.bottomMargin: 4
                    color: "transparent"

                    Text {
                        text: ctx.statusText
                        color: root.textActiveColor
                        font.pointSize: 26

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    color: "transparent"

                    Text {
                        id: metaDateStr
                        text: "-"
                        color: root.textInactiveColor
                        font.pointSize: 18

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    color: "transparent"

                    Text {
                        id: metaWMOStr
                        text: "-"
                        color: root.textInactiveColor
                        font.pointSize: 18

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }

        AreaFlick {
            id: areaFlick
            loading: root.loading
            graphType: root.graphType
            Layout.bottomMargin: 52
            Layout.preferredHeight: 100
            Layout.preferredWidth: parent.width
            areaColor: root.areaColor
            borderColor: root.borderColor
            textActiveColor: root.textActiveColor
            textInactiveColor: root.textInactiveColor

            onDataItemClicked: {
                root.gotoTime(day, hour, true);
            }

            onDrawn: {
                mainWindow.setLoadingText(false);
                root.graphLoading = false;
            }
        }

        RowLayout {
            id: daysContainer
            Layout.topMargin: 16
            Layout.bottomMargin: 8
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            Layout.maximumHeight: 140
            property string daysBgColor: "#424348"
            spacing: 16

            Connections {
                target: openMeteo

                function onDataReady() {
                    root.loading = false;

                    var i = 0;
                    root.dayButtons.forEach((component) => {
                        let obj = openMeteo.data.days[i];
                        component.title = obj.name;
                        component.temp = obj.temp_celcius;
                        component.img = openMeteo.WMO2Icon(obj.wmo);
                        i += 1;
                    });

                    root.gotoTime(0, 15);
                }
            }

            function makeActive(idx) {
                root.gotoTime(idx, 15);
            }

            DayItem {
                id: dayButton1
                loading: root.loading
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "-"
                temp: "0"
                img: "qrc:/Main/assets/Glance/na.png"
                isActive: true
                onClicked: daysContainer.makeActive(0);
            }

            DayItem {
                id: dayButton2
                loading: root.loading
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "-"
                temp: "0"
                img: "qrc:/Main/assets/Glance/na.png"
                onClicked: daysContainer.makeActive(1);
            }

            DayItem {
                id: dayButton3
                loading: root.loading
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "-"
                temp: "0"
                img: "qrc:/Main/assets/Glance/na.png"
                onClicked: daysContainer.makeActive(2);
            }

            DayItem {
                id: dayButton4
                loading: root.loading
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "-"
                temp: "0"
                img: "qrc:/Main/assets/Glance/na.png"
                onClicked: daysContainer.makeActive(3);
            }

            DayItem {
                id: dayButton5
                loading: root.loading
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "-"
                temp: "0"
                img: "qrc:/Main/assets/Glance/na.png"
                onClicked: daysContainer.makeActive(4);
            }

            DayItem {
                id: dayButton6
                loading: root.loading
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "-"
                temp: "0"
                img: "qrc:/Main/assets/Glance/na.png"
                onClicked: daysContainer.makeActive(5);
            }

            DayItem {
                id: dayButton7
                loading: root.loading
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "-"
                temp: "0"
                img: "qrc:/Main/assets/Glance/na.png"
                onClicked: daysContainer.makeActive(6);
            }
        }

        Rectangle {
            visible: false
            color: "orange"
            Layout.preferredHeight: 100
            Layout.preferredWidth: parent.width
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
