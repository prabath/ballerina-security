import ballerina/http;
import ballerina/log;

listener http:Listener ep = new(9009, config = {
    secureSocket: {
        keyStore: {
            path: "src/inventory/keys/keystore.p12",
            password: "wso2carbon"
        },
         trustStore: {
             path: "src/inventory/keys/truststore.p12",
             password: "wso2carbon"
         },
         protocol: {
             name: "TLS",
             versions: ["TLSv1.2"]
         },
         ciphers: ["TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"],
         sslVerifyClient : "require"
    }
});

@http:ServiceConfig {
    basePath: "/inventory"
}
service inventory on ep {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/items"
    }
    resource function updateItems(http:Caller caller, http:Request req) {
        log:printInfo("End-user: " + req.getHeader("authn-user"));
        http:Response res = new;
        res.setPayload({"status" : "items updated in the inventory."});
        checkpanic caller->respond(res);
    }
}
