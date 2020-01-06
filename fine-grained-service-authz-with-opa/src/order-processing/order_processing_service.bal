import ballerina/http;
import ballerina/jwt;
import ballerina/log;
import ballerina/runtime;
import ballerina/stringutils;

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

http:Client opa = new("http://localhost:8181");

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
        path: "/orders"
    }
    resource function placeOrder(http:Caller caller, http:Request req) {
        boolean isAuthorized = authz(runtime:getInvocationContext()?.principal?.username ?: "", "orders", "POST");
        json message;
        http:Response res = new;
        if (isAuthorized){
            message = {"status" : "order created successfully"};
        } else {
            message = {"status" : "user not authorized"};
            res.statusCode = 401;
        }
        res.setPayload(message);
        checkpanic caller->respond(res);
    }
}

function authz(string user, string res, string action) returns boolean {
    http:Request opaReq = new;
    json authzReq = { "input" : {"method": action, "path": res, "user": user}};
    log:printInfo(authzReq.toString());
    opaReq.setJsonPayload(authzReq);
    var response = opa->post("/v1/data/authz/orderprocessing", opaReq);
    if (response is http:Response) {
        json jsonResp = checkpanic response.getJsonPayload();
        json result = checkpanic jsonResp.result;
        json allow = checkpanic result.allow;
        if (allow != null && stringutils:equalsIgnoreCase(allow.toString(), "true")) {
            return true;
        } else {
            log:printError(jsonResp.toString());
            return false;
        }
    } else {
        log:printError("call to the opa endpoint failed.");
        return false;
    }
}
