#pragma once

#include <QtGlobal>
#include <QResource>
#include <QApplication>
#include <QScreen>
#include <QtWidgets/QMenu>
#include <QMainWindow>
#include <QObject>
#include <QtCore>
#include <QtGui>
#include <QFileInfo>

#include <iostream>

#include "ctx.h"
#include "lib/config.h"

namespace Ui {
  class Settings;
}

class Settings : public QMainWindow {
  Q_OBJECT

public:
  explicit Settings(AppContext *ctx, QWidget *parent = nullptr);
  static AppContext *getContext();
  static void writeGSettings();
  ~Settings() override;
  Ui::Settings *ui;

  bool dirty = false;

signals:
  void textScalingChanged();

private slots:
  void onCityTextChanged(const QString &inp);
  void onCitiesReceived(QVariantList arr);

private:
  AppContext *m_ctx;
  static Settings *pSettings;
  void closeEvent(QCloseEvent *event) override;
  static QString formatCityLabel(QString city, QString country, QString lat, QString lon);
};
