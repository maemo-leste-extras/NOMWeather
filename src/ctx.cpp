#include <filesystem>

#include <QObject>
#include <QDir>
#include <QStandardPaths>

#include "ctx.h"

#include "settings.h"
#include "lib/utils.h"

using namespace std::chrono;

AppContext::AppContext() {
  configRoot = QDir::homePath();
#ifdef DEBUG
  isDebug = true;
#else
  isDebug = false;
#endif
  homeDir = QDir::homePath();
  configDirectory = QString("%1/.config/%2/").arg(configRoot, QCoreApplication::applicationName());
  createConfigDirectory(configDirectory);

  m_tempType = config()->get(ConfigKeys::SettingsTempType).toString().trimmed();
  emit tempTypeChanged();

  m_weatherTimer = new QTimer(this);
  openMeteo = new OpenMeteo(this);

  connect(openMeteo, &OpenMeteo::statusUpdate, this, &AppContext::onOpenMeteoStatusUpdate);
  connect(openMeteo, &OpenMeteo::dataReady, this, &AppContext::onWeatherUpdated);

  connect(m_weatherTimer, &QTimer::timeout, this, &AppContext::onWeatherTimer);
  m_weatherTimer->setInterval(1000 * 2);
  m_weatherTimer->start();
  this->onWeatherTimer();

  Settings::writeGSettings();
}

void AppContext::onWeatherUpdated() {
  qint64 now = QDateTime::currentDateTime().toSecsSinceEpoch();
  lastWeatherUpdate = now;
}

void AppContext::onWeatherTimer() const {
  qint64 now = QDateTime::currentDateTime().toSecsSinceEpoch();
  if(settingsWindowOpened) return;
  if(lastWeatherUpdate == 0 || (now - lastWeatherUpdate) >= m_weatherUpdateInterval)
    openMeteo->getWeather();
}

void AppContext::onOpenMeteoStatusUpdate(const QString &msg) {
  m_statusText = msg;
  qDebug() << "statusUpdate " << msg;
  emit(statusTextChanged());
}

void AppContext::createConfigDirectory(const QString &dir) {
  QStringList createDirs({dir});
  for(const auto &d: createDirs) {
    if(!std::filesystem::exists(d.toStdString())) {
      qDebug() << QString("Creating directory: %1").arg(d);
      if (!QDir().mkpath(d))
        throw std::runtime_error("Could not create directory " + d.toStdString());
    }
  }
}

AppContext::~AppContext() {}
