#include <QApplication>
#include <QResource>
#include <QtCore>
#include <QSslSocket>

#if defined(Q_OS_LINUX) && defined(STATIC)
Q_IMPORT_PLUGIN(QXcbIntegrationPlugin)
#endif

#include <unistd.h>
#include <sys/types.h>
#include "mainwindow.h"
#include "ctx.h"

int main(int argc, char *argv[]) {
  qDebug() << "Qt version:" << qVersion();

  qputenv("QML_DISABLE_DISK_CACHE", "1");
  QApplication::setApplicationName("nomweather");
  QApplication::setOrganizationDomain("kroket.io");
  QApplication::setOrganizationName("Kroket Ltd.");
  QApplication app(argc, argv);

  qDebug() << "SSL version: " << QSslSocket::sslLibraryVersionString();
  qDebug() << "SSL build: " << QSslSocket::sslLibraryBuildVersionString();

  auto *ctx = new AppContext();
  ctx->isDebug = false;
  auto *mainWindow = new MainWindow(ctx);

  QDirIterator qrc(":", QDirIterator::Subdirectories);
  while(qrc.hasNext())
    qDebug() << qrc.next();

  return QApplication::exec();
}
