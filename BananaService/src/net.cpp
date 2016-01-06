#include "net.h"
#include <QtNetwork>
#include <QSslError>
#include <QMap>
#include <QUrl>
#include <QEventLoop>
Net::Net(QObject *parent) :
        QObject(parent), manager(new QNetworkAccessManager), loop(new QEventLoop)
{

    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyReceived(QNetworkReply*)));
    connect(manager, SIGNAL(sslErrors(QNetworkReply*,QList<QSslError>)), this,
            SLOT(sslErrors(QNetworkReply*,QList<QSslError>)));
    connect(manager, SIGNAL(finished(QNetworkReply*)), loop, SLOT(quit()));
//    connect(QNetworkReply,SIGNAL(error( QNetworkReply::NetworkError)),this,SLOT(onError(QNetworkReply::NetworkError)));
}

Net::~Net()
{
}

void Net::executeRequest(const QUrl &requestUrl, const QString &httpMethod,
        const NetParams &requestParams)
{
    QNetworkRequest request(requestUrl);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    if (!requestParams.isEmpty()) {
        Q_FOREACH(QString key,requestParams.keys()){
        qDebug() << key << " : -- : " << requestParams.value(key);
    }
    manager->post(request, paramsToByteArray(requestParams));
    qDebug()<< "url is "<<request.url().toString();
} else {
    manager->post(request, QByteArray());
}
}

QByteArray Net::paramsToByteArray(const NetParams &params)
{
    QByteArray postParams;
    NetParams::const_iterator i = params.constBegin();
    while (i != params.end()) {
        postParams += i.key() + "=" + i.value() + "&";
        ++i;
    }
    postParams.chop(1);
    return postParams;
}



void Net::replyReceived(QNetworkReply *reply)
{
    switch (reply->error()) {
        case QNetworkReply::NoError:
        break;
        case QNetworkReply::ContentAccessDenied:
        case QNetworkReply::ContentOperationNotPermittedError:
        case QNetworkReply::AuthenticationRequiredError:
        case QNetworkReply::ProtocolFailure:
            break;
        default:
            break;
    }

    int errorCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QString errorString = reply->errorString();
    qDebug() << errorCode << errorString;
    QByteArray data = reply->readAll();
    qDebug() << QString::fromAscii(data) << "bytearrraydata";
        // Reply headers
        QList < QByteArray > headers = reply->rawHeaderList();
        foreach(const QByteArray &header, headers){
        replyHeaders.insert(header, reply->rawHeader(header));
    }

    reply->deleteLater();
}

void Net::sslErrors(QNetworkReply *reply, const QList<QSslError> & errors)
{
    reply->ignoreSslErrors(errors);
}
void Net::onError(QNetworkReply::NetworkError e_code){
    //handle errors here

}
