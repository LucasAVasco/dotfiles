"""Library with completion functions for qutebrowser."""

from collections.abc import Callable

from qutebrowser.completion.models import (  # type: ignore[import-untyped]
    completionmodel,
    listcategory,
)


def create_completion_function(
    name: str,
    elements: list[tuple[str, str]],
) -> Callable[..., completionmodel.CompletionModel]:
    """Create a completion function for a command.

    Parameters
    ----------
    name: str
        The name of the command.
    elements: list[(str, str)]
        The elements to complete.

    """

    def completion(
        *,
        info: Callable[..., completionmodel.CompletionModel],  # noqa: ARG001
    ) -> completionmodel.CompletionModel:
        model = completionmodel.CompletionModel()

        model.add_category(
            listcategory.ListCategory(name, elements),
        )

        return model

    return completion


bool_completion = create_completion_function(
    name="Boolean",
    elements=[("true", "True"), ("false", "False")],
)
