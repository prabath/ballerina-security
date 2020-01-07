import ballerina/http;
import ballerina/jwt;

jwt:InboundJwtAuthProvider jwtAuthProvider = new({
    issuer: "wso2is",
    audience: "3VTwFk7u1i366wzmvpJ_LZlfAV4a",
    trustStoreConfig: {
        certificateAlias: "wso2carbon",
        trustStore: {
            path: "src/inventory/keys/truststore.p12",
            password: "wso2carbon"
        }
    }
});
http:BearerAuthHandler jwtAuthHandler = new(jwtAuthProvider);

listener http:Listener ep = new(9090, config = {
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
            scopes: ["place-order"]
        }
    }
    resource function updateItems(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setPayload({"status" : "items updated in the inventory."});
        checkpanic caller->respond(res);
    }
}
