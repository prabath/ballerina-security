import ballerina/auth;
import ballerina/http;
import ballerina/oauth2;

auth:OutboundBasicAuthProvider basiAuthProvider = new({
    username: "admin",
    password: "admin"
});
http:BasicAuthHandler basicAuthHandler = new(basiAuthProvider);

oauth2:InboundOAuth2Provider oauth2Provider = new({
    url: "https://localhost:9443/oauth2/introspect",
    clientConfig: {
        auth: {
            authHandler: basicAuthHandler
        },
        secureSocket: {
            trustStore: {
                path: "src/order-processing/keys/truststore.p12",
                password: "wso2carbon"
            }
        }
    }
});
http:BearerAuthHandler oauth2Handler = new(oauth2Provider);

listener http:Listener ep = new(9090, config = {
    auth: {
        authHandlers: [oauth2Handler]
    },
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
        path: "/items",
        auth: {
            scopes: ["place-order"]
        }
    }
    resource function updateItems(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setPayload({"status" : "items updated in the inventory."});
        checkpanic caller->respond(res);
    }
}
