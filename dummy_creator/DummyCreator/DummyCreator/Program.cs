using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

namespace DummyCreator
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length == 0)
                return;

            DirectoryInfo dir = new DirectoryInfo(args[0]);
            if (dir.Exists)
            {
                FileStream output = new FileStream("dummy.xml", FileMode.Create, FileAccess.Write);
                StreamWriter sw = new StreamWriter(output);

                Regex pathRegex = new Regex("(?<=images).+");
                string files = string.Join("\r\n", dir.GetFiles("*", SearchOption.AllDirectories)
                    .Select(f =>
                    {
                        Match match = pathRegex.Matches(f.FullName).Cast<Match>().FirstOrDefault();
                        return match != null ? "<Image src=\"file://{images}" + match.Value.Replace("\\", "/") + "\" />" : null;
                    }).ToArray());

                sw.Write(string.Format("<root> <Panel> {0} </Panel></root>", files));
                sw.Close();
                output.Close();
            }
        }
    }
}
