import ballerina/http;
import ballerina/jwt;
import ballerina/log;
import ballerina/runtime;

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

http:Client httpEndpoint = new("https://localhost:9009", {
    secureSocket: {
        keyStore: {
            path: "src/order-processing/keys/keystore.p12",
            password: "wso2carbon"
        },
        trustStore: {
            path: "src/order-processing/keys/truststore.p12",
            password: "wso2carbon"
        },
        protocol: {
            name: "TLS",
            versions: ["TLSv1.2"]
        },
        ciphers: ["TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"]
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
        },
        trustStore: {
            path: "src/order-processing/keys/truststore.p12",
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
        http:Request invReq = new;
        json invPayload = {"items" :[{"code" : "10001","qty" : 4}]};
        invReq.setJsonPayload(invPayload);

        // add a custom header to carry the end-user data.
        invReq.addHeader("authn-user", runtime:getInvocationContext()?.principal?.username ?: "");
        
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


