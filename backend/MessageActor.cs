using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Dapr.Actors;
using Dapr.Actors.Runtime;

namespace Dapr.Sample
{
    public class MessageActor : Actor, IMessageActor
    {
        public MessageActor(ActorService service, ActorId id)
            : base(service, id)
        {
        }

        public async Task AddMessage(string message)
        {
            var stateValue = await this.StateManager.TryGetStateAsync<List<string>>("state");

            if (stateValue.HasValue)
            {
                stateValue.Value.Add(message);
            }
            else
            {
                var messages = new List<string>
                {
                    message
                };

                await this.StateManager.SetStateAsync("state", messages);
            }
        }

        public async Task<IEnumerable<string>> GetMessages()
        {
            var stateValue = await this.StateManager.TryGetStateAsync<List<string>>("state");

            return stateValue.HasValue ? stateValue.Value : new List<string>();
        }
    }
}
