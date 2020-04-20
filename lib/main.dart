import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:event_app/edit.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';


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
      // home: EventList(),
      home: CalendarExample(title: 'カレンダー')
    );
  }
}

class CalendarExample extends StatefulWidget {
  CalendarExample({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState(){
    return _CalendarState();
  }
}

///////////初期設定///////////
class _CalendarState extends State<CalendarExample> with TickerProviderStateMixin{
  var _eventList = new List<String>();
  var _currentIndex;
  bool _loading = true;
  final _biggerFont = const TextStyle(fontSize: 18.0);
  AnimationController _animationController;
  CalendarController _calendarController;
  DateTime _currentDate = DateTime.now();
  EventList<Event> _markedDateMap = EventList<Event>();

  @override
  void initState() {
    super.initState();
    this.loadEventList();
    _currentIndex = -1;
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
            _buildCalendar(),
            const SizedBox(height: 8.0),
            const SizedBox(height: 8.0),
            Expanded(child: _buildList()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:_onButtonPresseed ,
          tooltip: 'New Memo',
          child: Icon(Icons.add),
        ),
    );
  }


///////////カレンダー設定///////////
  Widget _buildCalendar() {
    return Container(
        child: CalendarCarousel<Event>(
          onDayPressed: onDayPressed,
          weekendTextStyle: TextStyle(color: Colors.red),
          thisMonthDayBorderColor: Colors.grey,
          weekFormat: false,
          height: 460.0,
          selectedDateTime: _currentDate,
          daysHaveCircularBorder: false,
          customGridViewPhysics: NeverScrollableScrollPhysics(),
          markedDatesMap: _markedDateMap,  // 追加
          markedDateShowIcon: true,
          markedDateIconMaxShown: 2,
          todayTextStyle: TextStyle(
            color: Colors.blue,
          ),
          markedDateIconBuilder: (event) {
            return event.icon;
          },
          todayBorderColor: Colors.green[30],
          markedDateMoreShowTotal: false),
    );
  }

  void onDayPressed(DateTime date, List<Event> events) {
    this.setState(() => _currentDate = DateTime.now());
    _currentIndex ++;
    addEvent(date);
    addMemo(date);
  }

  void _onButtonPresseed(){
    this.setState(() => _currentDate = DateTime.now());
    _currentIndex ++;
    addEvent(_currentDate);
    addMemo(_currentDate);
  }

  void addEvent(DateTime date){
    _markedDateMap.add(date, createEvent(date));
  }

  Event createEvent(DateTime date){
    return Event(
      date: date,
      title: date.day.toString(),
      icon: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue, width: 5),
        ),
        child: Icon(
          Icons.calendar_today,
          color: Colors.blue,
        ),
        // width: 10,
        // height: 10,
      )
    );
  }

////////////メモ帳設定////////////////

  void loadEventList(){
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

  void addMemo(DateTime date){
    setState(() {
      _eventList.add("");
      // _currentIndex = 0;
      storeEventList();
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context){
          return new Edit2(_eventList[_currentIndex], _onChanged, date);
        }
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
          _currentIndex --;
        });
      },
      child: _buildRow(content, index),
    );
  }

  Widget _buildRow(String content, int index) {
    return ListTile(
      title: Text(
        index.toString() + ":" + content,
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
