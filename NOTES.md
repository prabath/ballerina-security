* Enable tracing : `$ ballerina run xxxxx.bal --b7a.http.tracelog.console=true`

* Enable debug logs : `$ ballerina run xxxxx.bal --b7a.log.level=DEBUG`

* Convert JKS to PKCS12: `$ keytool -importkeystore -srckeystore [MY_KEYSTORE.jks] -destkeystore [MY_FILE.p12] -srcstoretype JKS - deststoretype PKCS12 -deststorepass [PASSWORD_PKCS12]`

* Ballerina default key store locations :
  * MacOs - `/Library/Ballerina/distributions/jballerina-1.1.0/bre/security`
  * Linux - `/usr/lib/ballerina/distributions/jballerina-1.1.0/bre/security`
