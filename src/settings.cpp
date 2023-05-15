#include <QPixmap>
#include <QMessageBox>
#include <QDesktopServices>
#include <QCoreApplication>
#include <QSystemTrayIcon>
#include <QQmlContext>
#include <QMessageBox>
#include <QGroupBox>
#include <QFileDialog>
#include <QCheckBox>

#include "settings.h"

#include "ui_settings.h"

Settings * Settings::pSettings = nullptr;

Settings::Settings(AppContext *ctx, QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::Settings),
    m_ctx(ctx) {
  pSettings = this;
  ui->setupUi(this);
  ui->cityLabel->hide();

//#ifdef MAEMO
//  setProperty("X-Maemo-StackedWindow", 1);
//  setProperty("X-Maemo-Orientation", 2);
//#endif
  QPixmap p_theme_irssi(":general_settings.png");
  ui->lbl_image->setPixmap(p_theme_irssi);

  auto settingsLocationChoice = config()->get(ConfigKeys::SettingsLocationChoice).toString();
  if(settingsLocationChoice == "network")
    ui->radio_loc_network->setChecked(true);
  else if(settingsLocationChoice == "manual") {
    ui->radio_loc_manual->setChecked(true);

    auto settingsLocationName = config()->get(ConfigKeys::SettingsLocationName).toString();
    if(!settingsLocationName.isEmpty()) {
      auto country = config()->get(ConfigKeys::SettingsLocationCountry).toString();
      auto lat = config()->get(ConfigKeys::SettingsLocationLat).toString();
      auto lon = config()->get(ConfigKeys::SettingsLocationLon).toString();

      auto lbl = Settings::formatCityLabel(settingsLocationName, country, lat, lon);
      ui->cityLabel->setText(lbl);
      ui->cityLabel->show();
      ui->cityInput->setText(settingsLocationName);
    }
  } else {
    config()->set(ConfigKeys::SettingsLocationChoice, "network");
    ui->radio_loc_network->setChecked(true);
  }

  connect(ui->networkLocationRadioGroup, QOverload<QAbstractButton *>::of(&QButtonGroup::buttonClicked), [=](QAbstractButton *button) {
      auto name = button->objectName();
      if(name == "radio_loc_network") {
        config()->set(ConfigKeys::SettingsLocationChoice, "network");
        dirty = true;
      } else if(name == "radio_loc_manual") {
        config()->set(ConfigKeys::SettingsLocationChoice, "manual");
        dirty = true;
      }
  });

  connect(ui->cityInput, &QLineEdit::textChanged, this, &Settings::onCityTextChanged);
  connect(m_ctx->openMeteo, &OpenMeteo::citiesReceived, this, &Settings::onCitiesReceived);
}

QString Settings::formatCityLabel(
    QString city, QString country, QString lat, QString lon) {
  auto lblText = QString("City: %1\nCountry: %2\nLat: %3 Lon: %4").arg(city, country, lat, lon);
  return lblText;
}

void Settings::onCitiesReceived(QVariantList arr) {
  if(!arr.length()) return;

  QVariantMap obj = arr.at(0).toMap();
  auto city = obj["name"].toString();
  auto country = obj["country"].toString();
  auto lat = obj["lat"].toString();
  auto lon = obj["lon"].toString();

  config()->set(ConfigKeys::SettingsLocationName, city);
  config()->set(ConfigKeys::SettingsLocationCountry, country);
  config()->set(ConfigKeys::SettingsLocationLat, lat);
  config()->set(ConfigKeys::SettingsLocationLon, lon);

  auto lblText = Settings::formatCityLabel(city, country, lat, lon);
  ui->cityLabel->setText(lblText);
  dirty = true;
}

void Settings::onCityTextChanged(const QString &inp) {
  if(inp.isEmpty()) {
    ui->cityLabel->hide();
    return;
  }

  ui->cityLabel->show();
  if(inp.length() <= 2) {
    ui->cityLabel->setText("Searching requires at least 3 characters");
    return;
  }

  ui->cityLabel->setText("Searching...");
  m_ctx->openMeteo->getCities(inp);
}

AppContext *Settings::getContext(){
  return pSettings->m_ctx;
}

void Settings::closeEvent(QCloseEvent *event) {
  QWidget::closeEvent(event);
}

Settings::~Settings() {
  delete ui;
}
