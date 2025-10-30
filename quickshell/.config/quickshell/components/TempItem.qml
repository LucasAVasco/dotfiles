import Quickshell

LazyLoader {
    id: root

    signal done

    function load() {
        root.loading = true;
    }

    property var varItem: item // Used to ignore type checking errors

    onActiveChanged: {
        if (active) {
            varItem.done.connect(function () {
                root.done();
                root.active = false;
            });
        }
    }
}
