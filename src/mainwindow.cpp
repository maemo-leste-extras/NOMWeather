#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(AppContext *ctx, QWidget *parent) :
    QMainWindow(parent),
    m_ctx(ctx),
    ui(new Ui::MainWindow)
{
  ui->setupUi(this);
#ifdef MAEMO
  this->ui->menuBar->hide();
#endif

  this->screenDpiRef = 128;
  this->screenGeo = QApplication::primaryScreen()->availableGeometry();
  this->screenRect = QGuiApplication::primaryScreen()->geometry();
  this->screenDpi = QGuiApplication::primaryScreen()->logicalDotsPerInch();
  this->screenDpiPhysical = QGuiApplication::primaryScreen()->physicalDotsPerInch();
  this->screenRatio = this->screenDpiPhysical / this->screenDpiRef;
  qDebug() << QString("%1x%2 (%3 DPI)").arg(
      this->screenRect.width()).arg(this->screenRect.height()).arg(this->screenDpi);

  connect(ui->actionSettings, &QAction::triggered, this, &MainWindow::onOpenSettingsWindow);
  connect(ui->actionAbout, &QAction::triggered, this, &MainWindow::onOpenAboutWindow);
  connect(ui->actionExit, &QAction::triggered, this, &MainWindow::onQuitApplication);

  // example set config value
  // config()->set(ConfigKeys::Test, "test2");

  this->createQml();
  this->show();
  emit cppReady();
}

void MainWindow::onOpenAboutWindow() {
  m_about = new About(m_ctx, this);
  m_about->show();
}

void MainWindow::onOpenSettingsWindow() {
  m_settings = new Settings(m_ctx, this);
  m_settings->setAttribute(Qt::WA_DeleteOnClose);
  m_settings->show();
  m_ctx->settingsWindowOpened = true;
  connect(m_settings, &Settings::destroyed, [=](QObject * obj){
    m_ctx->settingsWindowOpened = false;
    if(m_settings->dirty)
      m_ctx->lastWeatherUpdate = 0;
  });
}

void MainWindow::onQuitApplication() {
  this->close();
}

void MainWindow::closeEvent(QCloseEvent *event) {
  //event->ignore();
  QApplication::quit();
}

void MainWindow::createQml() {
  if(m_quickWidget != nullptr) return;
  m_quickWidget = new QQuickWidget(this);
  m_quickWidget->setAttribute(Qt::WA_AlwaysStackOnTop);

  auto *qctx = m_quickWidget->rootContext();
  qctx->setContextProperty("cfg", config());
  qctx->setContextProperty("ctx", m_ctx);
  qctx->setContextProperty("openMeteo", m_ctx->openMeteo);
  qctx->setContextProperty("mainWindow", this);

  m_quickWidget->setSource(QUrl("qrc:/qml/main.qml"));
  m_quickWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);

  connect((QObject*)m_quickWidget->rootObject(), SIGNAL(onExample(int)), this, SLOT(onExample(int)));
  ui->centralWidget->layout()->addWidget(m_quickWidget);

  //onOpenSettingsWindow();
}

void MainWindow::destroyQml() {
  if(m_quickWidget == nullptr) return;
  m_quickWidget->disconnect();
  m_quickWidget->deleteLater();
  m_quickWidget = nullptr;
}

Q_INVOKABLE void MainWindow::nuke_chart_background(QQuickItem *item) {
  // https://stackoverflow.com/questions/59007984/customize-or-define-new-qml-chartview-theme
  if(auto *scene = item->findChild<QGraphicsScene *>()){
    for(QGraphicsItem *it : scene->items()) {
      if(auto *chart = dynamic_cast<QtCharts::QChart *>(it)){
        // Customize chart background
        chart->setBackgroundBrush(Qt::transparent);
        chart->layout()->setContentsMargins(0, 0, 0, 0);
        chart->setBackgroundRoundness(0);
        chart->setPlotAreaBackgroundBrush(Qt::red);
        chart->setPlotAreaBackgroundVisible(false);
      }
    }
  }
}

Q_INVOKABLE void MainWindow::update_series(QAreaSeries *series, QVariantList list, QString graphType) {
  auto lineSeries = new QLineSeries(this);
  lineSeries->setUseOpenGL(true);

  auto numPoints = list.count();
  double xDiv = 1.0 / numPoints;

  QString key;
  QBrush brush;
  QString pointStr;

  if(graphType == "temp") {
    brush = QBrush(QRgb(0x4d431d));
    if(m_ctx->tempType() == "celcius") {
      key = "temp_celcius";
      pointStr = "@yPoint °C";
    } else {
      key = "temp_fahrenheit";
      pointStr = "@yPoint °F";
    }
  } else {
    key = "windspeed_kmph";
    brush = QBrush(QRgb(0x1e3559));
    pointStr = "@yPoint km/h";
  }

  for(int i = 0; i != numPoints; i++) {
    auto obj = list.at(i).toJsonObject();
    double pos = xDiv * i;
    int val = obj.value(key).toInt();
    lineSeries->append(pos, val);
  }

  series->setUpperSeries(lineSeries);

  series->setBrush(brush);
  series->setPointLabelsFormat(pointStr);
  series->setPointLabelsVisible(false);
  series->setPointLabelsColor(Qt::white);
  series->setPointLabelsClipping(false);
  QFont bla;
  bla.setPointSize(16);
  series->setPointLabelsFont(bla);
}

Q_INVOKABLE void MainWindow::nuke_axes(QtCharts::QAbstractAxis *axisX, QtCharts::QAbstractAxis *axisY) {
  axisX->hide();
  axisX->setGridLineColor(Qt::transparent);
  axisX->setLabelsColor(Qt::white);
  axisY->hide();
}

Q_INVOKABLE void MainWindow::silly_animation(QLineSeries *series) {
  //series->setUseOpenGL(true);
  series->clear();
  series->setBrush(QBrush(QRgb(0x4d431d)));

  double yPos = abs(sin(m_sillyAnimationTicks / 8)) * 7;
  yPos += 4.0;
  double yPos2 = abs(yPos - 20);

  for(int i = 0; i != 21; i++) {
    double xPos = (double)i / 20;
    series->append(xPos, i % 2 == 0 ? yPos : yPos2);
  }

  m_sillyAnimationTicks += 1.0;
}

void MainWindow::onExample(int number) {
  qDebug() << "clicked: " + number;
}

MainWindow::~MainWindow() {
  delete ui;
}

