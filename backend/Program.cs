using Microsoft.Extensions.Hosting;
using System.Threading.Tasks;
using Dapr.Actors.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Dapr.Sample
{
    public class Program
    {
        public static async Task Main(string[] args)
        {
            var builder = Host.CreateDefaultBuilder(args)
                              .ConfigureWebHostDefaults(webBuilder =>
                              {
                                  webBuilder.UseActors(runtime => runtime.RegisterActor<MessageActor>())
                                            .Configure((ctx, app) =>
                                            {
                                                if (ctx.HostingEnvironment.IsDevelopment())
                                                {
                                                    app.UseDeveloperExceptionPage();
                                                }
                                                app.UseRouting();
                                            });
                              });

            builder.ConfigureLogging((context, loggingBuilder) =>
            {
                loggingBuilder.AddConsole();
            });

            await builder.RunConsoleAsync();
        }
    }
}
