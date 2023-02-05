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
        Console.WriteLine($"{DateTime.Now.ToLongTimeString()} Processing order " + order.Id);
        await daprClient.SaveStateAsync<Order>("statestore", order.Id.ToString(), order);        
        await Task.Delay(2000);
        Console.WriteLine($"{DateTime.Now.ToLongTimeString()} Done with order " + order.Id);
    }    

    [HttpGet("badcontroller")]
    public async Task BadControllerAction(string name, string id)
    {
        SqlConnection con = new SqlConnection("localdb");
        var cmd = new SqlCommand("UPDATE dbo.Person SET Name = " + name + " WHERE Id = " + id, con);
        var result = await cmd.ExecuteScalarAsync();
    }        
}