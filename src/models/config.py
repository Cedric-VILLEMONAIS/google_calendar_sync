from dataclasses import dataclass
from typing import Any, List, Mapping

from src.models.ical import ICalendar


@dataclass
class Config:
    icals: List[ICalendar]

    @classmethod
    def from_dict(cls, data: Mapping[str, Any]):
        icals = data.get("icals", [])
        return cls(
            icals=[ICalendar.from_dict(_) for _ in icals],
        )
