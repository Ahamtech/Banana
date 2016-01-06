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

#include "service.hpp"

#include <errno.h>
#include <malloc.h>
#include <spawn.h>
#include <unistd.h>
#include <QDebug>
#include <QtNetwork>
#include <QSslError>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QMap>
#include <QUrl>
#include <QEventLoop>
#include <QStringList>
#include <bb/data/JsonDataAccess>
#include <bb/system/InvokeManager>
#include <bb/system/InvokeRequest>
#include <bb/system/InvokeTargetReply>
#include <QSqlQuery>
#include <QDateTime>
#include<QTimer>

using namespace bb::data;

using namespace bb::platform;
using namespace bb::system;

Service::Service(Application* app) :
        QObject(), m_notify(new Notification(this)), _account(NULL), _hubCache(NULL), _udsUtil(
        NULL), _settings(NULL), _itemCounter(0), _app(app), _invokeManager(new InvokeManager()), manager(
                new QNetworkAccessManager), loop(new QEventLoop), db(new Database(this)), timer(
                new QTimer(this))
{
    bool started = false;
    bool connectResult;
    if (!db->_database.open()) {
        db->initDatabase();
    }
    _invokeManager->connect(_invokeManager, SIGNAL(invoked(const bb::system::InvokeRequest&)), this,
            SLOT(handleInvoke(const bb::system::InvokeRequest&)));
    qDebug() << "HeadlessHubIntegration: HeadlessHubIntegration";

    _invokeManager->setParent(this);

    switch (_invokeManager->startupMode()) {
        case ApplicationStartupMode::LaunchApplication:
            qDebug() << "HeadlessHubIntegration: Regular application launch";
            break;
        case ApplicationStartupMode::InvokeApplication:
            qDebug() << "HeadlessHubIntegration: Launching app from invoke";
            break;
        case ApplicationStartupMode::InvokeCard:
            qDebug() << "HeadlessHubIntegration: Launching card from invoke";
            break;
            // enable when 10.3 beta is released
        case ApplicationStartupMode::InvokeHeadless:
            qDebug() << "HeadlessHubIntegration: Launching headless from invoke";
            started = true;
            break;
        default:
            qDebug() << "HeadlessHubIntegration: other launch: " << _invokeManager->startupMode();
            break;
    }

    // enable when 10.3 beta is released
    //if (_invokeManager->startupMode() == ApplicationStartupMode::InvokeHeadless) {
    if (started) {
        initialize();
    }

    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyReceived(QNetworkReply*)));
    connect(manager, SIGNAL(sslErrors(QNetworkReply*,QList<QSslError>)), this,
            SLOT(sslErrors(QNetworkReply*,QList<QSslError>)));
    connect(manager, SIGNAL(finished(QNetworkReply*)), loop, SLOT(quit()));

    connect(timer, SIGNAL(timeout()), this, SLOT(update()));
    timer->start(1000);
}
Service::~Service()
{
    qDebug() << "HeadlessHubIntegration: ~HeadlessHubIntegration";

    // don't need to delete _invokeManager since this is its parent it will be
    // killed appropriately by Qt

    if (_account) {
        delete _account;
    }
    if (_hubCache) {
        delete _hubCache;
    }
    if (_settings) {
        delete _settings;
    }
    if (_udsUtil) {
        delete _udsUtil;
    }
}
void Service::handleInvoke(const bb::system::InvokeRequest & request)
{
    qDebug() << request.action();
    if (request.action().compare("in.ahamtech.BananaService.RESET") == 0) {
        triggerNotification();
    }
    if (request.action().compare("in.ahamtech.BananaService.REMOVE") == 0) {
        int count = db->getTableSizeByQuery(
                "select count(*) from settings where type = \"id\" or type = \"name\"");
        QVariantList list = _account->items();
        foreach(QVariant data,list){
        QVariantMap map = data.value<QVariantMap>();
        qint64 conv = 1;
        qint64 remid = map.value("sourceId").toLongLong();
        _account->removeHubItem(qint64(1),remid);
    }
        _account->updateAccount("desc", "");
    }
    if (request.action().compare("in.ahamtech.BananaService.ADD") == 0) {
        QSqlQuery query = db->executeSqlQuery("select value from settings where type = \"name\"");
        while (query.next())
            _account->updateAccount("desc", query.value(0).toString());
        qDebug() << query.value(0).toString();
        populateHub();
    }
    if (request.action().compare("in.ahamtech.BananaService.SETTINGS") == 0) {

    }
    if (request.action().compare("bb.action.MARKREAD") == 0) {
        qDebug() << "bb.action.MarKread";
        bb::data::JsonDataAccess jda;
        QVariantMap objectMap = (jda.loadFromBuffer(request.data())).toMap();
        QVariantMap attributesMap = objectMap["attributes"].toMap();
        attributesMap["readCount"] = 1;
        qint64 itemdid = attributesMap.value("sourceId").toLongLong();
        _account->updateHubItem(1, itemdid, attributesMap, false);
    }
}

void Service::initialize()
{
    qDebug() << "HeadlessHubIntegration: initialize: " << (_udsUtil != NULL);

//    _initMutex.lock();
//
//    // initialize UDS
//    if (!_udsUtil) {
//        _udsUtil = new UDSUtil(QString("bananaService"), QString("hubassets"));
//    }
//
//    if (!_udsUtil->initialized()) {
//        _udsUtil->initialize();
//    }
//
//    if (_udsUtil->initialized() && _udsUtil->registered()) {
//        if (!_settings) {
//            _settings = new QSettings("Banana", "Hub Integration");
//        }
//        if (!_hubCache) {
//            _hubCache = new HubCache(_settings);
//        }
//        if (!_account) {
//            _account = new Account(_udsUtil, _hubCache);
//        }
//
//        qDebug() << "HeadlessHubIntegration: initialize: initialized " << (_udsUtil != NULL);
//    }
//
//    _initMutex.unlock();
}

void Service::triggerNotification()
{
    // Timeout is to give time for UI to minimize
    QTimer::singleShot(2000, this, SLOT(onTimeout()));
}

void Service::onTimeout()
{
    Notification::clearEffectsForAll();
    Notification::deleteAllFromInbox();
    m_notify->notify();
}

void Service::replyReceived(QNetworkReply *reply)
{

    switch (reply->error()) {
        case QNetworkReply::NoError:
//        d->error = QtPocket::NoError;
            break;

        case QNetworkReply::ContentAccessDenied:
        case QNetworkReply::ContentOperationNotPermittedError:
        case QNetworkReply::AuthenticationRequiredError:
        case QNetworkReply::ProtocolFailure:
//        d->error = QtPocket::RequestUnauthorized;
            break;

        default:
//        d->error = QtPocket::NetworkError;
            break;
    }

    QVariant errorCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QString errorString = reply->errorString();
//    qDebug() << d->errorCode << d->errorString;
    QByteArray replyString = reply->readAll();
    qDebug() << QString::fromAscii(replyString) << "bytearrraydata";
    // Reply headers
    QList<QByteArray> headers = reply->rawHeaderList();
    foreach(const QByteArray &header, headers){
    replyHeaders.insert(header, reply->rawHeader(header));

}
    qDebug() << QString(replyString);
    emit responseReceived(replyString);
    reply->deleteLater();
}

void Service::sslErrors(QNetworkReply *reply, const QList<QSslError> & errors)
{
    reply->ignoreSslErrors(errors);
}

void Service::populateHub()
{
    qDebug() << "this is populating the data";
    if (db->_database.open()) {
        qDebug() << "no problem with data base openning";
        QVariant projectresults = db->executeQuery(
                "select * from tasks where completed = \"false\"");
        QVariantList projectslist = projectresults.value<QVariantList>();
        QVariantList h_list = _account->items();
        qDebug()<<"hub list size"<<h_list.size();
        foreach(QVariant data, h_list) {
                       QVariantMap h_map = data.value<QVariantMap>();

                           qDebug() << "hub item id "<<h_map.value("id").toString()<<h_map.contains("id");

        }

//        if (h_list.size() > 0) {
//
//            //deleting  the hub item
//
//            foreach(QVariant h_data,h_list){
//            QVariantMap h_map = h_data.value<QVariantMap>();
//            bool isItemPresent=false;
//            Q_UNUSED(isItemPresent);
//            foreach(QVariant data, projectslist) {
//                QVariantMap map = data.value<QVariantMap>();
//                if(h_map.value("id")!=map.value("id")) {
//                    qDebug() << "this item is not present in the database remove"<<h_map.value("id").toString();
//                    isItemPresent=true;
//                    continue;
//                }
//
//            }
//
//            if(isItemPresent) {
//                qDebug() << "remove function is called"<<h_map.value("id").toString();
//                _account->removeHubItem(qint64(1),h_map.value("id").value<qint64>());
//
//            }
//
//        }
//
//        //insertion or updating the hub item
//
//        foreach(QVariant data, projectslist) {
//            QVariantMap map = data.value<QVariantMap>();
//            foreach(QVariant h_data,h_list) {
//                QVariantMap h_map = h_data.value<QVariantMap>();
//                if((map.value("id")==h_map.value("id"))) {
//                    //update the hub item
//                    foreach(QVariant data,h_list) {
//                        QVariantMap map = data.value<QVariantMap>();
//                        qint64 conv = 1;
//                        map["readCount"] = 1;
//                        qint64 itemdid = map.value("sourceId").toLongLong();
//                        _account->updateHubItem(conv, itemdid , map, false);
//                    }
//                }
//                else {
//                    //addidng the hub item
//                    _account->addHubItem(
//                            qint64(1),
//                            map,map.value("name").toString(),
//                            map.value("name").toString(),
//                            qint64(map.value("modified").toLongLong()),
//                            map.value("id").toString(),
//                            map.value("name").toString(),
//                            "",
//                            false);
//                }
//            }
//
//        }
//    } //end of if(h_list>0)
//    else { //adding hub items at first
//        qDebug() << "No Items In Hub so please ";
//        foreach(QVariant data, projectslist) {
//            QVariantMap map = data.value<QVariantMap>();
//            _account->addHubItem(
//                    qint64(1),
//                    map,map.value("name").toString(),
//                    map.value("name").toString(),
//                    qint64(map.value("modified").toLongLong()),
//                    map.value("id").toString(),
//                    map.value("name").toString(),
//                    "",
//                    false);
//        }
//        QVariantList h_list = _account->items();
//        foreach(QVariant data,h_list) {
//            QVariantMap map = data.value<QVariantMap>();
//            qint64 conv = 1;
//            map["readCount"] = 0;
//            qint64 itemdid = map.value("sourceId").toLongLong();
//            _account->updateHubItem(conv, itemdid , map, false);
//        }
//    }
}
}

void Service::sendSound()
{

    m_notify->notify();
}
void Service::updateTimer()
{
    int t_value = db->getTableSizeByQuery(
            QString("select count(*) from settings where type = \"time\""));
    if (t_value > 0) {
        QVariant t_data = db->executeQuery(
                QString("select value from settings where type = \"time\""));
        QVariantList list = t_data.value<QVariantList>();
        QVariant time_value = list[0];
        QVariantMap map = time_value.value<QVariantMap>();
        if (timer->isActive()) {
            timer->setInterval(map.value("value").toInt());

        } else {
            timer->start(map.value("value").toInt());
        }

    } else {
        if (timer->isActive()) {
            timer->setInterval(1000 * 180);

        } else {
            timer->start(1000 * 180);
        }

    }
}
