#!/bin/sh

# 시작
# 복원할 sql 파일이 존재하는 디렉토리로 이동 후, 실행


#$$$ 접속계정
#DBHOST="localhost"
DBHOST="nodate"

#DBUSER="root"
DBUSER="nodata"

#DBPASS="qwer12#$"
DBPASS="nodata"

#DBNAME="test"
DBNAME="nodata"

#$$$ mysql/bin경로
#SQLBIN="/usr/bin"
SQLBIN="nodata"

# 설정값이 초기와 같음
if [ "$DBHOST" == "nodata" ]; then
	echo "DBHOST 값을 확인해주세요"
elif [ "$DBUSER" == "nodata" ]; then
	echo "DBUSER 값을 확인해주세요"
elif [ "$DBPASS" == "nodata" ]; then
	echo "DBPASS 값을 확인해주세요"
elif [ "$SQLBIN" == "nodata" ]; then
	echo "SQLBIN 값을 확인해주세요"
elif [ "$DBNAME" == "nodata" ]; then
	echo "DBNAME 값을 확인해주세요"
else
	#데이터 반영 전에 sql 파일안에 존재하는 'utf8mb4_0900_ai_ci'와 'utf8mb4' 문자열을 모두 변경해야 함. (https://swiftymind.tistory.com/67 참조)
	#vi [.sql 파일]
	#:%s/utf8mb4_0900_ai_ci/utf8mb3_general_ci/g
	#:%s/utf8mb4/utf8mb3/g
	#:wq
	echo "${DBNAME}.sql 파일의 문자조합 수정 시작"
	echo ""

	sed 's/utf8mb4_0900_ai_ci/utf8mb3_general_ci/g' $DBNAME.sql > $DBNAME.changed.sql
	sed 's/utf8mb4/utf8mb3/g' $DBNAME.changed.sql > $DBNAME.changed2.sql && mv $DBNAME.changed2.sql $DBNAME.changed.sql

	echo "${DBNAME}.sql 파일의 문자조합 수정 종료"
	echo ""

	echo "${DBNAME}.other.sql 파일의 문자조합 수정 시작"
	echo ""

	sed 's/utf8mb4_0900_ai_ci/utf8mb3_general_ci/g' $DBNAME.other.sql > $DBNAME.other.changed.sql
	sed 's/utf8mb4/utf8mb3/g' $DBNAME.other.changed.sql > $DBNAME.other.changed2.sql && mv $DBNAME.other.changed2.sql $DBNAME.other.changed.sql

	echo "${DBNAME}.other.sql 파일의 문자조합 수정 종료"
	echo ""

	echo "${DBNAME}.other.sql 파일의 DEFINER 수정 시작"
	echo ""

	sed 's/localhost/%/g' $DBNAME.other.changed.sql > $DBNAME.other.changed2.sql && mv $DBNAME.other.changed2.sql $DBNAME.other.changed.sql
	#sed 's/root/user/g' $DBNAME.other.changed.sql > $DBNAME.other.changed2.sql && mv $DBNAME.other.changed2.sql $DBNAME.other.changed.sql

	echo "${DBNAME}.other.sql 파일의 DEFINER 수정 종료"
	echo ""

	echo "MYSQL 스키마 복원 시작"
	echo ""

	$SQLBIN/mysql --user=$DBUSER --password=$DBPASS -h$DBHOST < $DBNAME.changed.sql

	#DEFINER 수정
	#vi [.sql 파일]
	#:%s/localhost/%/g
	#:%s/root/user/g
	#:wq
	echo "MYSQL other 복원 시작"
	echo ""

	$SQLBIN/mysql --user=$DBUSER --password=$DBPASS -h$DBHOST $DBNAME < $DBNAME.other.changed.sql

	echo "MYSQL other 복원 종료"
	echo ""

	echo "MYSQL 데이터 복원 시작"
	echo ""

	# _insert_data.sh에서 test 내용만 빼서 실행 '_insert_data_test.sh'로 파일 복사
	#vi 현재 줄 이하 모두 삭제
	#비주얼 모드(최초 기본 모드)에서 dG 입력

	# _insert_data.sh에서 아래 내용 실행 (복원할 db 설정)
	#vi _insert_data.sh
	#:%s/localhost/%/g
	#:wq
	chmod 777 ./_insert_data_$DBNAME.sh
	./_insert_data_$DBNAME.sh

	echo "MYSQL 데이터 복원 종료"
	echo ""
fi
