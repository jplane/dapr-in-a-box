using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Dapr.Actors;
using Dapr.Actors.Client;

namespace Dapr.Sample
{
    [ApiController]
    [Route("messages")]
    public class MessagesController : ControllerBase
    {
        public MessagesController()
        {
        }

        [HttpPost]
        [Route("{actorId}")]
        public async Task AddMessage(string actorId, [FromBody] string message)
        {
            var actor = ActorProxy.Create<IMessageActor>(new ActorId(actorId), "MessageActor");

            await actor.AddMessage(message).ConfigureAwait(false);
        }

        [HttpGet]
        [Route("{actorId}")]
        public async Task<IEnumerable<string>> GetMessages(string actorId)
        {
            var actor = ActorProxy.Create<IMessageActor>(new ActorId(actorId), "MessageActor");

            return await actor.GetMessages().ConfigureAwait(false);
        }
    }
}
