#!/bin/bash

function task_database_available()
{
    local command=""

    if [ "${DB_PLATFORM}" == "mysql" ]; then
        command="mysqladmin -h $DB_HOST -u ${DB_ADMIN_USER:-$DB_USER} -p${DB_ROOT_PASS:-${DB_ADMIN_PASS:-$DB_PASS}} -P ${DB_PORT} ping --connect_timeout=10"
    elif [ "${DB_PLATFORM}" == "postgres" ]; then
        command="pg_isready -h $DB_HOST -U ${DB_ADMIN_USER:-$DB_USER} -p ${DB_PORT}"
    elif [ "${DB_PLATFORM}" == "" ]; then
        # no database is used
        return
    else
        echo "invalid database type" >&2
        exit 1
    fi

    local counter=0

    while ! $command &> /dev/null; do

        if (( counter > 300 )); then
            echo "timeout while waiting on ${DB_PLATFORM} to become available" >&2
            exit 1
        fi

        if ! (( counter % 5 )); then
          echo "Waiting for database to become available: '${command}'"
        fi

        sleep 2
        ((++counter))
    done
}
