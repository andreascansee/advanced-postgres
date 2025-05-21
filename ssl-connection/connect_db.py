import psycopg2
from dotenv import load_dotenv
from psycopg2 import OperationalError
import os

load_dotenv()

def get_connection():
    try:
        conn = psycopg2.connect(
            host=os.getenv("PGHOST", "localhost"),
            port=int(os.getenv("PGPORT", 5432)),
            dbname=os.getenv("PGDATABASE", "postgres"),
            user=os.getenv("PGUSER", "postgres"),
            password=os.getenv("PGPASSWORD", ""),
            sslmode='verify-ca',
            sslrootcert="root.crt"
        )
        return conn
    except OperationalError as e:
        print("❌ Failed to connect to PostgreSQL:", e)
        return None
    
def main():
    conn = get_connection()
    if conn is None:
        return

    try:
        with conn.cursor() as cur:
            cur.execute("SELECT current_user, current_database(), version();")
            user, db, version = cur.fetchone()
            print(f"✅ Connected as {user}, to database '{db}'")
            print(f"PostgreSQL version: {version}")
    finally:
        conn.close()

if __name__ == "__main__":
    main()
    
    