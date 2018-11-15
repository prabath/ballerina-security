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

endpoint http:Client opa {
    url: "http://localhost:8181",
     secureSocket: {
        trustStore: {
            path: "order-processing/keys/truststore.p12",
            password: "wso2carbon"
        }
    }
};

endpoint http:Listener ep {
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
        http:Request opaReq = new;
        json authzReq = { "input" : {"method": action,"path": res,"user": user}};
        //json authzReq = { "input" : {"method": action,"path": res,"user": user, "amount" : 1000}};

        log:printInfo(authzReq.toString());

        opaReq.setJsonPayload(authzReq, contentType = "application/json");
        var response = opa->post("/v1/data/authz/orderprocessing",opaReq);
        match response {
            http:Response resp => { 
                json jsonResp =  check resp.getJsonPayload();
                json  result =  jsonResp.result;
                json  allow =  result.allow;
                if (allow != null && allow.toString().equalsIgnoreCase("true")) {
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



