import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCharts

Flickable {
    id: root
    interactive: false
    boundsBehavior: Flickable.StopAtBounds
    contentHeight: contentItem.childrenRect.height
    contentWidth: contentItem.childrenRect.width

    signal dataItemClicked(int day, int hour);
    signal drawn();

    property alias chart: chart
    property var cached_data: {};
    property string graphType: "temp"
    property var textContainerObject;

    property var dynamicTextObjects: new Array(168).fill(null)
    property var dynamicTextXPositions: new Array(168).fill(0)

    property bool loading: true
    property string areaColor: ""
    property string borderColor: ""
    property string textInactiveColor: ""
    property string textActiveColor: ""

    function redrawChart() {
        root.onDataReady();
    }

    function gotoTime(day, hour) {
        const dataIdx = (day * 24) + hour;
        root.animateGraph(day);
        root.highlightGraphItem(dataIdx);
    }

    function animateGraph(dayOfWeek) {
        let xPos = chart.width / 7;
        xPos *= dayOfWeek;

        if(xPos === 0)
          xPos = 32;
        else
          xPos -= 32;

        areaFlick.contentX = xPos;
    }

    Rectangle {
        z: parent.z + 5
        width: 8
        height: parent.height
        color: "#202124"
        anchors.left: parent.left
    }

    Behavior on contentX {
        NumberAnimation {
            id: areaFlickscrollAnimation
            easing.type: Easing.OutCirc;
            duration: 0
        }
    }

    RowLayout {
        spacing: 0
        anchors.left: parent.left

        ChartView {
            id: chart
            plotArea: Qt.rect(chart.x, chart.y, chart.width, chart.height)

            antialiasing: true
            legend.visible: false

            Layout.preferredWidth: root.loading ? root.width + 100 : 870*7
            Layout.preferredHeight: 100

            DateTimeAxis {
                id: valueAxisx
                //min: new Date(1970, 1, 1, 18, 0, 0, 0)
                //max: new Date(1970, 1, 2, 18, 0, 0, 0)
                format: "hh:mm"
                //tickCount: 17
                //labelsFont:Qt.font({
                //    pointSize: 26
                //})
                tickCount: 3
                labelsVisible: false
            }

            ValueAxis {
                id: valueAxisy
                min: 0
                max: 22
                labelsVisible: false
            }

            AreaSeries {
                id: area
                name: "area"
                borderColor: root.borderColor
                color: root.areaColor
                borderWidth: 4
                axisX: valueAxisx
                axisY: valueAxisy

                upperSeries: LineSeries {
                    id: series
                }
            }

            Timer {
                id: sillyAnimationTimer
                interval: 80
                running: root.loading
                repeat: true
                onTriggered: {
                    mainWindow.silly_animation(series);
                }
            }

            Component.onCompleted: {
                mainWindow.nuke_chart_background(chart);
                mainWindow.nuke_axes(area.axisX, area.axisY);
            }

            MouseArea {
                enabled: !root.loading
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    // highlight item detection
                    const pos = mapToItem(parent, mouse.x, mouse.y);

                    const closest = dynamicTextXPositions.reduce((a, b) => {
                        return Math.abs(b - pos.x) < Math.abs(a - pos.x) ? b : a;
                    });

                    const itemIdx = root.dynamicTextXPositions.indexOf(closest);
                    const obj = root.cached_data[itemIdx];

                    const day = Math.floor(itemIdx/24);
                    const hour = obj.hour;

                    root.dataItemClicked(day, hour);
                }
            }

            Item {
                id: graphTextOverlay
                anchors.fill: parent
                z: parent.z + 2

                Text { id: dynamicTextObject3; color: "white"; z: 999; y: 0; x: 92.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject3; x: 92.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject6; color: "white"; z: 999; y: 0; x: 201.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject6; x: 201.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject9; color: "white"; z: 999; y: 0; x: 310.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject9; x: 310.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject12; color: "white"; z: 999; y: 0; x: 419.0; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject12; x: 419.0; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject15; color: "white"; z: 999; y: 0; x: 527.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject15; x: 527.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject18; color: "white"; z: 999; y: 0; x: 636.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject18; x: 636.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject21; color: "white"; z: 999; y: 0; x: 745.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject21; x: 745.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject24; color: "white"; z: 999; y: 0; x: 854.0; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject24; x: 854.0; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject27; color: "white"; z: 999; y: 0; x: 962.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject27; x: 962.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject30; color: "white"; z: 999; y: 0; x: 1071.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject30; x: 1071.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject33; color: "white"; z: 999; y: 0; x: 1180.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject33; x: 1180.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject36; color: "white"; z: 999; y: 0; x: 1289.0; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject36; x: 1289.0; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject39; color: "white"; z: 999; y: 0; x: 1397.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject39; x: 1397.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject42; color: "white"; z: 999; y: 0; x: 1506.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject42; x: 1506.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject45; color: "white"; z: 999; y: 0; x: 1615.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject45; x: 1615.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject48; color: "white"; z: 999; y: 0; x: 1724.0; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject48; x: 1724.0; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject51; color: "white"; z: 999; y: 0; x: 1832.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject51; x: 1832.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject54; color: "white"; z: 999; y: 0; x: 1941.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject54; x: 1941.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject57; color: "white"; z: 999; y: 0; x: 2050.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject57; x: 2050.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject60; color: "white"; z: 999; y: 0; x: 2159.0; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject60; x: 2159.0; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject63; color: "white"; z: 999; y: 0; x: 2267.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject63; x: 2267.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject66; color: "white"; z: 999; y: 0; x: 2376.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject66; x: 2376.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject69; color: "white"; z: 999; y: 0; x: 2485.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject69; x: 2485.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject72; color: "white"; z: 999; y: 0; x: 2594.0; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject72; x: 2594.0; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject75; color: "white"; z: 999; y: 0; x: 2702.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject75; x: 2702.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject78; color: "white"; z: 999; y: 0; x: 2811.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject78; x: 2811.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject81; color: "white"; z: 999; y: 0; x: 2920.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject81; x: 2920.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject84; color: "white"; z: 999; y: 0; x: 3029.0; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject84; x: 3029.0; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject87; color: "white"; z: 999; y: 0; x: 3137.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject87; x: 3137.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject90; color: "white"; z: 999; y: 0; x: 3246.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject90; x: 3246.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject93; color: "white"; z: 999; y: 0; x: 3355.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject93; x: 3355.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject96; color: "white"; z: 999; y: 0; x: 3464.0; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject96; x: 3464.0; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject99; color: "white"; z: 999; y: 0; x: 3572.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject99; x: 3572.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject102; color: "white"; z: 999; y: 0; x: 3681.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject102; x: 3681.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject105; color: "white"; z: 999; y: 0; x: 3790.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject105; x: 3790.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject108; color: "white"; z: 999; y: 0; x: 3899.0; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject108; x: 3899.0; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject111; color: "white"; z: 999; y: 0; x: 4007.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject111; x: 4007.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject114; color: "white"; z: 999; y: 0; x: 4116.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject114; x: 4116.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject117; color: "white"; z: 999; y: 0; x: 4225.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject117; x: 4225.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject120; color: "white"; z: 999; y: 0; x: 4334.0; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject120; x: 4334.0; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject123; color: "white"; z: 999; y: 0; x: 4442.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject123; x: 4442.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject126; color: "white"; z: 999; y: 0; x: 4551.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject126; x: 4551.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject129; color: "white"; z: 999; y: 0; x: 4660.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject129; x: 4660.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject132; color: "white"; z: 999; y: 0; x: 4769.0; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject132; x: 4769.0; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject135; color: "white"; z: 999; y: 0; x: 4877.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject135; x: 4877.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject138; color: "white"; z: 999; y: 0; x: 4986.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject138; x: 4986.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject141; color: "white"; z: 999; y: 0; x: 5095.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject141; x: 5095.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject144; color: "white"; z: 999; y: 0; x: 5204.0; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject144; x: 5204.0; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject147; color: "white"; z: 999; y: 0; x: 5312.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject147; x: 5312.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject150; color: "white"; z: 999; y: 0; x: 5421.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject150; x: 5421.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject153; color: "white"; z: 999; y: 0; x: 5530.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject153; x: 5530.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject156; color: "white"; z: 999; y: 0; x: 5639.0; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject156; x: 5639.0; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject159; color: "white"; z: 999; y: 0; x: 5747.75; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject159; x: 5747.75; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject162; color: "white"; z: 999; y: 0; x: 5856.5; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject162; x: 5856.5; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}
                Text { id: dynamicTextObject165; color: "white"; z: 999; y: 0; x: 5965.25; font.bold: false; font.pointSize: 20; text: "";}
                Text { id: dynamicTextDateObject165; x: 5965.25; y: 104; font.bold: false; font.pointSize: 18; text: ""; color: "grey";}

                Component.onCompleted: {
                    dynamicTextObjects[3] = [dynamicTextObject3, dynamicTextDateObject3];
                    dynamicTextObjects[6] = [dynamicTextObject6, dynamicTextDateObject6];
                    dynamicTextObjects[9] = [dynamicTextObject9, dynamicTextDateObject9];
                    dynamicTextObjects[12] = [dynamicTextObject12, dynamicTextDateObject12];
                    dynamicTextObjects[15] = [dynamicTextObject15, dynamicTextDateObject15];
                    dynamicTextObjects[18] = [dynamicTextObject18, dynamicTextDateObject18];
                    dynamicTextObjects[21] = [dynamicTextObject21, dynamicTextDateObject21];
                    dynamicTextObjects[24] = [dynamicTextObject24, dynamicTextDateObject24];
                    dynamicTextObjects[27] = [dynamicTextObject27, dynamicTextDateObject27];
                    dynamicTextObjects[30] = [dynamicTextObject30, dynamicTextDateObject30];
                    dynamicTextObjects[33] = [dynamicTextObject33, dynamicTextDateObject33];
                    dynamicTextObjects[36] = [dynamicTextObject36, dynamicTextDateObject36];
                    dynamicTextObjects[39] = [dynamicTextObject39, dynamicTextDateObject39];
                    dynamicTextObjects[42] = [dynamicTextObject42, dynamicTextDateObject42];
                    dynamicTextObjects[45] = [dynamicTextObject45, dynamicTextDateObject45];
                    dynamicTextObjects[48] = [dynamicTextObject48, dynamicTextDateObject48];
                    dynamicTextObjects[51] = [dynamicTextObject51, dynamicTextDateObject51];
                    dynamicTextObjects[54] = [dynamicTextObject54, dynamicTextDateObject54];
                    dynamicTextObjects[57] = [dynamicTextObject57, dynamicTextDateObject57];
                    dynamicTextObjects[60] = [dynamicTextObject60, dynamicTextDateObject60];
                    dynamicTextObjects[63] = [dynamicTextObject63, dynamicTextDateObject63];
                    dynamicTextObjects[66] = [dynamicTextObject66, dynamicTextDateObject66];
                    dynamicTextObjects[69] = [dynamicTextObject69, dynamicTextDateObject69];
                    dynamicTextObjects[72] = [dynamicTextObject72, dynamicTextDateObject72];
                    dynamicTextObjects[75] = [dynamicTextObject75, dynamicTextDateObject75];
                    dynamicTextObjects[78] = [dynamicTextObject78, dynamicTextDateObject78];
                    dynamicTextObjects[81] = [dynamicTextObject81, dynamicTextDateObject81];
                    dynamicTextObjects[84] = [dynamicTextObject84, dynamicTextDateObject84];
                    dynamicTextObjects[87] = [dynamicTextObject87, dynamicTextDateObject87];
                    dynamicTextObjects[90] = [dynamicTextObject90, dynamicTextDateObject90];
                    dynamicTextObjects[93] = [dynamicTextObject93, dynamicTextDateObject93];
                    dynamicTextObjects[96] = [dynamicTextObject96, dynamicTextDateObject96];
                    dynamicTextObjects[99] = [dynamicTextObject99, dynamicTextDateObject99];
                    dynamicTextObjects[102] = [dynamicTextObject102, dynamicTextDateObject102];
                    dynamicTextObjects[105] = [dynamicTextObject105, dynamicTextDateObject105];
                    dynamicTextObjects[108] = [dynamicTextObject108, dynamicTextDateObject108];
                    dynamicTextObjects[111] = [dynamicTextObject111, dynamicTextDateObject111];
                    dynamicTextObjects[114] = [dynamicTextObject114, dynamicTextDateObject114];
                    dynamicTextObjects[117] = [dynamicTextObject117, dynamicTextDateObject117];
                    dynamicTextObjects[120] = [dynamicTextObject120, dynamicTextDateObject120];
                    dynamicTextObjects[123] = [dynamicTextObject123, dynamicTextDateObject123];
                    dynamicTextObjects[126] = [dynamicTextObject126, dynamicTextDateObject126];
                    dynamicTextObjects[129] = [dynamicTextObject129, dynamicTextDateObject129];
                    dynamicTextObjects[132] = [dynamicTextObject132, dynamicTextDateObject132];
                    dynamicTextObjects[135] = [dynamicTextObject135, dynamicTextDateObject135];
                    dynamicTextObjects[138] = [dynamicTextObject138, dynamicTextDateObject138];
                    dynamicTextObjects[141] = [dynamicTextObject141, dynamicTextDateObject141];
                    dynamicTextObjects[144] = [dynamicTextObject144, dynamicTextDateObject144];
                    dynamicTextObjects[147] = [dynamicTextObject147, dynamicTextDateObject147];
                    dynamicTextObjects[150] = [dynamicTextObject150, dynamicTextDateObject150];
                    dynamicTextObjects[153] = [dynamicTextObject153, dynamicTextDateObject153];
                    dynamicTextObjects[156] = [dynamicTextObject156, dynamicTextDateObject156];
                    dynamicTextObjects[159] = [dynamicTextObject159, dynamicTextDateObject159];
                    dynamicTextObjects[162] = [dynamicTextObject162, dynamicTextDateObject162];
                    dynamicTextObjects[165] = [dynamicTextObject165, dynamicTextDateObject165];
                }
            }

            Rectangle {
                color: root.areaColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: parent.Layout.preferredHeight - height
                height: 4
                z: parent.z + 1
            }
        }
    }

    Connections {
        target: mainWindow

        function onCppReady() {
            areaFlick.contentX = 32;
            areaFlickscrollAnimation.duration = 500;  // activate graph animations
        }
    }

    function getGraphMinMax() {
        var vMin;
        var vMax;

        if(root.graphType === "temp") {
            if(ctx.tempType === "celcius") {
                vMin = openMeteo.tempCMin;
                vMax = openMeteo.tempCMax;
            } else {
                vMin = openMeteo.tempFMin;
                vMax = openMeteo.tempFMax;
            }
        } else if(root.graphType === "wind") {
            vMax = openMeteo.windMax;
            vMin = openMeteo.windMin;
        }

        return [vMin, vMax]
    }

    function onDataReady() {  // new temperature data received
        // for more control, populate the series via C++
        mainWindow.update_series(area, root.cached_data, root.graphType);

        // set graph range
        let v = getGraphMinMax();
        let vMin = v[0];
        let vMax = v[1];
        valueAxisy.max = vMax + 8;
        valueAxisy.min = vMin - 6;

        // dynamically overlay text on the graph
        root.fillGraphTexts();
        root.drawn();
    }

    Connections {
        target: openMeteo
        onDataReady: {
            root.cached_data = JSON.parse(JSON.stringify(openMeteo.data.items));  // dirty deep-copy
            root.onDataReady()
        }
    }

    function highlightGraphItem(idx) {
        for(var i = 0; i !== dynamicTextObjects.length; i++) {
            if(dynamicTextObjects[i] === null) continue;
            dynamicTextObjects[i][0].color = root.textInactiveColor;
            dynamicTextObjects[i][1].color = root.textInactiveColor;
        }
        if(dynamicTextObjects[idx] !== null) {
            dynamicTextObjects[idx][0].color = root.textActiveColor;
            dynamicTextObjects[idx][1].color = root.textActiveColor;
        }
    }

    function calcPercentage(value, lowerBound, upperBound) {
        if (value <= lowerBound) {
            return 0.0;
        } else if (value >= upperBound) {
            return 100.0;
        } else {
            var rangeWidth = upperBound - lowerBound;
            var percentage = ((value - lowerBound) / rangeWidth) * 100;
            return percentage;
        }
    }

    function fillGraphTexts() {
        var itemWidth = chart.Layout.preferredWidth / root.cached_data.length;
        var chartHeight = chart.height - 32;

        var color = root.textInactiveColor;
        var text_pointSize = 20;
        var text_bold = "false";
        var date_pointSize = 18;
        var date_bold = "false";

        let v = getGraphMinMax();
        let vMin = v[0];
        let vMax = v[1];

        for(var i = 0; i !== 168; i++) {
            if (i === 0) continue;  // skip first label
            let obj = root.cached_data[i];

            // limit the graph texts to these hours
            if(![0, 3, 6, 9, 12, 15, 18, 21].includes(obj.hour)) continue;

            let val = 0;
            if(root.graphType === "temp") {
                val = ctx.tempType === "celcius" ? obj.temp_celcius : obj.temp_fahrenheit;
            } else if(root.graphType === "wind") {
                val = obj.windspeed_kmph;
            }

            // temperature text "wave" effect in the graph
            let xPos = (itemWidth * i) - 16;
            let yPos = 38;
            let yPerc = parseInt(calcPercentage(val, vMin, vMax));
            if(yPerc > 0) {
                let offset = (50 / 100) * yPerc;
                yPos -= offset;
                if(yPos <= 0) yPos = 0;
            }

            dynamicTextXPositions[i] = xPos;

            root.dynamicTextObjects[i][0].text = val;
            root.dynamicTextObjects[i][0].y = yPos;
            root.dynamicTextObjects[i][1].text = root.cached_data[i].hour + ":00";
        }
    }
}
