echo -e "REQUEST 1: 'generalUser1' has 'scope1' only. Hence, this user should not be able to call 'sayHello' resource\n"
curl -i -k -u generalUser1:password https://localhost:9090/hello/sayHello

echo -e "\n\n\nREQUEST 2: 'generalUser2' has 'scope2' only. Hence, this user should be able to call 'sayHello' resource\n"
curl -i -k -u generalUser2:password https://localhost:9090/hello/sayHello

echo -e "\n"
