import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strings/strings.dart';
import 'models.dart';

void main() => runApp(AcApp());

class AcApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animal Crossing App',
      theme: ThemeData(fontFamily: 'Humming'),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.teal[200],
          appBar: AppBar(
            title: Text('Animal Crossing App'),
            backgroundColor: Colors.teal[500],
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  text: 'Bugs',
                ),
                Tab(
                  text: 'Fish',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              StreamBuilder(
                stream: Firestore.instance.collection('bugs').snapshots(),
                builder: (context, bugSnapshot) {
                  if (!bugSnapshot.hasData) return LinearProgressIndicator();

                  return Scrollbar(
                      child: CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        flexibleSpace: _buildBugSearchBox(
                          context,
                          bugSnapshot.data.documents.toList(),
                        ),
                        backgroundColor: Colors.teal[500],
                        floating: false,
                        pinned: false,
                        snap: false,
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate(bugSnapshot
                            .data.documents
                            .map<Widget>((data) => _buildBugCard(context, data))
                            .toList()),
                      )
                    ],
                  ));
                },
              ),
              StreamBuilder(
                stream: Firestore.instance.collection('fish').snapshots(),
                builder: (context, fishSnapshot) {
                  if (!fishSnapshot.hasData) return LinearProgressIndicator();

                  return Scrollbar(
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverAppBar(
                          flexibleSpace: _buildFishSearchBox(
                            context,
                            fishSnapshot.data.documents.toList(),
                          ),
                          backgroundColor: Colors.teal[500],
                          floating: false,
                          pinned: false,
                          snap: false,
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate(fishSnapshot
                              .data.documents
                              .map<Widget>(
                                  (data) => _buildFishCard(context, data))
                              .toList()),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}


/*

Search Class and Functions

*/

class SearchResults extends StatelessWidget {
  String search;
  List<DocumentSnapshot> documentSnapshot;
  String bugOrFish;

  SearchResults(String search, List<DocumentSnapshot> documentSnapshot,
      String bugOrFish) {
    this.search = search;
    this.documentSnapshot = documentSnapshot;
    this.bugOrFish = bugOrFish;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        title: Text('Animal Crossing App'),
        backgroundColor: Colors.teal[500],
      ),
      body: Column(
        children: <Widget>[
          Text(
            'Search results for ' + this.search,
          ),
          Expanded(
            child: _buildSearchResultsList(
                context, this.documentSnapshot, this.bugOrFish),
          ),
        ],
      ),
    );
  }
}

/*

Create list of DocumentSnapshot that are the search results

*/
List<DocumentSnapshot> listSearchResults(
    List<DocumentSnapshot> data, String searchText, String bugOrFish) {
  List<DocumentSnapshot> results = [];

  if (bugOrFish == 'bug') {
    data.forEach((documentSnapshot) {
      Bug bug = Bug.fromSnapshot(documentSnapshot);
      if (bug.name.toLowerCase().contains(searchText))
        results.add(documentSnapshot);
    });
  } else {
    data.forEach((documentSnapshot) {
      Fish fish = Fish.fromSnapshot(documentSnapshot);
      if (fish.name.toLowerCase().contains(searchText))
        results.add(documentSnapshot);
    });
  }

  return results;
}

/*

Builds the widget for the screen of the search results

*/
Widget _buildSearchResultsList(
    BuildContext context, List<DocumentSnapshot> snapshot, String bugOrFish) {
  if (bugOrFish == 'bug') {
    return Scrollbar(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 20.0),
        children: snapshot.map((data) => _buildBugCard(context, data)).toList(),
      ),
    );
  } else {
    return Scrollbar(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 20.0),
        children:
            snapshot.map((data) => _buildFishCard(context, data)).toList(),
      ),
    );
  }
}

Widget _buildBugSearchBox(BuildContext context, List<DocumentSnapshot> data) {
  final textController = TextEditingController();

  return TextField(
    controller: textController,
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(40))
      ),
      hintText: 'Enter a bug name',
      contentPadding: EdgeInsets.all(15),
      fillColor: Colors.white,
      filled: true,
    ),
    onEditingComplete: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResults(textController.text,
              listSearchResults(data, textController.text, 'bug'), 'bug'),
        ),
      );
    },
  );
}

Widget _buildFishSearchBox(BuildContext context, List<DocumentSnapshot> data) {
  final textController = TextEditingController();

  return TextField(
    controller: textController,
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(40))
      ),
      hintText: 'Enter a fish name',
      contentPadding: EdgeInsets.all(15),
      fillColor: Colors.white,
      filled: true,
    ),
    onEditingComplete: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResults(textController.text,
              listSearchResults(data, textController.text, 'fish'), 'fish'),
        ),
      );
    },
  );
}


/*

Bug Widgets

*/

Widget _buildBugCard(BuildContext context, DocumentSnapshot data) {
  final bug = Bug.fromSnapshot(data);

  return Padding(
    key: ValueKey(bug.name),
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
        color: Color(0xFFFFF3CA),
      ),
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(top: 10),
              child: Image.asset(
                  'images/bugs/NH-Icon-' + data.documentID + '.png')),
          Container(
            padding: EdgeInsets.only(top: 10),
            child: _buildName(bug.name),
          ),
          Container(
            padding: EdgeInsets.only(top: 15, bottom: 27),
            child: _buildBugCardText(bug.price, bug.month, bug.time),
          ),
        ],
      ),
    ),
  );
}

Widget _buildBugCardText(int price, String month, String time) {
  return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
            child: Column(children: [
          Container(
            padding: EdgeInsets.only(bottom: 5),
            child: Text(
              'Price',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          _buildPrice(price),
        ])),
        Expanded(
            child: Column(children: [
          Container(
            padding: EdgeInsets.only(bottom: 5),
            child: Text(
              'Months',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          _buildMonth(month),
        ])),
        Expanded(
            child: Column(children: [
          Container(
            padding: EdgeInsets.only(bottom: 5),
            child: Text(
              'Time',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          _buildTime(time),
        ])),
      ],
    ),
  );
}

Widget _buildName(String name) {
  return Text(
    name,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    textAlign: TextAlign.center,
  );
}

Widget _buildPrice(int price) {
  return Container(
    child: Text(price.toString()),
  );
}

Widget _buildMonth(String month) {
  if (month.isEmpty) return Container(child: Text('All Year'));

  month = month
      .replaceAll('10', 'Oct')
      .replaceAll('11', 'Nov')
      .replaceAll('12', 'Dec')
      .replaceAll('1', 'Jan')
      .replaceAll('2', 'Feb')
      .replaceAll('3', 'Mar')
      .replaceAll('4', 'Apr')
      .replaceAll('5', 'May')
      .replaceAll('6', 'Jun')
      .replaceAll('7', 'Jul')
      .replaceAll('8', 'Aug')
      .replaceAll('9', 'Sep')
      .replaceAll(',', ', ');

  return Container(child: Text(month));
}

Widget _buildTime(String time) {
  List<String> finalTimeList = new List<String>();

  if (time.isEmpty) return Container(child: Text('All Day'));

  List<String> timeList = time.split(',');

  for (String timeListPart in timeList) {
    // halfTimeList stores the newly formatted time (PST) for each time range
    List<String> halfTimeList = new List<String>();
    List<String> hours = timeListPart.split('-');

    for (String hour in hours) {
      int hourInt = int.parse(hour);
      // change from military time
      int regularHour = hourInt - 12;

      if (regularHour > 0) {
        String newHour = regularHour.toString() + ' PM';
        halfTimeList.add(newHour);
      } else {
        String newHour = hourInt.toString() + ' AM';
        halfTimeList.add(newHour);
      }
    }

    finalTimeList.add(halfTimeList.join(' - '));
  }

  String finalTime = finalTimeList.join(', ');

  return Container(child: Text(finalTime));
}


/*

Fish Widgets

*/

Widget _buildFishCard(BuildContext context, DocumentSnapshot data) {
  final fish = Fish.fromSnapshot(data);

  return Padding(
    key: ValueKey(fish.name),
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
        color: Color(0xFFFFF3CA),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(5),
          },
          children: [
            TableRow(
              children: [
                Column(
                  children: [
                    Container(
                      child: Image.asset(
                          'images/fish/NH-Icon-' + data.documentID + '.png'),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 15),
                      child: _buildName(fish.name),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: _buildFishCardText(fish.price, fish.month, fish.time,
                      fish.location, fish.shadow),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFishCardText(
    int price, String month, String time, String location, int shadow) {
  return Container(
    child: Table(
      children: [
        TableRow(
          children: [
            Text('Price: '),
            _buildPrice(price),
          ],
        ),
        TableRow(
          children: [
            Text('Months: '),
            _buildMonth(month),
          ],
        ),
        TableRow(
          children: [
            Text('Time: '),
            _buildTime(time),
          ],
        ),
        TableRow(
          children: [
            Text('Location: '),
            _buildLocation(location),
          ],
        ),
        TableRow(
          children: [
            Text('Shadow: '),
            _buildShadow(shadow),
          ],
        ),
      ],
    ),
  );
}

Widget _buildLocation(String location) {
  return Text(
    capitalize(location),
  );
}

Widget _buildShadow(int shadow) {
  return Container(
    child: Text(shadow.toString()),
  );
}
