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

endpoint http:Client httpEndpoint {
    url: "https://localhost:9009",
     secureSocket: {
        trustStore: {
            path: "order-processing/keys/truststore.p12",
            password: "wso2carbon"
        }
    },
    auth: {
        scheme: http:JWT_AUTH
    }
};

endpoint http:Client tokenEndpoint {
    url: "https://localhost:9443/oauth2",
     secureSocket: {
        trustStore: {
            path: "order-processing/keys/truststore.p12",
            password: "wso2carbon"
        }
    },
    auth: {
        scheme: http:BASIC_AUTH,
        username: "FlfJYKBD2c925h4lkycqNZlC2l4a",
        password: "gWGWUmlBF35cIahquMfIlIsujlwa"
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
        path: "/orders",
        authConfig: {
            scopes: ["place-order"]
        }
    }
    placeOrder(endpoint caller, http:Request req) {
        exchangeToken(runtime:getInvocationContext().authContext.authToken);
        http:Request invReq = new;
        json invPayload = {"items" :[{"code" : "10001","qty" : 4}]};
        invReq.setJsonPayload(invPayload, contentType = "application/json");
        var response = httpEndpoint->post("/inventory/items",invReq);
        match response {
            http:Response resp => { 
                string log = "response from inventory service " + check resp.getPayloadAsString();
                log:printInfo(log);
                json success = {"status" : "order created successfully"};
                http:Response res = new;
                res.setPayload(success);
                _ = caller->respond(res);
            }
            error err => { 
                log:printError("call to the inventory endpoint failed.");
                json failure = {"status" : "failed to create a new order"};
                http:Response res = new;
                res.setPayload(failure);
                res.statusCode = 500;
                _ = caller->respond(res);
            }
        }        
    }
}

function exchangeToken(string jwt) {

    http:Request newReq = new;
    string payload = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&scope=update_items&assertion=" + jwt;
    newReq.setTextPayload(untaint payload, contentType = "application/x-www-form-urlencoded");

    var response = tokenEndpoint->post("/token",newReq);
        match response {
            http:Response resp => { 
                json jsonResp =  check resp.getJsonPayload();
                json  newJWT =  jsonResp.access_token;
                //log:printInfo(newJWT.toString());
                runtime:getInvocationContext().authContext.scheme = "jwt";
                runtime:getInvocationContext().authContext.authToken = newJWT.toString();
            }
            error err => { 
                log:printError("call to the token endpoint failed during token exchange.");
            }
    }        
}