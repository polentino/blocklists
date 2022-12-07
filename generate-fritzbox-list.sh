#!/usr/bin/env scala

@main def parse = {

  import java.nio.file._
  import java.nio.charset.StandardCharsets

  import scala.io.Source

  val projectRoot = Paths.get(".").toAbsolutePath
  // generated by google/localized with rx
  //    0.0.0.0  google.(\w+).(\w+) #\s\p{Print}+
  val domainExceptions = List(
    "co.ao", "co.bw", "co.ck", "co.cr", "co.id", "co.il", "co.in", "co.jp", "co.ke", "co.kr",
    "co.ls", "co.ma", "co.mz", "co.nz", "co.th", "co.tz", "co.ug", "co.uk", "co.uz", "co.ve",
    "co.vi", "co.za", "co.zm", "co.zw", "com.af", "com.ag", "com.ai", "com.ar", "com.au", "com.bd",
    "com.bh", "com.bn", "com.bo", "com.br", "com.bz", "com.co", "com.cu", "com.cy", "com.do",
    "com.ec", "com.eg", "com.et", "com.fj", "com.gh", "com.gi", "com.gt", "com.hk", "com.jm",
    "com.kh", "com.kw", "com.lb", "com.lc", "com.ly", "com.mm", "com.mt", "com.mx", "com.my",
    "com.na", "com.nf", "com.ng", "com.ni", "com.np", "com.om", "com.pa", "com.pe", "com.pg",
    "com.ph", "com.pk", "com.pr", "com.py", "com.qa", "com.sa", "com.sb", "com.sg", "com.sl",
    "com.sv", "com.tj", "com.tr", "com.tw", "com.ua", "com.uy", "com.vc", "com.vn"
  )

  Files.list(projectRoot.resolve("corporations"))
    .filter(Files.isDirectory(_))
    .forEach(walkSubPath)

  def isValidFilePath(path: Path) = {
    Files.isRegularFile(path) && {// todo use endswith
      path.getFileName.toString.toArray.dropWhile(_ != '.').toList match
        case Nil => true
        case _   => false
    }
  }

  def walkSubPath(path: Path): Unit = {
    Files.list(path)
      .filter(isValidFilePath)
      .forEach(parseFile)
  }

  def parseFile(path: Path): Unit = {
    val s     = Source.fromFile(path.toFile)
    val lines = s.getLines().toList
    s.close()
    println(s"!> parsing file $path")
    val result = lines
      .flatMap(_.replace("0.0.0.0 ", "").split('#').headOption.map(_.trim))
      .filter(_.nonEmpty)
      .map(line => {
        val toTake = if(domainExceptions.exists(d => line.endsWith(d))) 3 else 2
        line
          .split('.')
          .takeRight(toTake)
          .mkString(".")
      }).distinct

    val wholeContent = s"# Total nr. of domains in this file: ${result.size}\n" ++ result.mkString(" ")

    Files.write(path.resolveSibling(path.getFileName.toString + ".fritzbox"), wholeContent.getBytes(StandardCharsets.UTF_8))
  }
}