package authz.orderprocessing

allow {
    input.user = "admin@carbon.super"
    input.method = "POST"
    input.path = "orders"
}

