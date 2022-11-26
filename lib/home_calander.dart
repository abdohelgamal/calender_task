import 'package:calender_task/add_event_dialog.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool get isMonthView => crossFadeState == CrossFadeState.showFirst;
  late final CalendarController monthViewController;
  late final CalendarController scheduleViewController;
  CrossFadeState crossFadeState = CrossFadeState.showFirst;
  List<DateTime> dates = [];
  @override
  void initState() {
    dates = List.generate(DateTime(2022, DateTime.now().month + 1, 0).day,
        (index) => DateTime(2022, DateTime.now().month, index + 1));
    monthViewController = CalendarController();
    scheduleViewController = CalendarController();
    Future.delayed(const Duration(milliseconds: 500), () {
      monthViewController.selectedDate = DateTime.now();
      scheduleViewController.selectedDate = monthViewController.selectedDate!;
    });
    super.initState();
  }

  @override
  void dispose() {
    monthViewController.dispose();
    scheduleViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: !isMonthView
          ? SizedBox.square(
              dimension: 50,
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AddEventDialog();
                    },
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 22,
                ),
              ),
            )
          : null,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: TextButton.icon(
          onPressed: () {
            setState(
              () {
                if (crossFadeState == CrossFadeState.showFirst) {
                  crossFadeState = CrossFadeState.showSecond;
                } else {
                  crossFadeState = CrossFadeState.showFirst;
                }
              },
            );
          },
          icon: const Icon(Icons.arrow_back_ios_rounded),
          label: Text(
            formatDate(monthViewController.selectedDate ?? DateTime.now(),
                isMonthView ? [yyyy] : [MM]),
          ),
        ),
        leadingWidth: 130,
      ),
      body: AnimatedCrossFade(
        crossFadeState: crossFadeState,
        duration: const Duration(milliseconds: 800),
        //month view
        firstChild: SfCalendar(
          dataSource: MeetingDataSource(_getDataSource()),
          controller: monthViewController,
          headerDateFormat: 'MMMM',
          headerStyle: CalendarHeaderStyle(
            textStyle: TextStyle(color: Theme.of(context).primaryColor),
          ),
          view: CalendarView.month,
          onSelectionChanged: (calendarSelectionDetails) {
            setState(() {
              if (calendarSelectionDetails.date != null) {
                crossFadeState = CrossFadeState.showSecond;
                scheduleViewController.selectedDate =
                    monthViewController.selectedDate;
              } else if (calendarSelectionDetails.date ==
                  monthViewController.selectedDate) {
                monthViewController.selectedDate = null;
                crossFadeState = CrossFadeState.showFirst;
              }
            });
          },
          monthViewSettings: const MonthViewSettings(
              navigationDirection: MonthNavigationDirection.vertical,
              appointmentDisplayMode: MonthAppointmentDisplayMode.none,
              showTrailingAndLeadingDates: false,
              showAgenda: false),
          firstDayOfWeek: 6,
          viewNavigationMode: ViewNavigationMode.snap,
          selectionDecoration: const BoxDecoration(
            border: Border.fromBorderSide(BorderSide.none),
          ),
          monthCellBuilder: (context, details) {
            return Container(
              padding: const EdgeInsets.only(top: 7, bottom: 16),
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: 0.6,
                    color: Color(0xFFCFCFCF),
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: details.date == monthViewController.selectedDate
                        ? Theme.of(context).primaryColor
                        : Colors.transparent),
                child: Text(
                  details.date.day.toString(),
                  style: TextStyle(
                      color: details.date == monthViewController.selectedDate
                          ? Colors.white
                          : Colors.black),
                ),
              ),
            );
          },
        ),
        secondChild:
            // schedule view
            Column(
          children: [
            SizedBox(
              height: 90,
              child: ListView.builder(
                itemCount: dates.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        scheduleViewController.selectedDate = dates[index];
                        scheduleViewController.displayDate = dates[index];
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(formatDate(dates[index], [D])),
                        const SizedBox(
                          height: 10,
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dates[index] ==
                                        scheduleViewController.selectedDate
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent),
                            child: Text(
                              formatDate(dates[index], [d]),
                              style: TextStyle(
                                  color: dates[index] ==
                                          scheduleViewController.selectedDate
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: SfCalendar(
                controller: scheduleViewController,
                scheduleViewSettings: const ScheduleViewSettings(
                  hideEmptyScheduleWeek: true,
                  monthHeaderSettings: MonthHeaderSettings(height: 50),
                ),
                dataSource: MeetingDataSource(_getDataSource()),
                headerDateFormat: '',
                headerHeight: 0,
                headerStyle: CalendarHeaderStyle(
                  textStyle: TextStyle(color: Theme.of(context).primaryColor),
                ),
                view: CalendarView.day,
                timeSlotViewSettings: const TimeSlotViewSettings(
                    timeRulerSize: 62,
                    timelineAppointmentHeight: 59,
                    timeIntervalHeight: 60),
                firstDayOfWeek: 6,
                viewNavigationMode: ViewNavigationMode.snap,
                selectionDecoration: const BoxDecoration(
                  border: Border.fromBorderSide(BorderSide.none),
                ),
                appointmentBuilder: (context, calendarAppointmentDetails) {
                  return Container(
                    alignment: AlignmentDirectional.centerStart,
                    padding: const EdgeInsetsDirectional.only(start: 15),
                    decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      calendarAppointmentDetails.appointments
                          .toList()[0]
                          .eventName,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Meeting> _getDataSource() {
  final List<Meeting> meetings = <Meeting>[];
  final DateTime today = DateTime.now();
  final DateTime startTime =
      DateTime(today.year, today.month, today.day, 5, 15, 0);
  final DateTime endTime = startTime.add(const Duration(minutes: 45));
  meetings.add(Meeting(
      'Conference', startTime, endTime, const Color(0xFF0F8644), false));
  meetings.add(Meeting(
      'planning',
      endTime.add(const Duration(minutes: 150)),
      endTime.add(const Duration(minutes: 200)),
      const Color(0xFF0F8644),
      false));
  return meetings;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);
  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
