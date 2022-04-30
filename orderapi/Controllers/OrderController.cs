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
        try 
        {
            string databaseName = "daprdemo";
            string containerName = "orders";
            string account = "https://daprstate.documents.azure.com:443/";
            string key = "h8PNFT7S8DeM2vKJZXaIc6oUwMRh6c1tnLXWk6u4wMxvrgkPwIyyq5OY5oliua9ITUPRPnpWBOgd5Y2wZNhb5A==";
            
            var client = new Microsoft.Azure.Cosmos.CosmosClient(account, key);
            var _container = client.GetContainer(databaseName, containerName);

            var queryString = $"SELECT * FROM orders[\"value\"]";
            var query = _container.GetItemQueryIterator<Order>(new QueryDefinition(queryString));

            var results = new List<Order>();
            while (query.HasMoreResults)
            {
                var response = await query.ReadNextAsync();
                
                results.AddRange(response.ToList());
            }
            return results;        

            //Not supported in ACA currently
            // var query = "{" +
            //             "}";

            // var client = new Dapr.Client.DaprClientBuilder().Build();
            // var orders = await client.QueryStateAsync<Order>("statestore", query);

            // var result = new List<Order>();
            // foreach(var i in orders.Results)
            // {
            //     result.Add(i.Data);
            // }
            // return result;
        }
        catch( Exception ex)
        {
            throw;
        }

    }



}
