import ballerina/auth;
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

auth:OutboundBasicAuthProvider outboundBasicAuthProvider = new({
    username: "admin",
    password: "admin"
});
http:BasicAuthHandler outboundBasicAuthHandler = new(outboundBasicAuthProvider);

http:Client pdp = new("https://localhost:9445", {
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
        path: "/orders"
    }
    resource function placeOrder(http:Caller caller, http:Request req) {
        boolean isAuthorized = authz(runtime:getInvocationContext()?.principal?.username ?: "", "orders", "POST");
        http:Response res = new;
        json message;
        if (isAuthorized) {
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
    http:Request xacmlReq = new;
    json authzReq = getAuthzRequest(user);
    log:printInfo(authzReq.toString());
    xacmlReq.setJsonPayload(authzReq);
    var response = pdp->post("/api/identity/entitlement/decision/pdp", xacmlReq);
    if (response is http:Response) {
        json jsonResp = checkpanic response.getJsonPayload();
        json[] result = <json[]> jsonResp.Response;
        json allow = checkpanic result[0].Decision;
        log:printInfo(allow.toString());
        if (allow != null && stringutils:equalsIgnoreCase(allow.toString(), "permit")) {
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

function getAuthzRequest(string subject) returns json {
    return  { "Request": { 
                "Action": {
                    "Attribute": [
                        {
                            "AttributeId": "http://ecomm.org/authz/action/name", 
                            "Value": "POST"
                        }
                    ]
                }, 
                "Resource": {
                    "Attribute": [
                        {
                            "AttributeId": "http://ecomm.org/authz/resource/name", 
                            "Value": "orders"
                        }
                    ]
                },
                "AccessSubject": {
                    "Attribute": [
                        {
                            "AttributeId": "urn:oasis:names:tc:xacml:1.0:subject:subject-id", 
                            "Value": subject
                        }
                    ]
                }
                }
            };
}
