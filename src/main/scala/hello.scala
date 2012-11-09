import org.joda.time.DateTime

object HelloWorld {
  val now = new DateTime
  def main(args: Array[String]) =
    println("Hello world! Time is %d:%d.".format(now.getHourOfDay, now.getMinuteOfHour))
}
