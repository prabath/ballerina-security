import ballerina/http;
import ballerina/jwt;
import ballerina/log;

jwt:InboundJwtAuthProvider inboundJwtAuthProvider = new({
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

http:BearerAuthHandler inboundJwtAuthHandler = new(inboundJwtAuthProvider);

jwt:OutboundJwtAuthProvider outboundJwtAuthProvider = new;
http:BearerAuthHandler outboundJwtAuthHandler = new(outboundJwtAuthProvider);

http:Client httpEndpoint = new("https://localhost:9090", {
    auth: {
        authHandler: outboundJwtAuthHandler
    },
    secureSocket: {
        trustStore: {
            path: "src/order-processing/keys/truststore.p12",
            password: "wso2carbon"
        }
    }
});

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
service inventory on ep {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/orders",
        auth: {
            scopes: ["place-order"]
        }
    }
    resource function placeOrder(http:Caller caller, http:Request req) {
        http:Request invReq = new;
        json invPayload = {"items" :[{"code" : "10001","qty" : 4}]};
        invReq.setJsonPayload(invPayload);
        var response = httpEndpoint->post("/inventory/items",invReq);
        if (response is http:Response) {
            string log = "response from inventory service " + response.getTextPayload().toString();
            log:printInfo(log);
            json success = {"status" : "order created successfully"};
            http:Response res = new;
            res.setPayload(success);
            checkpanic caller->respond(res);
        } else {
            log:printError("call to the inventory endpoint failed.");
            json failure = {"status" : "failed to create a new order"};
            http:Response res = new;
            res.setPayload(failure);
            res.statusCode = 500;
            checkpanic caller->respond(res);
        }
    }
}
