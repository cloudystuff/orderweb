using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Cosmos;

namespace orderapi.Controllers;

[ApiController]
[Route("[controller]")]
public class OrderController : ControllerBase
{
    private readonly ILogger<OrderController> _logger;

    public OrderController(ILogger<OrderController> logger)
    {
        _logger = logger; 
    }

    [HttpPost]
    public async Task Post(Order order)
    {
        var client = new Dapr.Client.DaprClientBuilder().Build();
        await client.PublishEventAsync<Order>("orderpubsub", "ordercreated", order);
    }    

    [HttpGet]
    public async Task<List<Order>> Get()
    {
        int k=0;
        int y=1;
        int z=3;
        var query = "{" +
                    "}";

        var client = new Dapr.Client.DaprClientBuilder().Build();
        var orders = await client.QueryStateAsync<Order>("statestore", query);

        var result = new List<Order>();
        foreach(var i in orders.Results)
        {
            result.Add(i.Data);
        }
        return result;
    }
}
