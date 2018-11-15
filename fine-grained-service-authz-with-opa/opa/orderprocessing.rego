package authz.orderprocessing

allow {
    input.user = "admin2@carbon.super"
    input.method = "POST"
    input.path = "orders"
}

