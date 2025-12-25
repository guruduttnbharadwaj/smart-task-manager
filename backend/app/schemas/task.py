from pydantic import BaseModel
from typing import Optional, Dict, List
from datetime import datetime
from uuid import UUID


class TaskCreate(BaseModel):
    title: str
    description: str
    assigned_to: Optional[str] = None
    due_date: Optional[datetime] = None


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    category: Optional[str] = None
    priority: Optional[str] = None
    assigned_to: Optional[str] = None
    due_date: Optional[datetime] = None


class TaskResponse(BaseModel):
    id: UUID
    title: str
    description: Optional[str]
    category: Optional[str]
    priority: Optional[str]
    status: str
    assigned_to: Optional[str]
    due_date: Optional[datetime]
    extracted_entities: Optional[Dict]
    suggested_actions: Optional[List[str]]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
