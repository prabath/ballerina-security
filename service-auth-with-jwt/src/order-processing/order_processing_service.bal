import ballerina/http;
import ballerina/jwt;
import ballerina/log;

jwt:InboundJwtAuthProvider inboundJwtAuthProvider = new({
    issuer: "wso2is",
    audience: "3VTwFk7u1i366wzmvpJ_LZlfAV4a",
    trustStoreConfig: {
        certificateAlias: "wso2carbon",
        trustStore: {
            path: "src/order-processing/keys/truststore.p12",
            password: "wso2carbon"
        }
    }
});
http:BearerAuthHandler inboundJwtAuthHandler = new(inboundJwtAuthProvider);

listener http:Listener ep = new(9008, config = {
    auth: {
        authHandlers: [inboundJwtAuthHandler]
    },
    secureSocket: {
        keyStore: {
            path: "src/order-processing/keys/keystore.p12",
            password: "wso2carbon"
        }
    }
});

@http:ServiceConfig {
    basePath: "/order-processing"
}
service orderprocessing on ep {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/orders",
        auth: {
            scopes: ["place-order"]
        }
    }
    resource function placeOrder(http:Caller caller, http:Request req) {
        json invPayload = {"items" :[{"code" : "10001","qty" : 4}]};
        log:printInfo(invPayload.toString());

        json success = {"status" : "order created successfully"};
        http:Response res = new;
        res.setPayload(success);
        checkpanic caller->respond(res);
    }
}
