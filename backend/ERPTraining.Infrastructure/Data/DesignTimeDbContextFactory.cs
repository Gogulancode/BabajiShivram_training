using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using System.IO;

namespace ERPTraining.Infrastructure.Data
{
    public class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
    {
        public ApplicationDbContext CreateDbContext(string[] args)
        {
            // Try to locate appsettings.json in the API project (works for most dev/CI environments)
            var solutionDir = Directory.GetParent(Directory.GetCurrentDirectory());
            while (solutionDir != null && !File.Exists(Path.Combine(solutionDir.FullName, "backend", "ERPTraining.API", "appsettings.json")))
                solutionDir = solutionDir.Parent;

            var apiPath = solutionDir != null
                ? Path.Combine(solutionDir.FullName, "backend", "ERPTraining.API")
                : Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), "..", "..", "ERPTraining.API"));

            var config = new ConfigurationBuilder()
                .SetBasePath(apiPath)
                .AddJsonFile("appsettings.json")
                .Build();

            var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
            optionsBuilder.UseSqlServer(config.GetConnectionString("DefaultConnection"));

            return new ApplicationDbContext(optionsBuilder.Options);
        }
    }
}
