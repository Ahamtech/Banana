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
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(DB_PATH);
    qDebug() << db.isValid();
    qDebug() << db.open();
    bool ok = db.open();
    return ok;
}
bool Database::initDatabase()
{ //call this method with the name of the database with
    if (openDatabase()) {
        qDebug() << "PaperClip database  created";

        QString settingsTable =
                "create table if not exists settings(type varchar primary key unique,value varchar)";
        QSqlQuery queryAuths(settingsTable);

        qDebug() << " settings table created" << queryAuths.isActive();

        QString workspaceTable =
                "create table if not exists workspace(id number primary key unique,name varchar,ringtone varchar,led varchar)";
        QSqlQuery queryWorkspace(workspaceTable);

        qDebug() << "workspace table created" << queryWorkspace.isActive();

        QString projectsTable =
                "create table if not exists projects(id number primary key unique,name varchar,workspace number,created number,modified number,notes varchar,archive boolean,color varchar,lastupdate varchar)";
        QSqlQuery queryProjects(projectsTable);

        qDebug() << " projects table created" << queryProjects.isActive();

        QString usersTable =
                "create table if not exists users(id number primary key unique,name varchar,email varchar,workid number)";
        QSqlQuery queryUsers(usersTable);

        qDebug() << " users table created" << queryUsers.isActive();

        QString tasksTable =
                "create table if not exists tasks(id number primary key unique,name varchar,created number,modified number,notes varchar,completed boolean,completeddate number,due varchar,assignee number,assigneestatus varchar,fav varchar,workid number)";
        QSqlQuery queryTasks(tasksTable);

        qDebug() << " tasks table created" << queryTasks.isActive();

        QString subtasksTable =
                "create table if not exists subtasks(id number primary key unique,parentid varchar not null)";
        QSqlQuery querySubTasks(subtasksTable);

        qDebug() << " subtasks table created" << querySubTasks.isActive();

        QString tasksfollowersTable =
                "create table if not exists tasksfollowers(userid number,taskid number)";
        QSqlQuery querytasksfollowers(tasksfollowersTable);
        qDebug() << " tasksfollowers table created" << querytasksfollowers.isActive();

        QString membershipTable =
                "create table if not exists membership(taskid number,projectid number,sectionid number)";
        QSqlQuery querymembership(membershipTable);
        qDebug() << " membership table created" << querymembership.isActive();

        QString sectionmetaTable =
                "create table if not exists sectionmeta(id number primary key unique,name varchar)";
        QSqlQuery querysectionmeta(sectionmetaTable);
        qDebug() << " sectionmeta table created" << querysectionmeta.isActive();

        QString tagsmetaTable =
                "create table if not exists tagsmeta(id number primary key unique,name varchar,workid number)";
        QSqlQuery querytagsmeta(tagsmetaTable);
        qDebug() << " tagsmeta table created" << querytagsmeta.isActive();

        QString tagsTable = "create table if not exists tags(tagid number,taskid number)";
        QSqlQuery querytags(tagsTable);
        qDebug() << " tags table created" << querytags.isActive();

        QString favTable = "create table if not exists fav(taskid number,userid number)";
        QSqlQuery queryfav(favTable);
        qDebug() << " fav table created" << queryfav.isActive();

        QString tempprojectTable = "create table if not exists tempproject(id number)";
        QSqlQuery tempproject(tempprojectTable);
        qDebug() << " tempprojectTable table created" << tempproject.isActive();
        QString temptasktable = "create table if not exists temptask(id number)";
        QSqlQuery temptask(temptasktable);
        qDebug() << " temptasktable table created" << temptask.isActive();

        QString tempworkspacetable = "create table if not exists tempworkspace(id number)";
        QSqlQuery tempworkspace(tempworkspacetable);
        qDebug() << " tempworkspace table created" << tempworkspace.isActive();

        QString projectmembers =
                "create table if not exists projectmembers(projectid number,userid number)";
        QSqlQuery projectmembersq(projectmembers);
        qDebug() << " projectmembers table created" << projectmembersq.isActive();

        QString projectfollowers =
                "create table if not exists projectfollowers(projectid number,userid number)";
        QSqlQuery projectfollowersq(projectfollowers);
        qDebug() << " projectfollowers table created" << projectfollowersq.isActive();

        QString project2task =
                "create table if not exists project2task(projectid number,taskid number)";
        QSqlQuery project2taskq(project2task);
        qDebug() << " project2task table created" << project2taskq.isActive();
        QString user2workspace =
                "create table if not exists user2workspace(userid number,workid number)";
        QSqlQuery user2workspaceq(user2workspace);
        qDebug() << " user2workspace table created" << user2workspaceq.isActive();

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
    return query;
}

GroupDataModel * Database::getQueryModel(QString query)
{
    GroupDataModel *model = new GroupDataModel(QStringList());
    QVariant data = sqlda->execute(query);
    model->insertList(data.value<QVariantList>());
    return model;
}
int Database::getTableSizeByQuery(QString query)
{
    QSqlQuery q;
    q.prepare(query);
    if (q.exec()) {
        int rows = 0;
        if (q.next()) {
            rows = q.value(0).toInt();
        }
        return rows;
    } else
        qDebug() << q.lastError();
}
int Database::getTableSize(QString tabname)
{
    QSqlQuery q;
    q.prepare(QString("SELECT COUNT (*) FROM %1").arg(tabname));
    if (q.exec()) {
        int rows = 0;
        if (q.next()) {
            rows = q.value(0).toInt();
        }
        return rows;
    } else
        qDebug() << q.lastError();
}
;

bool Database::insertQuery(QString query, QVariantMap bind)
{
    sqlda->execute(query, bind);
    return sqlda->hasError();
}

void Database::dropTable(QString tablename){
    QSqlQuery q(QString("drop table %1").arg(tablename));
}
