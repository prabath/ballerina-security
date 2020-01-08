import ballerina/http;

listener http:Listener ep = new(9009, config = {
    secureSocket: {
        keyStore: {
            path: "src/inventory/keys/keystore.p12",
            password: "wso2carbon"
        }
    }
});

@http:ServiceConfig {
    basePath: "/inventory"
}
service inventory on ep {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/items"
    }
    resource function updateItems(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setPayload({"status" : "items updated in the inventory."});
        checkpanic caller->respond(res);
    }
}
