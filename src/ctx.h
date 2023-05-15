#pragma once

#include <QObject>
#include <QMainWindow>
#include <QCoreApplication>
#include <QJsonDocument>
#include <QMessageBox>
#include <QTimer>
#include <QDebug>
#include <QQueue>
#include <QThread>
#include <QGraphicsScene>
#include <QtQuick>
#include <QtWidgets>
#include <QtCharts>
#include <QMutex>

#include "lib/config.h"
#include "lib/openmeteo.h"


class AppContext : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)
  Q_PROPERTY(QString tempType READ tempType WRITE setTempType NOTIFY tempTypeChanged)

public:
  explicit AppContext();
  ~AppContext() override;

  bool isDebug;
  QString preloadModel;
  QString configDirectory;
  QString configRoot;
  QString homeDir;

  OpenMeteo *openMeteo;

  QString statusText() { return m_statusText; }
  QString tempType() { return m_tempType; }
  void setTempType(QString tempType) {
    config()->set(ConfigKeys::SettingsTempType, tempType);
    m_tempType = tempType;
    emit tempTypeChanged();
  }

  qint64 lastWeatherUpdate = 0;
  bool settingsWindowOpened = false;

signals:
  void statusTextChanged();
  void tempTypeChanged();

private slots:
  void onOpenMeteoStatusUpdate(const QString &msg);
  void onWeatherUpdated();
  void onWeatherTimer() const;

private:
  QString m_tempType = "celcius";
  QString m_statusText = "Loading";
  QTimer *m_weatherTimer;

  int m_weatherUpdateInterval = 600;  // update weather data per X seconds

  static void createConfigDirectory(const QString &dir);
};
