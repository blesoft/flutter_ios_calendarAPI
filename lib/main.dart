import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:event_app/edit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

// final Map<DateTime, List> _holidays = {
//   DateTime(2020,1,1):['賀正'],
// };

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'カレンダー',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: EventList(),
    );
  }
}

class MemoListState extends State<EventList> with TickerProviderStateMixin{
  var _eventList = new List<String>();
  var _currentIndex = -1;
  bool _loading = true;
  final _biggerFont = const TextStyle(fontSize: 18.0);
  AnimationController _animationController;
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    this.loadEventList();
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  // void _onDaySelected(DateTime day, List events) {
  //   print('CALLBACK: _onDaySelected');
  //   setState(() {
  //     _selectedEvents = events;
  //   });
  // }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }


  @override
  Widget build(BuildContext context) {
    final title = "カレンダー";
    if (_loading) {
      return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Switch out 2 lines below to play with TableCalendar's settings
          //-----------------------
          _buildTableCalendar(),
          // _buildTableCalendarWithBuilders(),
          const SizedBox(height: 8.0),
          // _buildButtons(),
          const SizedBox(height: 8.0),
           Expanded(child: _buildList()),
        ],
      ),
      //_buildList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        tooltip: 'New Memo',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      // events: _eventList,
      // holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      // onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }


  void loadEventList() {
    SharedPreferences.getInstance().then((prefs) {
      const key = "event-list";
      if (prefs.containsKey(key)) {
        _eventList = prefs.getStringList(key);
      }
      setState(() {
        _loading = false;
      });
    });
  }

  void _addEvent() {
    setState(() {
      _eventList.add("");
      _currentIndex = 0;
      storeEventList();
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Edit(_eventList[_currentIndex], _onChanged);
        },
      ));
    });
  }

  void _onChanged(String text) {
    setState(() {
      _eventList[_currentIndex] = text;
      storeEventList();
    });
  }

  void storeEventList() async {
    final prefs = await SharedPreferences.getInstance();
    const key = "event-list";
    final success = await prefs.setStringList(key, _eventList);
    if (!success) {
      debugPrint("イベント追加に失敗しました");
    }
  }

  Widget _buildList() {
    final itemCount = _eventList.length == 0 ? 0 : _eventList.length * 2 - 1;
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: itemCount,
        itemBuilder: /*1*/ (context, i) {
          // return Container(
          //   color: Colors.grey,
          //   child:Text('_eventList'));
          if (i.isOdd) return Divider(
            height: 2,
            color: Colors.grey,
            thickness: 1,
            );
          final index = (i / 2).floor();
          final event = _eventList[index];
          return _buildWrappedRow(event, index);
        });
  }

  Widget _buildWrappedRow(String content, int index) {
    return Dismissible(
      background: Container(color: Colors.red),
      key: Key(content),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _eventList.removeAt(index);
          storeEventList();
        });
      },
      child: _buildRow(content, index),
    );
  }

  Widget _buildRow(String content, int index) {
    return ListTile(
      title: Text(
        content,
        style: _biggerFont,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      // onTap: () {
      //   _currentIndex = index;
      //   Navigator.of(context)
      //       .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      //     return new Edit(_eventList[_currentIndex], _onChanged);
      //   }));
      // },
    );
  }
}

class EventList extends StatefulWidget {
  @override
  MemoListState createState() => MemoListState();
}