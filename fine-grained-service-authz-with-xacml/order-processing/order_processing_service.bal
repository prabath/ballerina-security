import ballerina/http;
import ballerina/runtime;
import ballerina/log;
import ballerina/io;

http:AuthProvider jwtAuthProvider = {
    scheme:"jwt",
    issuer:"wso2is",
    audience: "3VTwFk7u1i366wzmvpJ_LZlfAV4a",
    certificateAlias:"wso2carbon",
    trustStore: {
        path: "order-processing/keys/truststore.p12",
        password: "wso2carbon"
    }
};

endpoint http:Client pdp {
    url: "https://localhost:9445",
     secureSocket: {
        trustStore: {
            path: "order-processing/keys/truststore.p12",
            password: "wso2carbon"
        }
    },
    auth: {
        scheme: http:BASIC_AUTH,
        username: "admin",
        password: "admin"
    }
};

endpoint http:SecureListener ep {
    port: 9008,
    authProviders:[jwtAuthProvider],

    secureSocket: {
        keyStore: {
            path: "order-processing/keys/keystore.p12",
            password: "wso2carbon"
        },
        trustStore: {
            path: "order-processing/keys/truststore.p12",
            password: "wso2carbon"
        }
    }
};

@http:ServiceConfig {
    basePath: "/order-processing",
    authConfig: {
        authentication: { enabled: true }
    }
}
service<http:Service> orderprocessing bind ep {
      @http:ResourceConfig {
        methods: ["POST"],
        path: "/orders"
    }
    placeOrder(endpoint caller, http:Request req) {
        boolean isAuthorized = authz(runtime:getInvocationContext().userPrincipal.username, "orders", "POST");
        json message;
        http:Response res = new;
        if (isAuthorized){
            message = {"status" : "order created successfully"};
        } else {
            message = {"status" : "user not authorized"};
            res.statusCode = 401;
        }
        
        res.setPayload(message);
        _ = caller->respond(res);
    }
}

function authz(string user, string res, string action) returns (boolean) {
        http:Request xacmlReq = new;
        json authzReq = getAuthzRequest(user);

        log:printInfo(authzReq.toString());

        xacmlReq.setJsonPayload(authzReq, contentType = "application/json");
        var response = pdp->post("/api/identity/entitlement/decision/pdp",xacmlReq);
        match response {
            http:Response resp => { 
                json jsonResp =  check resp.getJsonPayload();
                json  result =  jsonResp.Response[0];
                json  allow =  result.Decision;
                if (allow != null && allow.toString().equalsIgnoreCase("permit")) {
                    return true;
                } else {
                    log:printError(jsonResp.toString());
                    return false;
                }
            }
            error err => { 
                log:printError("call to the opa endpoint failed.");
                return false;
            }
        } 
}

function getAuthzRequest(string subject) returns (json) {
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

