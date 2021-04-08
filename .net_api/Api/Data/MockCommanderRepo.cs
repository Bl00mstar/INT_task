using System.Collections.Generic;
using Commander.Models;

namespace Commander.Data
{
    public class MockCommanderRepo : ICommanderRepo
    {
        public IEnumerable<Command> GetAppCommands()
        {
            var commands = new List<Command>
            {
                new Command{Id=0, HowTo="test test", Line="lineline", Platform="KP"},
                new Command{Id=1, HowTo="2 test", Line="3line", Platform="KP2"}
            };

            return commands;
        }

        public Command GetCommandById(int id)
        {
            return new Command{Id=0, HowTo="test test", Line="lineline", Platform="KP"};
        }
    }
}