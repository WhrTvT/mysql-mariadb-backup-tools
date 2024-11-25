[ex]
zip 백업 방법 : zip -r [백업파일 이름].zip [백업 디렉토리/파일]

[db 서버] - 리눅스
#/etc/my.cnf 백업

#프로시저, 함수, 트리거, 이벤트 백업
mysqldump -hlocalhost -uroot -pqwer12#$ --routines --triggers --events --no-create-info --no-data --no-create-db --skip-opt test > ./test.other.sql

# db와 테이블별로 백업파일 생성
./dump.sh

[리눅스]
#/var/www/html/upload.php 백업
#/etc/php.ini 백업

#/var/www/html/... 웹 백업
zip -r ./web.zip application composer.json contributing.md db_schema.php docs ext ...

#/etc/httpd/ 내용 모두 백업
zip -r ./httpd_dir.zip /etc/httpd/