object WordCount extends App {
  io.Source.fromFile(args(0)).getLines.flatMap(_.split(' ')).toList.groupBy(identity).foreach(group =>
    printf("%s %d\n", group._1, group._2.length))
}
