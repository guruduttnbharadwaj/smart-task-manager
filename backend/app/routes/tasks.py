from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from uuid import UUID
from datetime import datetime

from app.database import get_db
from app.models.task import Task
from app.models.task_history import TaskHistory
from app.schemas.task import TaskCreate, TaskUpdate, TaskResponse
from app.services.classifier import classify_task

router = APIRouter(
    prefix="/api/tasks",
    tags=["Tasks"]
)

# -------------------------------------------------
# 1️⃣ CREATE TASK
# POST /api/tasks
# -------------------------------------------------
@router.post("/", response_model=TaskResponse)
def create_task(task: TaskCreate, db: Session = Depends(get_db)):

    classification = classify_task(task.description)

    new_task = Task(
        title=task.title,
        description=task.description,
        category=classification["category"],
        priority=classification["priority"],
        status="pending",
        assigned_to=task.assigned_to,
        due_date=task.due_date,
        extracted_entities={},
        suggested_actions=classification["suggested_actions"],
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )

    db.add(new_task)
    db.commit()
    db.refresh(new_task)

    history = TaskHistory(
        task_id=new_task.id,
        action="created",
        new_value={"status": "pending"},
        changed_by="system"
    )
    db.add(history)
    db.commit()

    return new_task


# -------------------------------------------------
# 2️⃣ LIST TASKS (with filters + pagination)
# GET /api/tasks
# -------------------------------------------------
@router.get("/", response_model=list[TaskResponse])
def list_tasks(
    status: str | None = None,
    category: str | None = None,
    priority: str | None = None,
    limit: int = 10,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    query = db.query(Task)

    if status:
        query = query.filter(Task.status == status)
    if category:
        query = query.filter(Task.category == category)
    if priority:
        query = query.filter(Task.priority == priority)

    tasks = query.offset(offset).limit(limit).all()
    return tasks


# -------------------------------------------------
# 3️⃣ GET TASK BY ID + HISTORY
# GET /api/tasks/{task_id}
# -------------------------------------------------
@router.get("/{task_id}")
def get_task(task_id: UUID, db: Session = Depends(get_db)):

    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    history = (
        db.query(TaskHistory)
        .filter(TaskHistory.task_id == task_id)
        .order_by(TaskHistory.changed_at.desc())
        .all()
    )

    return {
        "task": task,
        "history": history
    }


# -------------------------------------------------
# 4️⃣ UPDATE TASK
# PATCH /api/tasks/{task_id}
# -------------------------------------------------
@router.patch("/{task_id}", response_model=TaskResponse)
def update_task(
    task_id: UUID,
    updates: TaskUpdate,
    db: Session = Depends(get_db)
):

    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    old_value = {
        "title": task.title,
        "description": task.description,
        "status": task.status,
        "category": task.category,
        "priority": task.priority,
        "assigned_to": task.assigned_to,
        "due_date": task.due_date.isoformat() if task.due_date else None
    }

    for field, value in updates.dict(exclude_unset=True).items():
        setattr(task, field, value)

    task.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(task)

    history = TaskHistory(
        task_id=task.id,
        action="updated",
        old_value=old_value,
        new_value=updates.dict(exclude_unset=True),
        changed_by="system"
    )
    db.add(history)
    db.commit()

    return task


# -------------------------------------------------
# 5️⃣ DELETE TASK
# DELETE /api/tasks/{task_id}
# -------------------------------------------------
@router.delete("/{task_id}")
def delete_task(task_id: UUID, db: Session = Depends(get_db)):

    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    history = TaskHistory(
        task_id=task.id,
        action="deleted",
        old_value={"title": task.title},
        changed_by="system"
    )
    db.add(history)

    db.delete(task)
    db.commit()

    return {"message": "Task deleted successfully"}
