## Fine-grained access control with Open Policy Agent (OPA)

![alt text](./setup.png "Fine-grained access control with Open Policy Agent (OPA)")

* **Step:0** Clone the git repo with the following command. If you are new to Ballerina, please check this out: https://ballerina.io/. Ballerina version: 0.983.0.

```javascript
:\> git clone https://github.com/prabath/ballerina-security.git
```

* **Step:1** To start WSO2 Identity Server as a Docker container, run the following command from the directory **fine-grained-service-authz-with-opa**. This will spin up Identity Server (STS) and to make sure it is started properly, try to access the URL https://localhost:9443 from the browser and it should show the home page. In case you change port mapping in 1-run-sts.sh, make sure to change the corresponding port in **4-get-jwt-from-sts.sh**. By default Identity Server starts on port 9443. It make take 40s to 50s to start up the Identity Server.

```javascript
:\> sh 1-run-sts.sh
```
* **Step:2** To start OPA server as a Docker container, run the following command from the directory **fine-grained-service-authz-with-opa**. This will spin up the OPA server HTTP port 8181. The policy server is initialized with the policy **fine-grained-service-authz-with-opa/opa/orderprocessing.rego**.

```javascript
:\> sh 2-run-opa.sh
```
* **Step:3** To start the Order Processing microservice, run the following command from the directory **fine-grained-service-authz-with-opa**. This will start the service on HTTPS port 9008.

* **Step:4** Run the following command from the directory **fine-grained-service-authz-with-opa** to get JWT from the STS. Here we are using OAuth 2.0 password grant type to get the JWT. We use this only for the demo purpose - and in a production setup, you should try not to use the password grant type. Anyway, a JWT obtained from any of the grant type should be fine.

```javascript
:\> sh 4-get-jwt-from-sts.sh
{"access_token":"eyJ4NXQiOiJOVEF4Wm1NeE5ETXlaRGczTVRVMVpHTTBNekV6T0RKaFpXSTRORE5sWkRVMU9HRmtOakZpTVEiLCJraWQiOiJOVEF4Wm1NeE5ETXlaRGczTVRVMVpHTTBNekV6T0RKaFpXSTRORE5sWkRVMU9HRmtOakZpTVEiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhZG1pbkBjYXJib24uc3VwZXIiLCJhdWQiOiIzVlR3Rms3dTFpMzY2d3ptdnBKX0xabGZBVjRhIiwibmJmIjoxNTQxMjE3OTUxLCJhenAiOiIzVlR3Rms3dTFpMzY2d3ptdnBKX0xabGZBVjRhIiwiaXNzIjoid3NvMmlzIiwiZXhwIjoxNTQxMjIzOTUxLCJpYXQiOjE1NDEyMTc5NTEsImp0aSI6IjRjMjllODBhLWYwYWMtNDU5Yi05NzcyLWIzZjQ2NzllY2I2MyJ9.f9THJs5ZJsxn18Oozf42-5pu29-o5XEy9FUDH0EFgoG79i8kWiQ0ZFGw_TXMOFhfH4-tW1prc1omkA1TXaoEXlms3InwoFd-COfLPNDpdRrZ48E17OhnXTExiY7zn7-7VC--SnUO1faOUoZhg3V60HPqLVrf0c2fbXgIRnOvMtlgkf3zNtxxqG8EzxuqVsWiaXMfGZ54eiGokFVKFI1vsi33Vfz6RIXxPd6EBZWVE4V1vZ7LSAWEdVKJj8phiKDgzHM87uNn66oJ9yJeV4Z8Rr6gcXC-FFMpyWMSxB_KYyQjfktIDyzLwxqsbnY5B4aHLG9As0-oNAVrsffXyg70hA","refresh_token":"66b82830-e7e1-3c6b-9bdc-0f3de4b1d294","token_type":"Bearer","expires_in":6000}
```
* Now, we need to copy the value of the **access_token** parameter, from the above response and export it as TOKEN to the shell environment. The value of the TOKEN environment variable is referred by **5-call-order-processing.sh**.

```javascript
:\> export TOKEN=eyJ4NXQiOiJOVEF4Wm1NeE5ETXlaRGczTVRVMVpHTTBNekV6T0RKaFpXSTRORE5sWkRVMU9HRmtOakZpTVEiLCJraWQiOiJOVEF4Wm1NeE5ETXlaRGczTVRVMVpHTTBNekV6T0RKaFpXSTRORE5sWkRVMU9HRmtOakZpTVEiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhZG1pbkBjYXJib24uc3VwZXIiLCJhdWQiOiIzVlR3Rms3dTFpMzY2d3ptdnBKX0xabGZBVjRhIiwibmJmIjoxNTQxMjE3OTUxLCJhenAiOiIzVlR3Rms3dTFpMzY2d3ptdnBKX0xabGZBVjRhIiwiaXNzIjoid3NvMmlzIiwiZXhwIjoxNTQxMjIzOTUxLCJpYXQiOjE1NDEyMTc5NTEsImp0aSI6IjRjMjllODBhLWYwYWMtNDU5Yi05NzcyLWIzZjQ2NzllY2I2MyJ9.f9THJs5ZJsxn18Oozf42-5pu29-o5XEy9FUDH0EFgoG79i8kWiQ0ZFGw_TXMOFhfH4-tW1prc1omkA1TXaoEXlms3InwoFd-COfLPNDpdRrZ48E17OhnXTExiY7zn7-7VC--SnUO1faOUoZhg3V60HPqLVrf0c2fbXgIRnOvMtlgkf3zNtxxqG8EzxuqVsWiaXMfGZ54eiGokFVKFI1vsi33Vfz6RIXxPd6EBZWVE4V1vZ7LSAWEdVKJj8phiKDgzHM87uNn66oJ9yJeV4Z8Rr6gcXC-FFMpyWMSxB_KYyQjfktIDyzLwxqsbnY5B4aHLG9As0-oNAVrsffXyg70hA
```
* If you want to decode and see what is in the above JWT, go to https://jwt.io/ and paste the value of the TOKEN (or the JWT) there.

* **Step:5** Run the following command from the directory **fine-grained-service-authz-with-opa** to invoke the Order Processing microservice. **Make sure to run this command from the same terminal you exported the value of the JWT to TOKEN environment variable**.

```javascript
:\> sh 5-call-order-processing.sh

{"status":"order created successfully"}
```
* **Step:6** Step-6 in the above diagram happens before the step-5 produces the response. There the Order Processing microservice talks to the OPA server to check whether the user from the provided JWT is elgible to do a POST to the orders resource.

* **TODO** At the moment the call to the OPA server is done at the service level. This has to be moved to a reusable interceptor.
