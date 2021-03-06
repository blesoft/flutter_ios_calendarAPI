import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Edit2 extends StatelessWidget {
  String _current;
  Function _onChanged;
  DateTime _date;

  Edit2(this._current, this._onChanged, this._date);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_date.toString() + "イベント追加/編集"),
        actions: <Widget>[
          FlatButton(
            onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Icon(Icons.check),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
        leading: FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_back_ios),
          shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        ),
      ),
      body: new Container(
          padding: const EdgeInsets.all(16.0),
          child: new TextField(
            controller: TextEditingController(text: _current),
            maxLines: 99,
            style: new TextStyle(color: Colors.black),
            onChanged: (text) {
              _current = text;
              _onChanged(_current);
            },
          )),
    );
  }
}

class Edit3 extends StatelessWidget {
  String _current;
  Function _onChanged;
  DateTime _date;
  Map<DateTime,List> _map;

  Edit3(this._current, this._onChanged, this._date ,this._map);
  @override
  Widget build(BuildContext context) {
    Map<DateTime,List> _newMap = {_date : [_current]};
    _map.addAll(_newMap);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_date.toString() + "イベント追加/編集"),
        actions: <Widget>[
          FlatButton(
            onPressed: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Icon(Icons.check),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
        leading: FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_back_ios),
          shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        ),
      ),
      body: new Container(
          padding: const EdgeInsets.all(16.0),
          child: new TextField(
            controller: TextEditingController(text: _current),
            maxLines: 99,
            style: new TextStyle(color: Colors.black),
            onChanged: (text) {
              _current = text;
              _onChanged(_current);
            },
          )),
    );
  }
}