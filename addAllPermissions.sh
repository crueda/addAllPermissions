#!/usr/bin/env python
#-*- coding: UTF-8 -*-

# autor: Carlos Rueda
# date: 2015-12-21
# mail: carlos.rueda@deimos-space.com
# version: 1.0

########################################################################
# version 1.0 release notes:
# Initial version
########################################################################

from __future__ import division
import time
import datetime
import os
import sys
import calendar
import logging, logging.handlers

from threading import Thread
import MySQLdb as mdb

########################################################################
# configuracion y variables globales

LOG = "./addAllPermissions.log"
LOG_FOR_ROTATE = 10

BBDD_HOST = "192.168.27.3"
BBDD_USERNAME = "root"
BBDD_PASSWORD = "dat1234"
BBDD_NAME = "sumo"

PACKAGE=160
USERNAME='sumo'

########################################################################

# Se definen los logs internos que usaremos para comprobar errores
try:
    logger = logging.getLogger('addAllPermissions')
    loggerHandler = logging.handlers.TimedRotatingFileHandler(LOG, 'midnight', 1, backupCount=10)
    formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
    loggerHandler.setFormatter(formatter)
    logger.addHandler(loggerHandler)
    logger.setLevel(logging.DEBUG)
except:
    print '------------------------------------------------------------------'
    print '[ERROR] Error writing log at %s' % LOG
    print '[ERROR] Please verify path folder exits and write permissions'
    print '------------------------------------------------------------------'
    exit()

########################################################################



########################################################################
# Funcion principal
#
########################################################################

def main():
	con = None
	try:
		con = mdb.connect(BBDD_HOST, BBDD_USERNAME, BBDD_PASSWORD, BBDD_NAME)
		cur = con.cursor()

		sql = "SELECT ID FROM sumo.FUNCTIONALITY WHERE SUMO_ENUM!='' and SUMO_ENUM!='UXO'"
		logger.debug("sql: " + sql)
		cur.execute(sql)
		numrows = int(cur.rowcount)
		logger.debug("Permisos a insertar: " + str(numrows))
		row = cur.fetchone()
		while row is not None:			
			funcionality = row[0]
			curCheck = con.cursor()
			sql = "SELECT * FROM PACKAGES_FUNCTIONALITY WHERE FUNCTIONALITY_ID = " + str(funcionality) + " and PACKAGES_ID = " + str(PACKAGE)
			logger.debug("sql: " + sql)
			curCheck.execute(sql)
			numrows = int(cur.rowcount)
			if (numrows==0):
				curInsert = con.cursor()
				sql = "INSERT INTO PACKAGES_FUNCTIONALITY (FUNCTIONALITY_ID, PACKAGES_ID) VALUES (" + str(funcionality) + "," + str(PACKAGE) + ")"
				logger.debug("sql: " + sql)
				curInsert.execute(sql)
				con.commit()
				curInsert.close()
			curCheck.close()
			
			curCheck = con.cursor()
			sql = "SELECT * FROM USER_FUNCTIONALITY WHERE FUNCTIONALITY_ID = " + str(funcionality) + " and PACKAGES_ID = " + str(PACKAGE) + " and USER_NAME='"  + str(USERNAME) + "'"
			logger.debug("sql: " + sql)
			curCheck.execute(sql)
			numrows = int(cur.rowcount)
			if (numrows==0):			
				curInsert2 = con.cursor()
				sql = "INSERT INTO USER_FUNCTIONALITY (FUNCTIONALITY_ID, PACKAGES_ID, USER_NAME) VALUES (" + str(funcionality) + "," + str(PACKAGE) + ",'" + str(USERNAME) + "')"
				logger.debug("sql: " + sql)
				curInsert2.execute(sql)
				con.commit()
				curInsert2.close()
			curCheck.close()

			row = cur.fetchone()
			

	except mdb.Error, e:
		logger.error ("Error %d: %s" % (e.args[0], e.args[1]))
		sys.exit(1)

	finally:
		if con:
			con.close()

if __name__ == '__main__':
    main()
