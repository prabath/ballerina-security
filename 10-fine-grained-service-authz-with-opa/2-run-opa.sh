docker run --mount type=bind,source="$(pwd)"/opa,target=/policies -p 8181:8181 openpolicyagent/opa run policies/orderprocessing.rego  --server  --log-level debug


