using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace Dapr.Sample
{
    public class Program
    {
        public static Task Main(string[] args)
        {
            var builder = Host.CreateDefaultBuilder(args);

            builder.ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder
                    .Configure((ctx, app) =>
                    {
                        if (ctx.HostingEnvironment.IsDevelopment())
                        {
                            app.UseDeveloperExceptionPage();
                        }

                        app.UseRouting();
                        app.UseEndpoints(endpoints =>
                        {
                            endpoints.MapControllers();
                        });
                    });
            });

            builder.ConfigureLogging((context, loggingBuilder) =>
            {
                loggingBuilder.AddConsole();
            });

            builder.ConfigureServices(services =>
            {
                services.AddControllers();
            });

            return builder.RunConsoleAsync();
        }
    }
}
