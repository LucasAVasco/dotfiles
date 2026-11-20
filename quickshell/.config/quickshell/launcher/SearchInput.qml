import QtQuick

import "../ui"

TextFieldBox {
    id: root

    signal enter
    signal abort
    signal nextApp
    signal previousApp

    leadingIcon: "󰍉"
    placeholderText: "Search applications…"
    implicitHeight: 42

    onAccepted: root.enter()
    onEscapePressed: root.abort()
    onUpPressed: root.previousApp()
    onDownPressed: root.nextApp()
}
