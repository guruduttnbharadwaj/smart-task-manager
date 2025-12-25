from fastapi import FastAPI
from backend.app.routes.tasks import router as task_router

app = FastAPI(title="Smart Site Task Manager")

app.include_router(task_router)

@app.get("/")
def health_check():
    return {"status": "Backend is running"}
