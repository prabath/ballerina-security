import ballerina/http;
import ballerina/jwt;
import ballerina/log;
import ballerina/oauth2;

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

oauth2:OutboundOAuth2Provider outboundOAuth2Provider = new({
    tokenUrl: "https://localhost:9443/oauth2/token",
    clientId: "3VTwFk7u1i366wzmvpJ_LZlfAV4a",
    clientSecret: "3ypU1Ha8dGUmFdFbe4scmPAZ1Y4a",
    scopes: ["place-order"],
    clientConfig: {
        secureSocket: {
            trustStore: {
                path: "src/order-processing/keys/truststore.p12",
                password: "wso2carbon"
            }
        }
    }
});
http:BearerAuthHandler outboundOAuth2Handler = new(outboundOAuth2Provider);

http:Client httpEndpoint = new("https://localhost:9090", {
    auth: {
        authHandler: outboundOAuth2Handler
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
        var response = httpEndpoint->post("/inventory/items", invReq);
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
