from database import engine

try:
    with engine.connect() as conn:
        print("DB CONNECTED SUCCESSFULLY")
except Exception as e:
    print("DB CONNECTION FAILED")
    print(e)
