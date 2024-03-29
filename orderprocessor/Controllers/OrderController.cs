using Microsoft.AspNetCore.Mvc;
using Dapr;
using Dapr.Client;
using System.Data.SqlClient;

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
        await daprClient.SaveStateAsync<Order>("statestore", order.Id.ToString(), order);   

        //Simulate some extra work     
        await Task.Delay(2000);
    }       
}