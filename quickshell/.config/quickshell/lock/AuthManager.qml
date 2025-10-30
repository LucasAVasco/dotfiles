import Quickshell.Services.Pam

PamContext {
    id: pam
    property string password: ""

    signal authProcess(int status)

    function tryUnlock(password) {
        if (password == "") {
            return;
        }

        pam.password = password;
        pam.start();
    }

    onCompleted: status => {
        authProcess(status);
    }

    onResponseRequiredChanged: {
        if (!pam.responseRequired) {
            return;
        }

        respond(pam.password);
        pam.password = "";
    }
}
