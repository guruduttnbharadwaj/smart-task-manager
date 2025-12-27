from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

created_task_id = None


# ============================
# TEST 1: CREATE TASK
# ============================
def test_create_task():
    global created_task_id

    response = client.post(
        "/api/tasks/",
        json={
            "title": "Test task",
            "description": "Urgent meeting with team today",
            "assigned_to": "Tester"
        }
    )

    assert response.status_code == 200

    data = response.json()
    assert data["title"] == "Test task"
    assert data["status"] == "pending"
    assert "priority" in data
    assert "category" in data

    created_task_id = data["id"]


# ============================
# TEST 2: UPDATE TASK (COMPLETE)
# ============================
def test_update_task_status():
    global created_task_id
    assert created_task_id is not None

    response = client.patch(
        f"/api/tasks/{created_task_id}",
        json={
            "status": "completed"
        }
    )

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "completed"


# ============================
# TEST 3: DELETE TASK
# ============================
def test_delete_task():
    global created_task_id
    assert created_task_id is not None

    response = client.delete(f"/api/tasks/{created_task_id}")
    assert response.status_code == 200

    # Verify it is deleted
    response = client.get(f"/api/tasks/{created_task_id}")
    assert response.status_code == 404
