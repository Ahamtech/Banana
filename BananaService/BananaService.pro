APP_NAME = BananaService

CONFIG += qt warn_on

include(config.pri)

LIBS += -lbb -lbbsystem -lbbdata -lbbnetwork -lunifieddatasourcec -lbbpim -lbbplatform

QT += network sql