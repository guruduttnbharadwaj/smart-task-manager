from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes.tasks import router as task_router

app = FastAPI(title="Smart Site Task Manager")

#  CORS CONFIGURATION 
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # allow all origins for now (dev-safe)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
app.include_router(task_router)

@app.get("/")
def health_check():
    return {"status": "Backend is running"}
