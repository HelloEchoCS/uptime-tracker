DATABASE_NAME=$1
SCHEMA_NAME=$2

dropdb $DATABASE_NAME

createdb $DATABASE_NAME

psql $DATABASE_NAME -f $SCHEMA_NAME.sql