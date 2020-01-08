## Securing service with OAuth2

![alt text](./setup.png "Securing servie with OAuth2")

* **Step:0** Clone the git repo with the following command. If you are new to Ballerina, please check this out: https://ballerina.io/. Ballerina version: 1.1.0

```javascript
:\> git clone https://github.com/prabath/ballerina-security.git
```

* **Step:1** To start WSO2 Identity Server as a Docker container, run the following command from the directory **service-auth-with-oauth2**. This will spin up Identity Server (STS) and to make sure it is started properly, try to access the URL https://localhost:9443 from the browser and it should show the home page. In case you change port mapping in 1-run-sts.sh, make sure to change the corresponding port in **3-get-oauth2-token-from-sts.sh**. By default Identity Server starts on port 9443. It make take 40s to 50s to start up the Identity Server.

```javascript
:\> sh 1-run-sts.sh
```
* **Step:2** To start the Order Processing microservice, run the following command from the directory **service-auth-with-oauth2**. This will start the service on HTTPS port 9008.

```javascript
:\> sh 2-run-order-processing.sh
```
* **Step:3** Run the following command from the directory **service-auth-with-oauth2** to get JWT from the STS. Here we are using OAuth 2.0 password grant type to get the JWT. We use this only for the demo purpose - and in a production setup, you should try not to use the password grant type. Anyway, a JWT obtained from any of the grant type should be fine.

```javascript
:\> sh 3-get-oauth2-token-from-sts.sh
{"access_token":"eyJ4NXQiOiJOVEF4Wm1NeE5ETXlaRGczTVRVMVpHTTBNekV6T0RKaFpXSTRORE5sWkRVMU9HRmtOakZpTVEiLCJraWQiOiJOVEF4Wm1NeE5ETXlaRGczTVRVMVpHTTBNekV6T0RKaFpXSTRORE5sWkRVMU9HRmtOakZpTVEiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhZG1pbkBjYXJib24uc3VwZXIiLCJhdWQiOiIzVlR3Rms3dTFpMzY2d3ptdnBKX0xabGZBVjRhIiwibmJmIjoxNTQxMTUyMjAxLCJhenAiOiIzVlR3Rms3dTFpMzY2d3ptdnBKX0xabGZBVjRhIiwic2NvcGUiOiJwbGFjZS1vcmRlciIsImlzcyI6IndzbzJpcyIsImV4cCI6MTU0MTE1ODIwMSwiaWF0IjoxNTQxMTUyMjAxLCJqdGkiOiJkYzMxOTQyNS03YjAxLTQyMTAtOTcxYy1jNTcyMjViMjM0YTIifQ.KTyKSzok3flFxMRfxqNOzhTJXQoKifz2sxMSL1D5wKeloT1jJ8I1nd6B-ZC_5bQvgu5iywyWG7heaX3p-2r6YzsK-YbRKBHuEp_ubCgpt0bv8ae7Am3iwXBBjc5KlOkJY7s8Ciatl1tdrA0vab0yTS0SjSA5QYHDLvDqoZxyDgvZAmUxM8QhtrLV_DJHltJjIf-YCqM_ASGqI6N64kr1vQugb8_Tgr5epgaZDDYq1mgfJXQtcK1iuOAWH8FjhGzHaJ7-LfsIuP9jOrEm7aJtkdFJTpfG6gWwRKmuKQFqXvaTso-DP0QPAhsv2x10Xv-g6ssQ6CuZ_E8m3-GsvXYdog","refresh_token":"f44abeb7-5938-34cd-a1a2-7b95bc7a518f","scope":"place-order","token_type":"Bearer","expires_in":6000}
```
* Now, we need to copy the value of the **access_token** parameter, from the above response and export it as TOKEN to the shell environment. The value of the TOKEN environment variable is referred by **4-call-order-processing.sh**.

```javascript
:\> export TOKEN=eyJ4NXQiOiJOVEF4Wm1NeE5ETXlaRGczTVRVMVpHTTBNekV6T0RKaFpXSTRORE5sWkRVMU9HRmtOakZpTVEiLCJraWQiOiJOVEF4Wm1NeE5ETXlaRGczTVRVMVpHTTBNekV6T0RKaFpXSTRORE5sWkRVMU9HRmtOakZpTVEiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJhZG1pbkBjYXJib24uc3VwZXIiLCJhdWQiOiIzVlR3Rms3dTFpMzY2d3ptdnBKX0xabGZBVjRhIiwibmJmIjoxNTQxMTUyMjAxLCJhenAiOiIzVlR3Rms3dTFpMzY2d3ptdnBKX0xabGZBVjRhIiwic2NvcGUiOiJwbGFjZS1vcmRlciIsImlzcyI6IndzbzJpcyIsImV4cCI6MTU0MTE1ODIwMSwiaWF0IjoxNTQxMTUyMjAxLCJqdGkiOiJkYzMxOTQyNS03YjAxLTQyMTAtOTcxYy1jNTcyMjViMjM0YTIifQ.KTyKSzok3flFxMRfxqNOzhTJXQoKifz2sxMSL1D5wKeloT1jJ8I1nd6B-ZC_5bQvgu5iywyWG7heaX3p-2r6YzsK-YbRKBHuEp_ubCgpt0bv8ae7Am3iwXBBjc5KlOkJY7s8Ciatl1tdrA0vab0yTS0SjSA5QYHDLvDqoZxyDgvZAmUxM8QhtrLV_DJHltJjIf-YCqM_ASGqI6N64kr1vQugb8_Tgr5epgaZDDYq1mgfJXQtcK1iuOAWH8FjhGzHaJ7-LfsIuP9jOrEm7aJtkdFJTpfG6gWwRKmuKQFqXvaTso-DP0QPAhsv2x10Xv-g6ssQ6CuZ_E8m3-GsvXYdog
```
* If you want to decode and see what is in the above JWT, go to https://jwt.io/ and paste the value of the TOKEN (or the JWT) there.

* **Step:4** Run the following command from the directory **service-auth-with-oauth2** to invoke rge Order Processing microservice. **Make sure to run this command from the same terminal you exported the value of the JWT to TOKEN environment variable**.

```javascript
:\> sh 4-call-order-processing.sh

{"status":"order created successfully"}
```
