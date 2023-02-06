# Run Dapr sidecar

http://localhost:5109/order
http://localhost:3500/v1.0/invoke/orderapi/method/order

get-process orderapi, daprd




# Service invocation
```csharp
var client = new Dapr.Client.DaprClientBuilder().Build();
await client.InvokeMethodAsync<Order>("orderapi", "order", order);
```

# State management

```csharp
var client = new Dapr.Client.DaprClientBuilder().Build();
await client.SaveStateAsync<Order>("statestore", order.Id.ToString(), order);
```

# Pub/sub

```csharp
await client.PublishEventAsync<Order>("orderpubsub", "ordercreated", order);
```

# Output Bindings

```csharp
await client.InvokeBindingAsync("twilio", "create", "Order created:" + order.Id);
```

# Input bindings

```json
{
    "Item": "Racing car",
    "Quantity": 42
}
```

# Hosting
http://40.114.168.43 (app in k8s)
http://20.56.206.47 (zipkin dashboard)
