* Enbale tracing : ballerina run -e b7a.http.tracelog.console=true xxxxx.bal

* Enbale debug logs : ballerina run -e b7a.log.level=DEBUG xxxxx.bal

* Convert JKS to PKCS12: keytool -importkeystore -srckeystore [MY_KEYSTORE.jks] -destkeystore [MY_FILE.p12] -srcstoretype JKS - deststoretype PKCS12 -deststorepass [PASSWORD_PKCS12]

* Ballerina default key store in Mac : /Library/Ballerina/ballerina-0.982.0/bre/security
