using Microsoft.AspNetCore.Mvc;
using Dapr;
using Dapr.Client;

namespace orderprocessor.Controllers;

[ApiController]
public class OrderCreatedController : ControllerBase
{

    private readonly ILogger<OrderCreatedController> _logger;

    public OrderCreatedController(ILogger<OrderCreatedController> logger)
    {
        _logger = logger;
    }

    [Topic("orderpubsub", "ordercreated")]
    [HttpPost("ordercreated")]
    public async Task Post([FromBody]Order order, [FromServices] DaprClient daprClient)
    {
        Console.WriteLine($"{DateTime.Now.ToLongTimeString()} Processing order " + order.Id.ToString());
        await daprClient.SaveStateAsync<Order>("statestore", order.Id.ToString(), order);        
        await Task.Delay(2000);
        Console.WriteLine($"{DateTime.Now.ToLongTimeString()} Done with order " + order.Id.ToString());
    }    
}