import ballerina/http;
import ballerina/runtime;
import ballerina/log;
import ballerina/io;

endpoint http:Listener ep {
    port: 9009,

    secureSocket: {
        keyStore: {
            path: "inventory/keys/keystore.p12",
            password: "wso2carbon"
        },
        trustStore: {
            path: "inventory/keys/truststore.p12",
            password: "wso2carbon"
        },
        protocol: {
            name: "TLS",
            versions: ["TLSv1.2"]
        },
        ciphers: ["TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"],
        sslVerifyClient : "require"
    }
};

@http:ServiceConfig {
    basePath: "/inventory",
    authConfig: {
        authentication: { enabled: true }
    }
}
service<http:Service> inventory bind ep {
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/items"
    }
    updateItems(endpoint caller, http:Request req) {
        log:printInfo("End-user: " + req.getHeader("authn-user"));
        http:Response res = new;
        res.setPayload({"status" : "items updated in the inventory."});
        _ = caller->respond(res);
    }
}