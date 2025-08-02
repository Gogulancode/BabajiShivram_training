using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Text.Json;

class Program
{
    private static readonly HttpClient client = new HttpClient();

    static async Task Main(string[] args)
    {
        try
        {
            // Test the API endpoint
            var response = await client.PostAsync("https://localhost:7001/api/roleaccess/seed-data", null);
            
            if (response.IsSuccessStatusCode)
            {
                var content = await response.Content.ReadAsStringAsync();
                Console.WriteLine("✅ Role mapping seeded successfully!");
                Console.WriteLine($"Response: {content}");
            }
            else
            {
                Console.WriteLine($"❌ Error: {response.StatusCode}");
                var error = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"Error content: {error}");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Exception: {ex.Message}");
        }
    }
}
