"""User-recorded vaccine tracking, not clinical eligibility decisions."""
from datetime import datetime, timezone, timedelta
from pydantic import BaseModel, ConfigDict, Field, model_validator


class VaccinationRecord(BaseModel):
    model_config = ConfigDict(extra='allow', str_strip_whitespace=True)
    id: str = Field(min_length=1, max_length=120, pattern=r'^[a-z0-9_]+$')
    name: str = Field(min_length=1, max_length=160)
    due_date: datetime
    custom: bool = False
    done: bool = False
    excluded: bool = False
    received_date: datetime | None = None
    reminder_at: datetime | None = None
    doctor: str = Field(default='', max_length=160)
    notes: str = Field(default='', max_length=500)

    @model_validator(mode='after')
    def validate_completion(self):
        if self.done and self.received_date is None:
            raise ValueError('Actual received date is required for a completed dose.')
        today_india = datetime.now(timezone(timedelta(hours=5, minutes=30))).date()
        if self.received_date and self.received_date.date() > today_india:
            raise ValueError('Received date cannot be in the future.')
        if self.done or self.excluded:
            self.reminder_at = None
        if self.done:
            self.excluded = False
        if not self.done:
            self.received_date = None
        return self
