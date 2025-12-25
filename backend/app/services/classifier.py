def classify_task(text: str):
    text = text.lower()

    category = "general"
    if "meeting" in text or "schedule" in text:
        category = "scheduling"
    elif "bug" in text or "fix" in text:
        category = "technical"
    elif "invoice" in text or "payment" in text:
        category = "finance"

    priority = "low"
    if "urgent" in text or "asap" in text:
        priority = "high"
    elif "soon" in text:
        priority = "medium"

    actions = {
        "scheduling": ["Block calendar", "Send invite"],
        "technical": ["Investigate issue"],
        "finance": ["Check invoice"],
        "general": []
    }

    return {
        "category": category,
        "priority": priority,
        "suggested_actions": actions.get(category, [])
    }
