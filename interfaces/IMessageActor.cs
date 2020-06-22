using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Dapr.Actors;

namespace Dapr.Sample
{
    public interface IMessageActor : IActor
    {
        Task AddMessage(string message);
        Task<IEnumerable<string>> GetMessages();
    }
}
