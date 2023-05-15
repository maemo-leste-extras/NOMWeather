#pragma once

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QLocale>

#include "http.h"
#include "config.h"

class AppContext;
class OpenMeteo : public QObject
{
Q_OBJECT
Q_PROPERTY(QVariantMap data READ data NOTIFY dataReady)
Q_PROPERTY(int tempCMax READ getTempCMax NOTIFY tempCMaxChanged)
Q_PROPERTY(int tempCMin READ getTempCMin NOTIFY tempCMinChanged)
Q_PROPERTY(int tempFMax READ getTempFMax NOTIFY tempFMaxChanged)
Q_PROPERTY(int tempFMin READ getTempFMin NOTIFY tempFMinChanged)
Q_PROPERTY(int windMax READ getWindMax NOTIFY windMaxChanged)
Q_PROPERTY(int windMin READ getWindMin NOTIFY windMinChanged)

public:
  explicit OpenMeteo(QObject *parent = nullptr);

  Q_INVOKABLE void getCities(QString inp);
  Q_INVOKABLE void getWeather();
  Q_INVOKABLE void getLatLonViaNetwork();
  Q_INVOKABLE QString WMO2Icon(int wmo);

  QString name;
  QString country;
  QString lat;
  QString lon;

  [[nodiscard]] QVariantMap data() const { return m_data; }
  [[nodiscard]] int getTempFMax() const { return m_tempFMax; }
  [[nodiscard]] int getTempFMin() const { return m_tempFMin; }
  [[nodiscard]] int getTempCMax() const { return m_tempCMax; }
  [[nodiscard]] int getTempCMin() const { return m_tempCMin; }
  [[nodiscard]] int getWindMax() const { return m_windMax; }
  [[nodiscard]] int getWindMin() const { return m_windMin; }

  static QString weatherString(int wmo);

signals:
  void citiesReceived(QVariantList arr);
  void locationUpdated(QString _name, QString _country, QString _lat, QString _lon);
  void dataReady();
  void tempCMinChanged();
  void tempCMaxChanged();
  void tempFMinChanged();
  void tempFMaxChanged();
  void windMinChanged();
  void windMaxChanged();
  void statusUpdate(QString msg);

public slots:
  void onLatLonReceived(const QJsonDocument& resp);
  void onCitiesReceived(const QJsonDocument& resp);
  void onMeteoReceived(const QJsonDocument& resp);
  void onErrorReceived(QString err);
  void onLocationUpdated(const QString &_name, const QString &_country, const QString &_lat, const QString &_lon);

private:
  HttpClient *m_httpIpv4toLatLon;
  HttpClient *m_httpCities;
  HttpClient *m_httpData;

  QVariantMap m_data;
  int m_tempCMin = 0;
  int m_tempCMax = 10;
  int m_tempFMin = 0;
  int m_tempFMax = 10;
  int m_windMin = 0;
  int m_windMax = 10;
};

