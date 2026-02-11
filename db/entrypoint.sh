#!/bin/bash

# Iniciar SQL Server
/opt/mssql/bin/sqlservr &

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Esperar a que SQL Server esté listo
wait_for_sql() {
    for i in {1..50}; do
        # Intentar conexión
        /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" &>/dev/null
        if [ $? -eq 0 ]; then
            echo "SQL Server listo"
            return 0
        fi
        echo "Esperando que levante SQL Serve: ($i/50)"
        sleep 3
    done
    return 1
}

echo "Esperando que esté listo SQL Server"
wait_for_sql

if [ $? -eq 0 ]; then
    echo "Crear bases de datos"
    /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -Q "
        IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'indec') CREATE DATABASE indec;
        IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'supermercado1') CREATE DATABASE supermercado1;
        IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'supermercado2') CREATE DATABASE supermercado2;
        IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'supermercado3') CREATE DATABASE supermercado3;
        IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'supermercado4') CREATE DATABASE supermercado4;
    "

    echo "Correr scripts"
    # Definiciones de BD con su script de inicialización respectivo
    databases=("indec" "supermercado1" "supermercado2" "supermercado3" "supermercado4")
    scripts=(
      "$SCRIPT_DIR/indec-script.sql"
      "$SCRIPT_DIR/supermercado1-script.sql"
      "$SCRIPT_DIR/supermercado2-script.sql"
      "$SCRIPT_DIR/supermercado3-script.sql"
      "$SCRIPT_DIR/supermercado4-script.sql"
    )

    for i in "${!databases[@]}"; do
        /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -d "${databases[i]}" -i "${scripts[i]}"
        echo "Script ejecutado ${scripts[i]} en ${databases[i]}"
    done

else
    echo "SQL Server no está levantado"
fi

# Mantener el contenedor ejecutándose
tail -f /dev/null
