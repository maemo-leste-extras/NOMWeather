#include <cmath>

#include "openmeteo.h"

OpenMeteo::OpenMeteo(QObject *parent) :
  QObject(parent)
{
  m_httpCities = new HttpClient(parent);
  m_httpData = new HttpClient(parent);
  m_httpIpv4toLatLon = new HttpClient(parent);

  connect(m_httpIpv4toLatLon, &HttpClient::requestComplete, this, &OpenMeteo::onLatLonReceived);
  connect(m_httpIpv4toLatLon, &HttpClient::requestFailed, this, &OpenMeteo::onErrorReceived);

  connect(m_httpCities, &HttpClient::requestComplete, this, &OpenMeteo::onCitiesReceived);
  connect(m_httpCities, &HttpClient::requestFailed, this, &OpenMeteo::onErrorReceived);

  connect(m_httpData, &HttpClient::requestComplete, this, &OpenMeteo::onMeteoReceived);
  connect(m_httpData, &HttpClient::requestFailed, this, &OpenMeteo::onErrorReceived);

  connect(this, &OpenMeteo::locationUpdated, this, &OpenMeteo::onLocationUpdated);
}

void OpenMeteo::onLocationUpdated(const QString &_name, const QString &_country, const QString &_lat, const QString &_lon) {
  this->name = _name;
  this->country = _country;
  this->lat = _lat;
  this->lon = _lon;

  auto url = QString("https://api.open-meteo.com/v1/forecast?latitude=%1&longitude=%2&hourly=temperature_2m,precipitation_probability,weathercode,windspeed_10m").arg(lat, lon);
  m_httpData->get(url);
}

void OpenMeteo::getWeather() {
  if(m_httpData->busy) {
    qDebug() << "getWeather() busy, skipping.";
    return;
  }

  emit statusUpdate("Fetching weather");
  auto locationChoice = config()->get(ConfigKeys::SettingsLocationChoice).toString();
  auto locationName = config()->get(ConfigKeys::SettingsLocationName).toString().trimmed();
  auto locationLat = config()->get(ConfigKeys::SettingsLocationLat).toString();
  auto locationLon = config()->get(ConfigKeys::SettingsLocationLon).toString();
  auto locationCountry = config()->get(ConfigKeys::SettingsLocationCountry).toString();
  auto locationAvailable = !locationLat.isEmpty() &&
                           !locationLon.isEmpty() &&
                           !locationName.isEmpty() &&
                           !locationCountry.isEmpty();

  if(locationChoice == "manual") {
    if(locationAvailable) {
      emit locationUpdated(
          locationName, locationCountry,
          locationLat, locationLon
      );
    } else {
      auto msg = "Please specify a location";
      emit statusUpdate(msg);
    }
  } else {
    this->getLatLonViaNetwork();
  }
}

void OpenMeteo::getLatLonViaNetwork() {
  emit statusUpdate("Fetching lat/lon");

  auto url = QString("http://ip-api.com/json");
  m_httpIpv4toLatLon->get(url);
}

void OpenMeteo::getCities(QString inp) {
  if(inp.length() <= 2) return;

  auto url = QString("https://geocoding-api.open-meteo.com/v1/search?name=%1").arg(inp);
  m_httpCities->get(url);
}

void OpenMeteo::onLatLonReceived(const QJsonDocument& resp) {
  emit statusUpdate("lat/lon received");

  auto obj = resp.object();
  auto _lat = QString("%1").arg(obj.value("lat").toDouble());
  auto _lon = QString("%1").arg(obj.value("lon").toDouble());

  emit locationUpdated(
      obj.value("city").toString(),
      obj.value("country").toString(),
      _lat, _lon
  );
}

void OpenMeteo::onErrorReceived(QString msg) {
  qWarning() << msg;
  if(msg.length() >= 16)
    msg = msg.remove(0, 16);
  emit statusUpdate(msg);
}

void OpenMeteo::onMeteoReceived(const QJsonDocument& resp) {
  emit statusUpdate("Weather received");

  auto locale = QLocale("en_US");
  auto obj = resp.object();
  auto hourly = obj.value("hourly").toObject();
  auto hTime = hourly.value("time").toArray();
  auto hTemp2m = hourly.value("temperature_2m").toArray();
  auto hPrecProb = hourly.value("precipitation_probability").toArray();
  auto hWMO = hourly.value("weathercode").toArray();
  auto hWindspeed = hourly.value("windspeed_10m").toArray();

  m_data["name"] = name;
  m_data["country"] = country;
  m_data["lat"] = lat;
  m_data["lon"] = lon;

  // QList<int> hours = {0, 3, 6, 9, 12, 15, 18, 21};

  auto arr = QVariantList();
  auto arrDays = QVariantList();
  QList<int> tempsC;
  QList<int> tempsF;
  QList<int> winds;

  for(int i = 0; i != hTime.count(); i++) {
    QVariantMap _map;

    auto timestampStr = hTime.at(i).toString();
    auto datetime = QDateTime::fromString(timestampStr, "yyyy-MM-ddTHH:mm");
    auto _date = datetime.date();

    auto hour = datetime.time().hour();
    _map["date"] = timestampStr.replace("T", " ");
    _map["year"] = _date.year();
    _map["month"] = _date.month();
    _map["day"] = _date.day();
    _map["dayOfWeek"] = _date.dayOfWeek();
    _map["dayName"] = locale.dayName(_date.dayOfWeek(), QLocale::LongFormat);
    _map["hour"] = hour;
    _map["minute"] = datetime.time().minute();
    _map["epoch_msecs"] = datetime.toMSecsSinceEpoch();
    _map["epoch_secs"] = datetime.toSecsSinceEpoch();

    double temp_celcius_double = hTemp2m.at(i).toDouble();
    int temp_celcius_int = int(floor(temp_celcius_double));
    int temp_fahrenheit_int = int(floor((temp_celcius_double * 1.8) + 32));
    int wind_kmph = floor(hWindspeed.at(i).toDouble());
    tempsC << temp_celcius_int;
    tempsF << temp_fahrenheit_int;
    winds << wind_kmph;

    _map["temp_celcius"] = temp_celcius_int;
    _map["temp_fahrenheit"] = temp_fahrenheit_int;

    _map["precipitation_probability"] = hPrecProb.at(i).toInt();
    _map["wmo"] = hWMO.at(i).toInt();
    _map["wmo_str"] = OpenMeteo::weatherString(hWMO.at(i).toInt());

    _map["windspeed_kmph"] = wind_kmph;
    arr << _map;
  }

  // populate 'days'
  for(auto const val: arr) {
    auto _obj = val.toJsonObject();
    auto hour = _obj.value("hour").toInt();
    auto dayOfWeek = _obj.value("dayOfWeek").toInt();

    if(hour == 15) {
      QVariantMap dayItem;
      dayItem["name"] = locale.dayName(dayOfWeek, QLocale::ShortFormat);
      dayItem["temp_celcius"] = _obj.value("temp_celcius").toInt();
      dayItem["temp_fahrenheit"] = _obj.value("temp_fahrenheit").toInt();
      dayItem["wmo"] = _obj.value("wmo").toInt();
      dayItem["wmo_str"] = _obj.value("wmo_str").toString();
      arrDays << dayItem;
    }
  }

  m_data["items"] = arr;
  m_data["days"] = arrDays;

  auto boundsCTemps = std::minmax_element(tempsC.begin(), tempsC.end());
  m_tempCMin = *boundsCTemps.first;
  m_tempCMax = *boundsCTemps.second;

  auto boundsFTemps = std::minmax_element(tempsF.begin(), tempsF.end());
  m_tempFMin = *boundsFTemps.first;
  m_tempFMax = *boundsFTemps.second;

  auto boundsWinds = std::minmax_element(winds.begin(), winds.end());
  m_windMin = *boundsWinds.first;
  m_windMax = *boundsWinds.second;

  emit tempCMinChanged();
  emit tempCMaxChanged();
  emit tempFMinChanged();
  emit tempFMaxChanged();
  emit windMinChanged();
  emit windMaxChanged();
  emit statusUpdate("Weather");
  emit dataReady();
}

QString OpenMeteo::WMO2Icon(int wmo) {
  QMap<int, QString> map;
  map[0] = "sun";
  map[1] = "30";
  map[2] = "28";
  map[3] = "two_gray_cloud";
  map[45] = "fog";
  map[48] = "fog";
  map[51] = "11";
  map[53] = "40";
  map[55] = "2";
  map[56] = "6";
  map[57] = "7";

  map[61] = "11";
  map[63] = "40";
  map[65] = "2";

  map[66] = "5";
  map[67] = "5";

  map[71] = "13";
  map[73] = "14";
  map[75] = "18";

  map[77] = "18";

  map[80] = "11";
  map[81] = "9";
  map[80] = "12";

  map[85] = "13";
  map[86] = "6";

  map[95] = "4";
  map[96] = "4";
  map[99] = "4";

  if(map.contains(wmo)) {
    return "qrc:///weather/" + map[wmo] + ".png";
  } else {
    return "qrc:///weather/na.png";
  }
}

QString OpenMeteo::weatherString(int wmo) {
  QMap<int, QString> map;
  map[0] = "Clear sky";
  map[1] = "Mainly clear";
  map[2] = "Partly cloudy";
  map[3] = "Overcast";
  map[45] = "Fog";
  map[48] = "Depositing rime fog";
  map[51] = "Drizzle; light";
  map[53] = "Drizzle; moderate";
  map[55] = "Drizzle; dense";
  map[56] = "Freezing drizzle; light";
  map[57] = "Freezing drizzle; dense";

  map[61] = "Rain; slight";
  map[63] = "Rain; moderate";
  map[65] = "Rain; heavy";

  map[66] = "Freezing rain; light";
  map[67] = "Freezing rain; heavy";

  map[71] = "Snow fall; slight";
  map[73] = "Snow fall; moderate";
  map[75] = "Snow fall; heavy";

  map[77] = "Snow grains";

  map[80] = "Rain showers: slight";
  map[81] = "Rain showers: moderate";
  map[80] = "Rain showers: violent";

  map[85] = "Snow showers: slight";
  map[86] = "Snow showers: heavy";

  map[95] = "Thunderstorm";
  map[96] = "Thunderstorm";
  map[99] = "Thunderstorm";

  if(map.contains(wmo)) {
    return map[wmo];
  } else {
    return "unknown";
  }
}

void OpenMeteo::onCitiesReceived(const QJsonDocument& resp) {
  auto obj = resp.object();
  if(!obj.contains("results"))
    qDebug() << "malformed onDataLocationReceived blob, returning";

  auto arr = obj.value("results").toArray();
  QVariantList variantList;

  for(auto val: arr) {
    obj = val.toObject();

    QVariantMap variantMap;
    auto _name = obj.value("name").toString();
    auto _country = obj.value("country").toString();
    auto _lat = obj.value("latitude").toDouble();
    auto _lon = obj.value("longitude").toDouble();

    variantMap["name"] = _name;
    variantMap["country"] = _country;
    variantMap["country_code"] = obj.value("country_code").toString();
    variantMap["timezone"] = obj.value("timezone").toString();
    variantMap["lat"] = _lat;
    variantMap["lon"] = _lon;
    variantList << variantMap;
  }

  emit citiesReceived(variantList);
}

