#pragma once

#include <iostream>

#include <QMainWindow>
#include <QCompleter>
#include <QPushButton>
#include <QClipboard>
#include <QStringListModel>
#include <QTimer>
#include <QQuickWidget>
#include <QQuickView>
#include <QQmlContext>
#include <QQmlEngine>
#include <QDebug>
#include <QQueue>
#include <QThread>
#include <QMutex>

#include "ctx.h"
#include "about.h"
#include "settings.h"
#include "mainwindow.h"
#include "lib/utils.h"

namespace Ui {
  class MainWindow;
}

class AppContext;
class MainWindow : public QMainWindow
{
  Q_OBJECT

public:
  explicit MainWindow(AppContext *ctx, QWidget *parent = nullptr);
  void setupUIModels();
  void queueTask();
  void setupCompleter();

  Q_INVOKABLE void setLoadingText(bool loading) {
    setWindowTitle(loading ? "NOMWeather (loading)" : "NOMWeather");
  }

  ~MainWindow();

  qreal screenDpiRef;
  QRect screenGeo;
  QRect screenRect;
  qreal screenDpi;
  qreal screenDpiPhysical;
  qreal screenRatio;

  Q_INVOKABLE void silly_animation(QLineSeries *series);
  Q_INVOKABLE void nuke_chart_background(QQuickItem *item);
  Q_INVOKABLE void nuke_axes(QtCharts::QAbstractAxis *axisX, QtCharts::QAbstractAxis *axisY);
  Q_INVOKABLE void update_series(QAreaSeries *series, QVariantList list, QString graphType);

public slots:
  void onOpenSettingsWindow();
  void onOpenAboutWindow();
  void onQuitApplication();

private slots:
  void onExample(int number);

signals:
  void cppReady();

protected:
  void closeEvent(QCloseEvent *event) override;

private:
  Ui::MainWindow *ui;
  AppContext *m_ctx = nullptr;
  double m_sillyAnimationTicks = 40.0;

  QQuickWidget *m_quickWidget = nullptr;
  About *m_about = nullptr;
  Settings *m_settings = nullptr;

  void createQml();
  void destroyQml();
};
