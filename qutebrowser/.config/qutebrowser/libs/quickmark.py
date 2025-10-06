"""Quickmarks for qutebrowser."""

from pathlib import Path


def set_initial_quickmarks(quickmarks: dict[str, str]) -> None:
    """Set the initial quickmarks.

    Does not overwrite existing quickmarks.

    Parameters
    ----------
    quickmarks : dict[str, str]
        The quickmarks to set.

    """
    # Custom quick marks
    file = Path("~/.config/qutebrowser/quickmarks").expanduser()
    if not file.exists():
        file.parent.mkdir(parents=True, exist_ok=True)

        with file.open("w") as f:
            for k, v in quickmarks.items():
                f.write(f"{k} {v}\n")
