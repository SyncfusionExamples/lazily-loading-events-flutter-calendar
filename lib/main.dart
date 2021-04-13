import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoadMoreCalendar(),
    );
  }
}

/// Widget of getting started calendar
class LoadMoreCalendar extends StatefulWidget {
  @override
  _LoadMoreCalendarState createState() => _LoadMoreCalendarState();
}

Map<DateTime, List<Appointment>> _dataCollection =
    <DateTime, List<Appointment>>{};

class _LoadMoreCalendarState extends State<LoadMoreCalendar> {
  _LoadMoreCalendarState();

  final _MeetingDataSource _events = _MeetingDataSource(<Appointment>[]);
  final CalendarController _calendarController = CalendarController();

  final List<CalendarView> _allowedViews = <CalendarView>[
    CalendarView.day,
    CalendarView.week,
    CalendarView.workWeek,
    CalendarView.month,
    CalendarView.schedule,
    CalendarView.timelineDay,
    CalendarView.timelineWeek,
    CalendarView.timelineWorkWeek,
    CalendarView.timelineMonth,
  ];

  @override
  void initState() {
    _calendarController.view = CalendarView.month;
    _addAppointmentDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Widget calendar = _getLoadMoreCalendar(_calendarController, _events);
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Load More'),
      ),
      body: Container(child: calendar),
    );
  }

  /// Creates the required appointment details as a list.
  void _addAppointmentDetails() {
    final List<String> _subjectCollection = <String>[];
    _subjectCollection.add('General Meeting');
    _subjectCollection.add('Plan Execution');
    _subjectCollection.add('Project Plan');
    _subjectCollection.add('Consulting');
    _subjectCollection.add('Support');
    _subjectCollection.add('Development Meeting');
    _subjectCollection.add('Scrum');
    _subjectCollection.add('Project Completion');
    _subjectCollection.add('Release updates');
    _subjectCollection.add('Performance Check');

    final List<Color> _colorCollection = <Color>[];
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF36B37B));
    _colorCollection.add(const Color(0xFF01A1EF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));
    _colorCollection.add(const Color(0xFF0A8043));

    final Random random = Random();
    _dataCollection = <DateTime, List<Appointment>>{};
    final DateTime today = DateTime.now();
    final DateTime rangeStartDate = DateTime(today.year, today.month, today.day)
        .add(const Duration(days: -1000));
    final DateTime rangeEndDate = DateTime(today.year, today.month, today.day)
        .add(const Duration(days: 1000));
    for (DateTime i = rangeStartDate;
        i.isBefore(rangeEndDate);
        i = i.add(Duration(days: 1 + random.nextInt(2)))) {
      final DateTime date = i;
      final int count = 1 + random.nextInt(3);
      for (int j = 0; j < count; j++) {
        final DateTime startDate = DateTime(
            date.year, date.month, date.day, 8 + random.nextInt(8), 0, 0);
        final int duration = random.nextInt(3);
        final Appointment meeting = Appointment(
            subject: _subjectCollection[random.nextInt(7)],
            startTime: startDate,
            endTime:
                startDate.add(Duration(hours: duration == 0 ? 1 : duration)),
            color: _colorCollection[random.nextInt(9)],
            isAllDay: false);

        if (_dataCollection.containsKey(date)) {
          final List<Appointment> meetings = _dataCollection[date]!;
          meetings.add(meeting);
          _dataCollection[date] = meetings;
        } else {
          _dataCollection[date] = [meeting];
        }
      }
    }
  }

  /// Returns the calendar widget based on the properties passed.
  SfCalendar _getLoadMoreCalendar(CalendarController calendarController,
      CalendarDataSource calendarDataSource) {
    return SfCalendar(
        controller: calendarController,
        dataSource: calendarDataSource,
        allowedViews: _allowedViews,
        loadMoreWidgetBuilder:
            (BuildContext context, LoadMoreCallback loadMoreAppointments) {
          return FutureBuilder<void>(
            future: loadMoreAppointments(),
            builder: (context, snapShot) {
              return Container(
                  height: _calendarController.view == CalendarView.schedule
                      ? 50
                      : double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.blue)));
            },
          );
        },
        monthViewSettings: MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            appointmentDisplayCount: 4),
        timeSlotViewSettings: TimeSlotViewSettings(
            minimumAppointmentDuration: const Duration(minutes: 60)));
  }
}

/// An object to set the appointment collection data source to collection, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class _MeetingDataSource extends CalendarDataSource {
  _MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  Future<void> handleLoadMore(DateTime startDate, DateTime endDate) async {
    await Future.delayed(Duration(seconds: 1));
    final List<Appointment> meetings = <Appointment>[];
    DateTime date = DateTime(startDate.year, startDate.month, startDate.day);
    final DateTime appEndDate =
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    while (date.isBefore(appEndDate)) {
      final List<Appointment>? data = _dataCollection[date];
      if (data == null) {
        date = date.add(Duration(days: 1));
        continue;
      }

      for (final Appointment meeting in data) {
        if (appointments!.contains(meeting)) {
          continue;
        }

        meetings.add(meeting);
      }
      date = date.add(Duration(days: 1));
    }

    appointments!.addAll(meetings);
    notifyListeners(CalendarDataSourceAction.add, meetings);
  }
}
