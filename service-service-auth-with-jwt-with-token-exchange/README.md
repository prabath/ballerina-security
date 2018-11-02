## Securing service to service communication over TLS with JWT with token exchange

![alt text](./setup.png "Service to Service Communication Over TLS with JWT")

* **Step:0** Clone the git repo with the following command. If you are new to Ballerina, please check this out: https://ballerina.io/ 

```javascript
:\> git clone https://github.com/prabath/ballerina-security.git
```

* **Step:1** To start WSO2 Identity Server as a Docker container, run the following command from the directory **service-service-auth-with-jwt**. This will spin up Identity Server (STS) and to make sure it is started properly, try to access the URL https://localhost:9443 from the browser and it should show the home page. In case you change port mapping in 1-run-sts.sh, make sure to change the corresponding port in **4-get-jwt-from-sts.sh**. By default Identity Server starts on port 9443. It make take 40s to 50s to start up the Identity Server.

```javascript
:\> sh 1-run-sts.sh
```
* **Step:2** To start the Order Processing microservice, run the following command from the directory **service-service-auth-with-jwt**. This will start the service on HTTPS port 9008.

```javascript
:\> sh 2-run-order-processing.sh
```
* **Step:3** To start the Inventory microservice, run the following command from the directory **service-service-auth-with-jwt**. This will start the service on HTTPS port 9009.

```javascript
:\> sh 3-run-inventory.sh
```
* **Step:4** Run the following command from the directory **service-service-auth-with-jwt** to get JWT from the STS. Here we are using OAuth 2.0 password grant type to get the JWT. We use this only for the demo purpose - and in a production setup, you should try not to use the password grant type. Anyway, a JWT obtained from any of the grant type should be fine.

```javascript
:\> sh 4-get-jwt-from-sts.sh
{"access_token":"eyJ4NXQiOiJOVEF4Wm1NeE5ETXlaRGczTVRVMVpHTTBNekV6T0RKaFpXSTRORE5sWkRVMU9HRmtOakZpTVEiLCJraWQiOiJOVEF4Wm1NeE5ETXlaRGczTVRVMVpHTTBNekV6T0RKaFpXSTRORE5sWkRVMU9HRmtOakZpTVEiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhZG1pbkBjYXJib24uc3VwZXIiLCJhdWQiOiJKRDBjMVpkR2dJV2ZOVXJuSkRRb3dPN2p5UDhhIiwibmJmIjoxNTQxMTIwMDQ5LCJhenAiOiJKRDBjMVpkR2dJV2ZOVXJuSkRRb3dPN2p5UDhhIiwic2NvcGUiOiJwbGFjZS1vcmRlciIsImlzcyI6IndzbzJpcyIsImV4cCI6MTU0MTEyMzY0OSwiaWF0IjoxNTQxMTIwMDQ5LCJqdGkiOiJlYTMyNDhiYi0xY2IyLTQwMjctYjEyMy0yMWIwZmE2YTA2ODYifQ.QRT8bt9g673i7Z1YVYXnmccRIIUIWdA_3JmkbulOkI7-7PShT2xpOAeRbuU0dPt18IhnqYep4bZB7LmUk7fmYSDHPzLxglpApFVIIAOOh9l_4Zg_03yARBazCmB6IA5-p_iMoETRgMHPo5dqP-Gyj8QzlZv0B-zuIcuCp15-BT643ng7giLzE1714Q1AOdc64Yxr5S8HCugrYYb4VEQAfH_iTg4xdvcu-oX55eD9sJxsXlE74DnFdQnIlnFH3gSlQGGmf-f36EpwJ9ydTc2YomNcGcopOkCGmjz_6ofLJHMJmFG5l1GrF1mEv-HkDkmlMt-RxX3DuLfOrJ3dkfNUIA","refresh_token":"f732d56d-49d9-370f-a982-20c9db107d35","scope":"place-order","token_type":"Bearer","expires_in":3600}
```
* Now, we need to copy the value of the **access_token** parameter, from the above response and export it as TOKEN to the shell environment. The value of the TOKEN environment variable is referred by **5-call-order-processing.sh**.

```javascript
:\> export TOKEN=eyJ4NXQiOiJOVEF4Wm1NeE5ETXlaRGczTVRVMVpHTTBNekV6T0RKaFpXSTRORE5sWkRVMU9HRmtOakZpTVEiLCJraWQiOiJOVEF4Wm1NeE5ETXlaRGczTVRVMVpHTTBNekV6T0RKaFpXSTRORE5sWkRVMU9HRmtOakZpTVEiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhZG1pbkBjYXJib24uc3VwZXIiLCJhdWQiOiJKRDBjMVpkR2dJV2ZOVXJuSkRRb3dPN2p5UDhhIiwibmJmIjoxNTQxMTIwMDQ5LCJhenAiOiJKRDBjMVpkR2dJV2ZOVXJuSkRRb3dPN2p5UDhhIiwic2NvcGUiOiJwbGFjZS1vcmRlciIsImlzcyI6IndzbzJpcyIsImV4cCI6MTU0MTEyMzY0OSwiaWF0IjoxNTQxMTIwMDQ5LCJqdGkiOiJlYTMyNDhiYi0xY2IyLTQwMjctYjEyMy0yMWIwZmE2YTA2ODYifQ.QRT8bt9g673i7Z1YVYXnmccRIIUIWdA_3JmkbulOkI7-7PShT2xpOAeRbuU0dPt18IhnqYep4bZB7LmUk7fmYSDHPzLxglpApFVIIAOOh9l_4Zg_03yARBazCmB6IA5-p_iMoETRgMHPo5dqP-Gyj8QzlZv0B-zuIcuCp15-BT643ng7giLzE1714Q1AOdc64Yxr5S8HCugrYYb4VEQAfH_iTg4xdvcu-oX55eD9sJxsXlE74DnFdQnIlnFH3gSlQGGmf-f36EpwJ9ydTc2YomNcGcopOkCGmjz_6ofLJHMJmFG5l1GrF1mEv-HkDkmlMt-RxX3DuLfOrJ3dkfNUIA
```
* If you want to decode and see what is in the above JWT, go to https://jwt.io/ and paste the value of the TOKEN (or the JWT) there.

* **Step:5** Run the following command from the directory **service-service-auth-with-jwt** to invoke rge Order Processing microservice. **Make sure to run this command from the same terminal you exported the value of the JWT to TOKEN environment variable**.

```javascript
:\> sh 5-call-order-processing.sh

{"status":"order created successfully"}
```