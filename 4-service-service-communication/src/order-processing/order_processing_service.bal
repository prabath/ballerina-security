import ballerina/http;
import ballerina/log;

http:Client httpEndpoint = new("https://localhost:9009", {
    secureSocket: {
        trustStore: {
            path: "src/order-processing/keys/truststore.p12",
            password: "wso2carbon"
        }
    }
});

listener http:Listener ep = new(9008, config = {
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
