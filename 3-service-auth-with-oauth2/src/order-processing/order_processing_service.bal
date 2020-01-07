import ballerina/auth;
import ballerina/http;
import ballerina/log;
import ballerina/oauth2;

auth:OutboundBasicAuthProvider outboundBasiAuthProvider = new({
    username: "admin",
    password: "admin"
});
http:BasicAuthHandler outboundBasicAuthHandler = new(outboundBasiAuthProvider);

oauth2:InboundOAuth2Provider inboundOAuth2Provider = new({
    url: "https://localhost:9443/oauth2/introspect",
    clientConfig: {
        auth: {
            authHandler: outboundBasicAuthHandler
        },
        secureSocket: {
            trustStore: {
                path: "src/order-processing/keys/truststore.p12",
                password: "wso2carbon"
            }
        }
    }
});
http:BearerAuthHandler inboundOAuth2Handler = new(inboundOAuth2Provider);

listener http:Listener ep = new(9008, config = {
    auth: {
        authHandlers: [inboundOAuth2Handler]
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
        json invPayload = {"items" :[{"code" : "10001","qty" : 4}]};
        log:printInfo(invPayload.toString());

        json success = {"status" : "order created successfully"};
        http:Response res = new;
        res.setPayload(success);
        checkpanic caller->respond(res);
    }
}
