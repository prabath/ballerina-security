import ballerina/http;
import ballerina/jwt;

jwt:InboundJwtAuthProvider jwtAuthProvider = new({
    issuer: "wso2is",
    audience: "FlfJYKBD2c925h4lkycqNZlC2l4a",
    trustStoreConfig: {
        certificateAlias: "wso2carbon",
        trustStore: {
            path: "src/inventory/keys/truststore.p12",
            password: "wso2carbon"
        }
    }
});

http:BearerAuthHandler jwtAuthHandler = new(jwtAuthProvider);

listener http:Listener ep = new(9009, config = {
    auth: {
        authHandlers: [jwtAuthHandler]
    },
    secureSocket: {
        keyStore: {
            path: "src/inventory/keys/keystore.p12",
            password: "wso2carbon"
        }
    }
});

@http:ServiceConfig {
    basePath: "/inventory"
}
service inventory on ep {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/items",
        auth: {
            scopes: ["update_items"]
        }
    }
    resource function updateItems(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setPayload({"status" : "items updated in the inventory."});
        checkpanic caller->respond(res);
    }
}
