#!/bin/sh

# 시작
echo "MYSQL 백업 시작"
echo ""

#오늘날짜
export Today="`date '+%Y-%m-%d'`"

#$$$ 접속계정
#DBHOST="localhost"
DBHOST="nodata"

#DBUSER="root"
DBUSER="nodata"

#DBPASS="qwer12#$"
DBPASS="nodata"

#$$$ mysql/bin경로
#SQLBIN="/usr/bin"
SQLBIN="nodata"

#$$$ 백업하여 저장할 경로
#BACKUPDIR="/backup/mysql"
BACKUPDIR="nodata"

# 설정값이 초기와 같음
if [ "$DBHOST" == "nodata" ]; then
	echo "DBHOST 값을 확인해주세요"
elif [ "$DBUSER" == "nodata" ]; then
	echo "DBUSER 값을 확인해주세요"
elif [ "$DBPASS" == "nodata" ]; then
	echo "DBPASS 값을 확인해주세요"
elif [ "$SQLBIN" == "nodata" ]; then
	echo "SQLBIN 값을 확인해주세요"
elif [ "$BACKUPDIR" == "nodata" ]; then
	echo "BACKUPDIR 값을 확인해주세요"
else
	/bin/mkdir -p $BACKUPDIR/$Today


	echo ""
	echo "덤프 시작 : `date '+%Y-%m-%d %H:%M:%S'`"

	# 백업할 디비 리스트
	DBLIST=`$SQLBIN/mysql --user=$DBUSER --password=$DBPASS -h$DBHOST -e "SHOW DATABASES;" | tail -n+2`


	# 디비 별 테이블별 덤프
	for THISDB in $DBLIST
		do

		# 제외할 db 
		if [ "$THISDB" == "phpmyadmin" ]; then
			echo "Database dump skip - phpmyadmin"
		elif [ "$THISDB" == "cacti" ]; then
			echo "Database dump skip - sys"
		elif [ "$THISDB" == "information_schema" ]; then
			echo "Database dump skip - information_schema"
		#elif [ "$THISDB" == "mysql" ]; then
		#	echo "Database dump skip - mysql"
		elif [ "$THISDB" == "performance_schema" ]; then
			echo "Database dump skip - performance_schema"
		elif [ "$THISDB" == "sys" ]; then
			echo "Database dump skip - sys"

		else

			TABLELIST=`${SQLBIN}/mysql -h${DBHOST} -u${DBUSER} -p${DBPASS} ${THISDB} -e "show tables" | /bin/grep -v Tables_in_${THISDB}`
			DIR="${BACKUPDIR}/${Today}/${THISDB}"
			/bin/mkdir $DIR # 디비별 디렉토릭 생성
			# 스키마만 따로 저장
			echo "mysqldump --no-data > ${DIR}.sql"
			$SQLBIN/mysqldump -h$DBHOST -u$DBUSER -p$DBPASS --databases $THISDB --no-data > ${DIR}.sql
			# 프로시저, 함수, 이벤트만 따로 저장
			echo "mysqldump --no-data > ${DIR}.other.sql"
			$SQLBIN/mysqldump -h$DBHOST -u$DBUSER -p$DBPASS --databases $THISDB --routines --triggers --events --no-create-info --no-create-db --skip-opt --no-data > ${DIR}.other.sql
			# 복구 스크립트 생성
			echo "${SQLBIN}/mysql -h${DBHOST} -u${DBUSER} -p${DBPASS} < ${THISDB}.sql" >> ${BACKUPDIR}/${Today}/_insert_schema.sh
			# 데이타 저장
			for THISTABLE in $TABLELIST
				do
				TABLEDIR="${DIR}/${THISDB}.${THISTABLE}.sql"
				echo "mysqldump --no-create-info $TABLEDIR"
				$SQLBIN/mysqldump -h$DBHOST -u$DBUSER -p$DBPASS --no-create-info $THISDB $THISTABLE > $TABLEDIR
				# 복구 스크립트 생성
				echo "echo \"${THISDB}.${THISTABLE}.sql 파일 실행 시작\"" >> ${BACKUPDIR}/${Today}/_insert_data_${THISDB}.sh
				echo "${SQLBIN}/mysql -h${DBHOST} -u${DBUSER} -p${DBPASS} ${THISDB} < ${TABLEDIR}" >> ${BACKUPDIR}/${Today}/_insert_data_${THISDB}.sh
				echo "echo \"${THISDB}.${THISTABLE}.sql 파일 실행 종료\"" >> ${BACKUPDIR}/${Today}/_insert_data_${THISDB}.sh
				echo ""
			done
		fi
		echo ""

	done

	echo "덤프 완료 : `date '+%Y-%m-%d %H:%M:%S'`"

	#echo ""
	#echo "덤프 파일 압축 시작 : `date '+%Y-%m-%d %H:%M:%S'`"
	#BACKUPFILE="mysql_${Today}.tar.gz"
	#echo "tar -cvzf $BACKUPDIR/$BACKUPFILE $BACKUPDIR/$Today"
	#tar -cvzf ${BACKUPDIR}/${BACKUPFILE} ${BACKUPDIR}/${Today}
	#echo "덤프 파일 압축 완료 : `date '+%Y-%m-%d %H:%M:%S'`"

	#echo ""
	#echo "덤프 파일 삭제 시작 : `date '+%Y-%m-%d %H:%M:%S'`"
	#/bin/rm -rf $BACKUPDIR/$Today
	#echo "덤프 파일 삭제 완료 : `date '+%Y-%m-%d %H:%M:%S'`"

	#echo ""
	#echo "오래된 백업 파일 삭제 시작(30일 이상) : `date '+%Y-%m-%d %H:%M:%S'`"
	#find $BACKUPDIR -ctime +30 -exec rm -f {} \;
	#echo "오래된 백업 파일 삭제 완료 : `date '+%Y-%m-%d %H:%M:%S'`"
fi
