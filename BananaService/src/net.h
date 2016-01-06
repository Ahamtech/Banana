/*
 *	Net - A Pocket.com library for Qt
 *
 *	Copyright (c) 2014 Zoltán Benke (benecore@devpda.net)
 *                      	 http://devpda.net
 *
 *	The MIT License (MIT)
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy of
 *	this software and associated documentation files (the "Software"), to deal in
 *	the Software without restriction, including without limitation the rights to
 *	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 *	the Software, and to permit persons to whom the Software is furnished to do so,
 *	subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in all
 *	copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef NET_H
#define NET_H
#include <QObject>
#include <QUrl>
#include <QMultiMap>
#include <QMap>
#include <QNetworkAccessManager>
#include <QNetworkReply>
 #include <QEventLoop>
class QNetworkReply;
class QNetworkAccessManager;
class QSslError;
class QEventLoop;

typedef QMultiMap<QString, QString> NetParams;
typedef QMap<QString, QString> NetHeaders;


class Net: public QObject
{
    Q_OBJECT
public:
    Net(QObject *parent);
    QEventLoop *loop;
    virtual ~Net();

    QNetworkAccessManager* manager;
    NetHeaders replyHeaders;
    QByteArray paramsToByteArray(const NetParams &params);
    void executeRequest(const QUrl &requestUrl, const QString &httpMethod,
            const NetParams &requestParams);


    signals:
private slots:
    void replyReceived(QNetworkReply *reply);
    void sslErrors(QNetworkReply *reply, const QList<QSslError> & errors);
    void onError(QNetworkReply::NetworkError e_code);
private:
};

#endif // NET_H
