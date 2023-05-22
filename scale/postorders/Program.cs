using System;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using System.Text.Json;
using System.Text;



namespace PostOrder
{
    class Program
    {

        static async Task Main()
        {            
            var client =  new Dapr.Client.DaprClientBuilder().Build();

            for (int i = 1; i <= 2000; i++)
            {
                var order = new Order()
                {
                    Item = $"Item {i}",
                    Quantity = 1
                };

                await client.PublishEventAsync<Order>("orderpubsub", "ordercreated", order);
                
                System.Console.WriteLine($"Send Message {i}");
                //await Task.Delay(50);
            }

        }
    }

    public class Order
    {
        public Order()
        {
            this.Id = Guid.NewGuid();
            this.CreatedAt = DateTime.Now;
            this.Item = string.Empty;
        }         
        public Guid Id { get; set; }
        public DateTime CreatedAt { get; set; }
        public string? Item { get; set; }
        public int Quantity { get; set; }

    }
}    