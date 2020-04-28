package com.openxchange.oxcoi;


class MethodChannels {

    abstract static class Security {
        static final String NAME = "oxcoi.security";

        abstract static class Methods {
            static final String DECRYPT = "'decrypt'";
        }

        abstract static class Arguments {
            static final String CONTENT = "encryptedBase64Content";
            static final String PRIVATE_KEY = "privateKeyBase64";
            static final String PUBLIC_KEY = "publicKeyBase64";
            static final String AUTH = "authBase64";
        }
    }

    abstract static class Sharing {
        static final String NAME = "oxcoi.sharing";

        abstract static class Methods {
            static final String GET_SHARE_DATA = "getSharedData";
            static final String SEND_SHARE_DATA = "sendSharedData";
            static final String GET_INITIAL_LINK = "getInitialLink";
        }

        abstract static class Arguments {
            static final String MIME_TYPE = "mimeType";
            static final String TEXT = "text";
            static final String PATH = "path";
            static final String NAME = "fileName";
            static final String TITLE = "title";
        }
    }
}

