/*
 * Copyright (c) 2013-2014 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef SERVICE_H_
#define SERVICE_H_

#include <bb/Application>
#include <bb/platform/Notification>
#include <bb/system/InvokeManager>
//#include <QtNetwork/QNetworkAccessManager>
#include <QNetworkAccessManager>
#include <QEventLoop>
#include <QObject>
#include <QSettings>
#include <QTimer>
#include "UDSUtil.hpp"
#include <bb/pim/unified/unified_data_source.h>
#include "database.hpp"
#include "UDSUtil.hpp"
#include "HubCache.hpp"
#include "Account.hpp"
class QNetworkReply;
class QNetworkAccessManager;
class QSslError;
class Database;
class QTimer;
namespace bb
{
    namespace platform
    {
        class Notification;
    }
    namespace system
    {
        class ApplicationStartupMode;
        class InvokeManager;
        class InvokeRequest;
        class InvokeTargetReply;
    }
    class Application;
}
class Account;
using bb::Application;
using bb::system::ApplicationStartupMode;
using bb::system::InvokeManager;
using bb::system::InvokeRequest;
using bb::system::InvokeTargetReply;
class QNeworkAccessManager;
class QEventLoop;
typedef QMultiMap<QString, QString> QtPocketParams;
typedef QMap<QString, QString> QtPocketHeaders;
class Service: public QObject
{
    Q_OBJECT
public:
    QMap<QByteArray,QByteArray> replyHeaders;
    Service(Application* app);
    virtual ~Service();
    void initialize();
    void sendSound();
    QTimer *timer;
    void updateTimer();

private slots:
    void handleInvoke(const bb::system::InvokeRequest &);
    void onTimeout();
    void replyReceived(QNetworkReply *reply);
    void sslErrors(QNetworkReply *reply, const QList<QSslError> & errors);

private:

    bb::system::InvokeManager* _invokeManager;
    bb::platform::Notification* m_notify;
    QNetworkAccessManager *manager;
    QEventLoop *loop;
    Database *db;
    Account* _account;
    HubCache* _hubCache;
    UDSUtil* _udsUtil;
    QSettings* _settings;
void populateHub();
    int _itemCounter;
    Application* _app;

    QMutex _initMutex;
    void triggerNotification();
   signals:

        void responseReceived(QByteArray response);

};

#endif /* SERVICE_H_ */
