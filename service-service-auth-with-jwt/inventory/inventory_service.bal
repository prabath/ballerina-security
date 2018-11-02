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
        path: "inventory/keys/truststore.p12",
        password: "wso2carbon"
    }
};

endpoint http:SecureListener ep {
    port: 9009,
    authProviders:[jwtAuthProvider],

    secureSocket: {
        keyStore: {
            path: "inventory/keys/keystore.p12",
            password: "wso2carbon"
        },
        trustStore: {
            path: "inventory/keys/truststore.p12",
            password: "wso2carbon"
        }
    }
};

@http:ServiceConfig {
    basePath: "/inventory",
    authConfig: {
        authentication: { enabled: true }
    }
}
service<http:Service> inventory bind ep {
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/items",
        authConfig: {
            scopes: ["place-order"]
        }
    }
    updateItems(endpoint caller, http:Request req) {
        http:Response res = new;
        res.setPayload({"status" : "items updated in the inventory."});
        _ = caller->respond(res);
    }
}