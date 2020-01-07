import ballerina/auth;
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

jwt:OutboundJwtAuthProvider outboundJwtAuthProvider = new;
http:BearerAuthHandler outboundJwtAuthHandler = new(outboundJwtAuthProvider);

http:Client httpEndpoint = new("https://localhost:9009", {
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

auth:OutboundBasicAuthProvider outboundBasicAuthProvider = new({
    username: "FlfJYKBD2c925h4lkycqNZlC2l4a",
    password: "gWGWUmlBF35cIahquMfIlIsujlwa"
});
http:BasicAuthHandler outboundBasicAuthHandler = new(outboundBasicAuthProvider);

http:Client tokenEndpoint = new("https://localhost:9443/oauth2", {
    auth: {
        authHandler: outboundBasicAuthHandler
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
        string authToken = runtime:getInvocationContext()?.authenticationContext?.authToken ?: "";
        exchangeToken(authToken);
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

function exchangeToken(string jwt) {
    http:Request newReq = new;
    string payload = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&scope=update_items&assertion=" + jwt;
    newReq.setTextPayload(payload, contentType = "application/x-www-form-urlencoded");

    var response = tokenEndpoint->post("/token", newReq);
    if (response is http:Response) {
        json jsonResp = checkpanic response.getJsonPayload();
        json newJWT = checkpanic jsonResp.access_token;
        log:printInfo(newJWT.toString());
        runtime:InvocationContext invocationContext = runtime:getInvocationContext();
        invocationContext.authenticationContext = {
            scheme: "jwt",
            authToken: newJWT.toString()
        };
    } else {
        log:printError("call to the token endpoint failed during token exchange.");
    }
}
