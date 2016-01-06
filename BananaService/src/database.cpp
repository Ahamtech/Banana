/*
 * database.cpp
 *
 *  Created on: 17-Dec-2014
 *      Author: perl
 */
#include "database.hpp"
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlRecord>
#include <QtSql/QSqlError>

#include <QtSql/QtSql>
#include <QDate>
#include <QDebug>
#include <QObject>
#include <bb/cascades/GroupDataModel>
#include <bb/data/SqlDataAccess>
using namespace bb::cascades;
using namespace bb::data;

//class bb::cascades::GroupDataModel;
Database::Database(QObject *parent) :
        QObject(parent), DB_PATH("./data/Banana.db")
{
    sqlda = new SqlDataAccess(DB_PATH);
    qDebug() << "thisi is the DB" << DB_PATH;
}
Database::~Database()
{
}
bool Database::openDatabase()
{
    _database = QSqlDatabase::addDatabase("QSQLITE");
    _database.setDatabaseName(DB_PATH);
    qDebug() << _database.isValid();
    qDebug() << _database.open();
    bool ok = _database.open();
    return ok;
}
bool Database::initDatabase()
{ //call this method with the name of the database with
    if (openDatabase()) {
        qDebug() << "Banana database  created";
        QString authsTable =
                "create table if not exists settings(type varchar primary key unque,value varchar)";
          QSqlQuery queryAuths(authsTable);

        qDebug() << " auths table created" << queryAuths.isActive();

        return true;
    } else
        return false;
}

QVariant Database::executeQuery(QString q)
{
    return sqlda->execute(q);
}
QSqlQuery Database::executeSqlQuery(QString q)
{
    QSqlQuery query(q);
    qDebug() << "delete query is called" << query.isValid();
    return query;
}

//GroupDataModel * Database::getQueryModel(QString query)
//{
//    GroupDataModel *model = new GroupDataModel(QStringList());
//    QVariant data = sqlda->execute(query);
//    model->insertList(data.value<QVariantList>());
//    return model;
//}
int Database::getTableSizeByQuery(QString query){
    QSqlQuery q;
     q.prepare(query);
     if(q.exec()){
         int rows= 0;
              if (q.next()) {
                     rows= q.value(0).toInt();
              }
              return rows;
     }
     else qDebug()<<q.lastError();
}
int Database::getTableSize(QString tabname){
    QSqlQuery q;
     q.prepare(QString("SELECT COUNT (*) FROM %1").arg(tabname));
     if(q.exec()){
         int rows= 0;
              if (q.next()) {
                     rows= q.value(0).toInt();
              }
              return rows;
     }
     else qDebug()<<q.lastError();
};

bool Database::insertQuery(QString query,QVariantMap bind){
    sqlda->execute(query,bind);
    return sqlda->hasError();
}
