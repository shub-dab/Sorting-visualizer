import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sort Visualizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _currentSortAlgo = 'bubble';

  int dur = 999;
  List<int> _numbers = [];
  int _sampleSize = 250;
  int _maxvalue = 450;

  bool isSorted = false;
  bool isSorting = false;

  StreamController<List<int>> _streamController;
  Stream<List<int>> _stream;

  _reset() {
    isSorted = false;
    _numbers = [];
    for (int i = 0; i < _sampleSize; ++i) {
      _numbers.add(Random().nextInt(500));
    }
    _streamController.add(_numbers);
  }

  _setSortAlgo(String type) {
    setState(() {
      _currentSortAlgo = type;
    });
  }
  String _getTitle() {
    switch (_currentSortAlgo) {
      case "bubble":
        return "Bubble Sort";
        break;
      case "selection":
        return "Selection Sort";
        break;
      case "insertion":
        return "Insertion Sort";
        break;
      case "quick":
        return "Quick Sort";
        break;
      case "merge":
        return "Merge Sort";
    }
  }


  _randomize() {

    _numbers =[];

    for (var i = 0; i < _sampleSize; ++i) {
      _numbers.add(Random().nextInt(_maxvalue));
    }
    setState(() {isSorted = false;});
    _streamController.add(_numbers);
  }

  _sort() async {
    setState(() {
      isSorting = true;
    });

    switch (_currentSortAlgo) {
      case "bubble":
        await _bubbleSort();
        break;
      case "insertion":
        await _insertionSort();
        break;
      case "selection":
        await _selectionSort();
        break;
      case "quick":
        await _quickSort(0, _sampleSize.toInt() - 1);
        break;
      case "merge":
        await _mergeSort(0, _sampleSize.toInt() - 1);
        break;
    }

    setState(() {
      isSorted = true;
      isSorting = false;
    });
  }

  _bubbleSort() async {
    for(int i=0; i<_numbers.length-1; i++)
    {
      int flag = 0;
      for(int j=0; j<_numbers.length-1-i; j++)
      {
        if(_numbers[j] > _numbers[j+1]) // change to "<" for desc. order
            {
          int temp = _numbers[j];
          _numbers[j] = _numbers[j+1];
          _numbers[j+1] = temp;
          flag = 1;
        }
        await Future.delayed(Duration(microseconds: dur)); // to simulate delay
        // setState(() {});
        _streamController.add(_numbers);
      }
      // break if already sorted (optimization)
    }
  }

  _insertionSort() async {
    for (int i = 1; i < _numbers.length; i++) {
      int temp = _numbers[i];
      int j = i - 1;
      while (j >= 0 && temp < _numbers[j]) {
        _numbers[j + 1] = _numbers[j];
        --j;
        await Future.delayed(Duration(microseconds: dur));

        _streamController.add(_numbers);
      }
      _numbers[j + 1] = temp;
      await Future.delayed(Duration(microseconds: dur));

      _streamController.add(_numbers);
    }
  }

  _selectionSort() async {
    for (int i = 0; i < _numbers.length; i++) {
      for (int j = i + 1; j < _numbers.length; j++) {
        if (_numbers[i] > _numbers[j]) {
          int temp = _numbers[j];
          _numbers[j] = _numbers[i];
          _numbers[i] = temp;
        }

        await Future.delayed(Duration(microseconds: dur));

        _streamController.add(_numbers);
      }
    }
  }

  cf(int a, int b) {
    if (a < b) {
      return -1;
    } else if (a > b) {
      return 1;
    } else {
      return 0;
    }
  }

  _quickSort(int leftIndex, int rightIndex) async {
    Future<int> _partition(int left, int right) async {
      int p = (left + (right - left) / 2).toInt();

      var temp = _numbers[p];
      _numbers[p] = _numbers[right];
      _numbers[right] = temp;
      await Future.delayed(Duration(microseconds: dur));

      _streamController.add(_numbers);

      int cursor = left;

      for (int i = left; i < right; i++) {
        if (cf(_numbers[i], _numbers[right]) <= 0) {
          var temp = _numbers[i];
          _numbers[i] = _numbers[cursor];
          _numbers[cursor] = temp;
          cursor++;

          await Future.delayed(Duration(microseconds: dur));

          _streamController.add(_numbers);
        }
      }

      temp = _numbers[right];
      _numbers[right] = _numbers[cursor];
      _numbers[cursor] = temp;

      await Future.delayed(Duration(microseconds: dur));

      _streamController.add(_numbers);

      return cursor;
    }

    if (leftIndex < rightIndex) {
      int p = await _partition(leftIndex, rightIndex);

      await _quickSort(leftIndex, p - 1);

      await _quickSort(p + 1, rightIndex);
    }
  }

  _mergeSort(int leftIndex, int rightIndex) async {
    Future<void> merge(int leftIndex, int middleIndex, int rightIndex) async {
      int leftSize = middleIndex - leftIndex + 1;
      int rightSize = rightIndex - middleIndex;

      List leftList = new List(leftSize);
      List rightList = new List(rightSize);

      for (int i = 0; i < leftSize; i++) leftList[i] = _numbers[leftIndex + i];
      for (int j = 0; j < rightSize; j++) rightList[j] = _numbers[middleIndex + j + 1];

      int i = 0, j = 0;
      int k = leftIndex;

      while (i < leftSize && j < rightSize) {
        if (leftList[i] <= rightList[j]) {
          _numbers[k] = leftList[i];
          i++;
        } else {
          _numbers[k] = rightList[j];
          j++;
        }

        await Future.delayed(Duration(microseconds: dur));
        _streamController.add(_numbers);

        k++;
      }

      while (i < leftSize) {
        _numbers[k] = leftList[i];
        i++;
        k++;

        await Future.delayed(Duration(microseconds: dur));
        _streamController.add(_numbers);
      }

      while (j < rightSize) {
        _numbers[k] = rightList[j];
        j++;
        k++;

        await Future.delayed(Duration(microseconds: dur));
        _streamController.add(_numbers);
      }
    }

    if (leftIndex < rightIndex) {
      int middleIndex = (rightIndex + leftIndex) ~/ 2;

      await _mergeSort(leftIndex, middleIndex);
      await _mergeSort(middleIndex + 1, rightIndex);

      await Future.delayed(Duration(microseconds: dur));

      _streamController.add(_numbers);

      await merge(leftIndex, middleIndex, rightIndex);
    }
  }


  @override
  void initState() {
    super.initState();
    _streamController = StreamController<List<int>>();
    _stream = _streamController.stream;
    _randomize();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitle(),
          style: TextStyle(
            color: Colors.purple[50],
            letterSpacing: 2,
          ),
        ),
        elevation: 100,
        centerTitle: true,
        backgroundColor: Colors.purple[900],
        actions: <Widget>[

          PopupMenuButton<String>
            (icon: Icon(Icons.more_vert),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'bubble',
                  child: Text("Bubble Sort"),
                ),
                PopupMenuItem(
                  value: 'selection',
                  child: Text("Selection Sort"),
                ),
                PopupMenuItem(
                  value: 'insertion',
                  child: Text("Insertion Sort"),
                ),
                PopupMenuItem(
                  value: 'quick',
                  child: Text("Quick Sort"),
                ),
                PopupMenuItem(
                  value: 'merge',
                  child: Text("Merge Sort"),
                ),
              ],
            onSelected: (String value) {
              _reset();
              _setSortAlgo(value);
            }
          )
        ],
      ),
      body: Container(
        child: StreamBuilder<Object>(
            stream: _stream,
            builder: (context, snapshot) {

              int counter = 0;

              return Row(
                children: _numbers.map((int number) {
                  counter++;
                  return CustomPaint(
                    painter: BarPainter(
                      width: MediaQuery.of(context).size.width / _sampleSize,  // width of each bar
                      value: number,
                      index: counter,
                    ),
                  );
                }).toList(),
              );
            }
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      bottomNavigationBar: Row(
        children: <Widget>[
          Expanded(
            child: RaisedButton(
              color: Colors.purple[50],
              disabledColor: Colors.purple[100],
              child: Text('Randomize',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.purple[900],
                ),
              ),
              onPressed: isSorting ? null :_randomize,
            ),
          ),
          Expanded(
            child: RaisedButton(
              color: Colors.purple[50],
              disabledColor: Colors.purple[100],
              child: Text(
                'Sort',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.purple[900],
                ),
              ),
              disabledTextColor: Colors.grey,
              onPressed: (isSorting || isSorted) ? null : _sort,
            ),
          )
        ],
      ),
    );
  }
}

class BarPainter extends CustomPainter {

  final double width;
  final int value;
  final int index;

  BarPainter({this.width, this.value, this.index});

  @override
  void paint(Canvas canvas, Size size) {

    Paint paint = Paint();

    if (this.value < 500 * .10) {
      paint.color = Colors.purple[50];
    } else if (this.value < 500 * .20) {
      paint.color = Colors.purple[100];
    } else if (this.value < 500 * .30) {
      paint.color = Colors.purple[200];
    } else if (this.value < 500 * .40) {
      paint.color = Colors.purple[300];
    } else if (this.value < 500 * .50) {
      paint.color = Colors.purple[400];
    } else if (this.value < 500 * .60) {
      paint.color = Colors.purple[500];
    } else if (this.value < 500 * .70) {
      paint.color = Colors.purple[600];
    } else if (this.value < 500 * .80) {
      paint.color = Colors.purple[700];
    } else if (this.value < 500 * .90) {
      paint.color = Colors.purple[800];
    } else {
      paint.color = Colors.purple[900];
    }

    paint.strokeWidth = width;
    paint.strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(index*width, 0), Offset(index*width, value.ceilToDouble()), paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}
