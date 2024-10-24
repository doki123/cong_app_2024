import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map billAndTime =
      {}; // this logs when getBills was triggered and what the date selected was
  TextEditingController dateController = TextEditingController();
  TextEditingController rangeController = TextEditingController();
  String formattedDate = "";
  String formattedEndDate = "";
  List commonPolicyAreas = [];
  Map<String, double> chartData = {}; // for the Pie Chart; pie chart . dart
  Map<String, double> partyData = {};
  bool chartExists = false;
  int durationDays = 31;

  // List<PieData> pies = []; // for Pie Chart; easy_pie_chart.dart

  List<Map> returnedBills = [];
  bool _loading = false;
  final TextEditingController policyController = TextEditingController();
  // policyDrop?
  //     selectedDropPolicy; // not used? i think? CTRL F doesnt show anything
  String dropdownvalue =
      "none"; // set as none initially to disable Find Bills button
  int offset =
      0; // meant to help with pagination; click next button and (offset += 20) should happen
  int buttonCounter = 0; // counts how many times Find Bills has been pressed
  bool dateSame =
      false; // checks whether the date selected now is the same as the selected date last time
  bool nextButton = false;

  String api_key = "g51ZVJeu9Te5r14aSLpG86n1BatzwIsnU8CfcVWv";
  List<Color> colorsChart = [
    Colors.lime[400]!,
    Colors.lime[900]!,
    Colors.green[400]!,
    Colors.green[900]!,
    Colors.teal[400]!,
    Colors.teal[900]!,
    Colors.green[400]!,
    Colors.green[900]!,
    Colors.cyan[400]!,
    Colors.cyan[900]!,
    Colors.blue[400]!,
    Colors.blue[900]!,
    Colors.indigo[400]!,
    Colors.indigo[900]!,
    Colors.pink[400]!,
    Colors.pink[900]!,
    Colors.deepOrange[400]!,
    Colors.deepOrange[900]!,
    Colors.amber[400]!,
    Colors.amber[900]!,
  ];

  Map allPolicyCategories = {
    'Agriculture and Food':
        'Primary focus of measure is agricultural practices; agricultural prices and marketing; agricultural education; food assistance or nutrition programs; food industry, supply, and safety; aquaculture; horticulture and plants. Measures concerning international trade in agricultural products may fall under Foreign Trade and International Finance policy area.',
    'Animals':
        'Primary focus of measure is animal protection; human-animal relationships; wildlife conservation and habitat protection; veterinary medicine. Measures concerning endangered or threatened species may fall under Environmental Protection policy area. Measures concerning wildlife refuge matters may fall under Public Lands and Natural Resources policy area.',
    'Armed Forces and National Security':
        'Primary focus of measure is military operations and spending, facilities, procurement and weapons, personnel, intelligence; strategic materials; war and emergency powers; veterans’ issues. Measures concerning alliances and collective security, arms sales and military assistance, or arms control may fall under International Affairs policy area.',
    'Arts, Culture, Religion':
        "Primary focus of measure is art, literature, performing arts in all formats; arts and humanities funding; libraries, exhibitions, cultural centers; sound recording, motion pictures, television and film; cultural property and resources; cultural relations; and religion. Measures concerning intellectual property aspects of the arts may fall under Commerce policy area. Measures concerning religious freedom may fall under Civil Rights and Liberties, Minority Issues policy area.",
    'Civil Rights and Liberties, Minority Issues':
        "Primary focus of measure is discrimination on basis of race, ethnicity, age, sex, gender, health or disability; First Amendment rights; due process and equal protection; abortion rights; privacy. Measures concerning abortion rights and procedures may fall under Health policy area.",
    'Commexrce':
        "Primary focus of measure is business investment, development, regulation; small business; consumer affairs; competition and restrictive trade practices; manufacturing, distribution, retail; marketing; intellectual property. Measures concerning international competitiveness and restrictions on imports and exports may fall under Foreign Trade and International Finance policy area.",
    'Congress':
        "Primary focus of measure is Members of Congress; general congressional oversight; congressional agencies, committees, operations; legislative procedures; U.S. Capitol. Measures concerning oversight and investigation of specific matters may fall under the issue-specific relevant policy area.",
    'Crime and Law Enforcement':
        "Primary focus of measure is criminal offenses, investigation and prosecution, procedure and sentencing; corrections and imprisonment; juvenile crime; law enforcement administration; controlled substances regulation. Measures concerning terrorism may fall under Emergency Management or International Affairs policy areas.",
    'Economics and Public Finance':
        "Primary focus of measure is budgetary matters such as appropriations, public debt, the budget process, government lending, government accounts and trust funds; monetary policy and inflation; economic development, performance, and economic theory.",
    "Education":
        "Primary focus of measure is elementary, secondary, or higher education including special education and matters of academic performance, school administration, teaching, educational costs, and student aid. Measures concerning college sports (including NCAA) may fall under Sports and Recreation policy area.",
    "Emergency Management":
        "Primary focus of measure is emergency planning; response to civil disturbances, natural and other disasters, including fires; emergency communications; security preparedness.",
    "Energy":
        "Primary focus of measure is all sources and supplies of energy, including alternative energy sources, oil and gas, coal, nuclear power; efficiency and conservation; costs, prices, and revenues; electric power transmission; public utility matters.",
    "Environmental Protection":
        "Primary focus of measure is regulation of pollution including from hazardous substances and radioactive releases; climate change and greenhouse gases; environmental assessment and research; solid waste and recycling; ecology. Measures concerning energy exploration, efficiency, and conservation may fall under Energy policy area.",
    "Families":
        "Primary focus of measure is child and family welfare, services, and relationships; marriage and family status; domestic violence and child abuse. Measures concerning public assistance programs or aging may fall under Social Welfare policy area.",
    "Finance and Financial Sector":
        "Primary focus of measure is U.S. banking and financial institutions regulation; consumer credit; bankruptcy and debt collection; financial services and investments; insurance; securities; real estate transactions; currency. Measures concerning financial crimes may fall under Crime and Law Enforcement. Measures concerning business and corporate finance may fall under Commerce policy area. Measures concerning international banking may fall under Foreign Trade and International Finance policy area.",
    "Foreign Trade and International Finance":
        "Primary focus of measure is competitiveness, trade barriers and adjustment assistance; foreign loans and international monetary system; international banking; trade agreements and negotiations; customs enforcement, tariffs, and trade restrictions; foreign investment. Measures concerning border enforcement may fall under Immigration policy area.",
    "Government Operations and Politics":
        "Primary focus of measure is government administration, including agency organization, contracting, facilities and property, information management and services; rulemaking and administrative law; elections and political activities; government employees and officials; Presidents; ethics and public participation; postal service. Measures concerning agency appropriations and the budget process may fall under Economics and Public Finance policy area.",
    "Health":
        "Primary focus of measure is science or practice of the diagnosis, treatment, and prevention of disease; health services administration and funding, including such programs as Medicare and Medicaid; health personnel and medical education; drug use, safety, treatment, and research; health care coverage and insurance; health facilities. Measures concerning controlled substances and drug trafficking may fall under Crime and Law Enforcement policy area.",
    "Housing and Community Development":
        "Primary focus of measure is home ownership; housing programs administration and funding; residential rehabilitation; regional planning, rural and urban development; affordable housing; homelessness; housing industry and construction; fair housing. Measures concerning mortgages and mortgage finance may fall under Finance and Financial Sector policy area.",
    "Immigration":
        "Primary focus of measure is administration of immigration and naturalization matters; immigration enforcement procedures; customs and border protection; refugees and asylum policies; travel and residence documentation for non-U.S. nationals, such as visas; foreign labor; benefits for immigrants. Measures concerning smuggling and trafficking of persons and controlled substances may fall under Crime and Law Enforcement policy area. Measures concerning refugees may fall under International Affairs policy area.",
    "International Affairs":
        "Primary focus of measure is matters affecting foreign aid, human rights, international law and organizations; national governance; passports for U.S. nationals; arms control; diplomacy and foreign officials; alliances and collective security. Measures concerning trade agreements, tariffs, foreign investments, and foreign loans may fall under Foreign Trade and International Finance policy area.",
    "Labor and Employment":
        "Primary focus of measure is matters affecting hiring and composition of the workforce, wages and benefits, labor-management relations; occupational safety, personnel management, unemployment compensation, pensions. Measures concerning public-sector employment may fall under Government Operations and Politics policy area.",
    "Law":
        "Primary focus of measure is matters affecting civil actions and administrative remedies, courts and judicial administration, general constitutional issues, dispute resolution, including mediation and arbitration. Measures concerning specific constitutional amendments may fall under the policy area relevant to the subject matter of the amendment (e.g., Education). Measures concerning criminal procedure and law enforcement may fall under Crime and Law Enforcement policy area.",
    "Native Americans":
        "Primary focus of measure is matters affecting Native Americans, including Alaska Natives and Hawaiians, in a variety of domestic policy settings. This includes claims, intergovernmental relations, and Indian lands and resources.",
    "Public Lands and Natural Resources":
        "Primary focus of measure is natural areas (including wilderness); lands under government jurisdiction; land use practices and policies; parks, monuments, and historic sites; fisheries and marine resources; mining and minerals; emergency wildfire mitigation and disaster relief on federal lands. Measures concerning energy supplies and production may fall under Energy policy area.",
    "Science, Technology, Communications":
        "Primary focus of measure is natural sciences, space exploration, research policy and funding, research and development, STEM education, scientific cooperation and communication; technology policies, telecommunication, information technology; digital media, journalism. Measures concerning scientific education may fall under Education policy area.",
    "Social Sciences and History":
        "Primary focus of measure is policy sciences, history, matters related to the study of society. Measures concerning particular aspects of government functions may fall under Government Operations and Politics policy area.",
    "Social Welfare":
        "Primary focus of measure is public assistance and Social Security programs; social services matters, including community service, volunteer, and charitable activities. Measures concerning such health programs as Medicare and Medicaid may fall under Health policy area.",
    "Sports and Recreation":
        "Primary focus of measure is youth, amateur, college (including NCAA) and professional athletics; outdoor recreation; sports and recreation facilities. Measures concerning recreation areas may fall under Public Lands and Natural Resources policy area.",
    "Taxation":
        "Primary focus of measure is all aspects of income, excise, property, inheritance, and employment taxes; tax administration and collection. Measures concerning state and local finance may fall under Economics and Public Finance policy area.",
    "Transportation and Public Works":
        "Primary focus of measure is all aspects of transportation modes and conveyances, including funding and safety matters; Coast Guard; infrastructure development; travel and tourism. Measures concerning water resources and navigation projects may fall under Water Resources Development policy area.",
    "Water Resources Development":
        "Primary focus of measure is the supply and use of water and control of water flows; watersheds; floods and storm protection; wetlands. Measures concerning water quality may fall under Environmental Protection policy area."
  };

  Map policyBillsSorted = {
    'Agriculture and Food': [],
    'Animals': [],
    'Armed Forces and National Security': [],
    'Arts, Culture, Religion': [],
    'Civil Rights and Liberties, Minority Issues': [],
    'Commerce': [],
    'Congress': [],
    'Crime and Law Enforcement': [],
    'Economics and Public Finance': [],
    "Education": [],
    "Emergency Management": [],
    "Energy": [],
    "Environmental Protection": [],
    "Families": [],
    "Finance and Financial Sector": [],
    "Foreign Trade and International Finance": [],
    "Government Operations and Politics": [],
    "Health": [],
    "Housing and Community Development": [],
    "Immigration": [],
    "International Affairs": [],
    "Labor and Employment": [],
    "Law": [],
    "Native Americans": [],
    "Public Lands and Natural Resources": [],
    "Science, Technology, Communications": [],
    "Social Sciences and History": [],
    "Social Welfare": [],
    "Sports and Recreation": [],
    "Taxation": [],
    "Transportation and Public Works": [],
    "Water Resources Development": [],
    // "Non-Bill": []
  };

  List policyKeysList = [];
  List<DropdownMenuItem>? dropdownPolicyList = [];

  @override
  initState() {
    super.initState();
    connectToServer();
  }

  chartGenerator(policyAreasFound) {
    chartData = {};

    policyAreasFound.forEach((x) =>
        chartData[x] = !chartData.containsKey(x) ? (1) : (chartData[x]! + 1.0));

    chartExists = true;
    print(chartData);

    var sortedByValueMap = Map.fromEntries(chartData.entries.toList()
      ..sort((e1, e2) => e1.value.compareTo(e2.value)));

    print(sortedByValueMap);

    chartData = sortedByValueMap;

    return chartData;
  }

  connectToServer() async {
    policyKeysList = policyBillsSorted.keys.toList();
    dropdownPolicyList?.add(const DropdownMenuItem(
        value: "none", child: Text("Select a Policy Area")));

    for (int i = 0; i < policyKeysList.length; i++) {
      DropdownMenuItem tempVal = DropdownMenuItem(
          value: policyKeysList[i], child: Text(policyKeysList[i]));
      dropdownPolicyList?.add(tempVal);
    }
  }

  getBills(String formattedDate, String formattedEndDate, int offset) async {
    _loading = true;
    List<Map> billCollection = [];
    commonPolicyAreas = [];
    chartData = {};

    if (nextButton == false) {
      // if you DO click next button, then it should be appeneded to returnedBills
      returnedBills = [];
      policyBillsSorted = {
        'Agriculture and Food': [],
        'Animals': [],
        'Armed Forces and National Security': [],
        'Arts, Culture, Religion': [],
        'Civil Rights and Liberties, Minority Issues': [],
        'Commerce': [],
        'Congress': [],
        'Crime and Law Enforcement': [],
        'Economics and Public Finance': [],
        "Education": [],
        "Emergency Management": [],
        "Energy": [],
        "Environmental Protection": [],
        "Families": [],
        "Finance and Financial Sector": [],
        "Foreign Trade and International Finance": [],
        "Government Operations and Politics": [],
        "Health": [],
        "Housing and Community Development": [],
        "Immigration": [],
        "International Affairs": [],
        "Labor and Employment": [],
        "Law": [],
        "Native Americans": [],
        "Public Lands and Natural Resources": [],
        "Science, Technology, Communications": [],
        "Social Sciences and History": [],
        "Social Welfare": [],
        "Sports and Recreation": [],
        "Taxation": [],
        "Transportation and Public Works": [],
        "Water Resources Development": [],
        // "Non-Bill": []
      };
    }

    var bills = await http.get(Uri.parse(
        'https://api.congress.gov/v3/bill?api_key=$api_key&limit=20&format=json&fromDateTime=$formattedDate'
        'T00:00:00Z&toDateTime=$formattedEndDate'
        'T00:00:00Z&offset=$offset'));
    print(
        'https://api.congress.gov/v3/bill?api_key=$api_key&limit=20&format=json&fromDateTime=$formattedDate'
        'T00:00:00Z&toDateTime=$formattedEndDate'
        'T00:00:00Z&offset=$offset');
    print('BILLS BEING RECIEVED');
    var billsDecoded = json.decode(bills.body);
    int pageCount = billsDecoded['pagination']['count'];
    print('THESE MANY BILLS $pageCount');

    if (billsDecoded['bills'] == null) {
      print('NO BILLS FOUND');
      return false;
    }
    print(billsDecoded['bills'].length);
    _loading = true;
    for (int i = 0; i < billsDecoded['bills'].length; i++) {
      String title;
      List summaryList = [];
      List sponsorList = [];
      String policyArea;

      String billUrl =
          billsDecoded['bills'][i]['url']; // GETS URL OF INDIVIDUAL BILL
      var whatever = billUrl.indexOf("?format");
      billUrl =
          "${billUrl.substring(0, whatever)}?api_key=$api_key&format=json";
      // print(billUrl);

      var billIndiv = await http.get(Uri.parse(billUrl));
      var billInDec = jsonDecode(billIndiv
          .body); // THIS IS THE INFORMATION INSIDE THE LINK FOR AN INDIVIDUAL BILL
      // print(billUrl); // LINK TO BILL THAT INCLUDES THE API KEY; IF YOU WANT TO DISPLAY LINK TO BILL'S TEXT ON APP, DON'T USE THIS LINK

      title = billsDecoded['bills'][i]['title']; // TITLE OF BILL

      // FIND READABLE BILL URL
      print('trying to find url of text of bill');
      String billTextUrl =
          billsDecoded['bills'][i]['url']; // GETS URL OF INDIVIDUAL BILL
      billTextUrl =
          "${billTextUrl.substring(0, whatever)}/text?api_key=$api_key&format=json";
      var billTextIndiv = await http.get(Uri.parse(billTextUrl));
      var billTextInDec = jsonDecode(billTextIndiv.body);
      String textPlease = "No URL Found";
      try {
        textPlease = billTextInDec['textVersions'][0]['formats'][0]['url'];
        // ignore: empty_catches
      } catch (e) {}

      // end of bit
      try {
      if (billInDec['bill']['policyArea'] == null) {
        policyArea = 'Non-Bill';
      } else {
        policyArea = billInDec['bill']['policyArea']['name'];

        // SUMMARIES SECTION
        if (billInDec['bill']['summaries'] == null) {
          // print('This Bill Does Not Appear to Have Summary');
          summaryList = ['Summary unavailable'];
        } else {
          var summaryLink = billInDec['bill']['summaries'][
              'url']; // inside the indiviual bill's info, there is a link that takes you to its summary
          var formatThis = summaryLink.indexOf("?format");
          summaryLink = summaryLink.substring(0, formatThis) +
              "?api_key=" +
              api_key +
              "&format=json";
          var billTextEnc = await http
              .get(Uri.parse(summaryLink)); // GETS INFO INSIDE OF SUMMARY LINK
          var billTextDec = jsonDecode(billTextEnc.body);

          for (int x = 0; x < billTextDec['summaries'].length; x++) {
            summaryList.add(billTextDec['summaries'][x]['text']);
          }
          // print(summaryList);
        }
        // SPONSORS INFORMATION SECTION
        for (int x = 0; x < billInDec['bill']['sponsors'].length; x++) {
          sponsorList.add([
            billInDec['bill']['sponsors'][x]['party'],
            billInDec['bill']['sponsors'][x]['state'],
            // billInDec['bill']['sponsors'][x]['fullName'],
            billInDec['bill']['sponsors'][x]['firstName'] +
                " " +
                billInDec['bill']['sponsors'][x]['lastName']
          ]);
        }

        // ADD BILL TO LARGE REPERTOIRE
        billCollection.add({
          'title': title,
          'summaries': summaryList,
          'sponsors': sponsorList,
          'policy_area': policyArea,
          'url': textPlease
        });

        // ADD BILL TO SPECIFIC POLICY AREA LIST
        List polTem = policyBillsSorted[policyArea];

        polTem.add({
          'title': title,
          'summaries': summaryList,
          'sponsors': sponsorList,
          'policy_area': policyArea,
          'url': textPlease,
        });

        policyBillsSorted[policyArea] = polTem;
      }
            commonPolicyAreas.add(policyArea);

      }
      catch(e) {
        print(e);
      }

      // commonPolicyAreas.add(policyArea);
    }

    _loading = false;

    print('END GETBILLS FUNCTION');
    commonPolicyAreas.removeWhere((element) => element == "Non-Bill");

    // print(policyBillsSorted);
    setState(() {});

    return [billCollection, commonPolicyAreas];
  }

  polFilter(String selectedPolicy) {
    // print(policyBillsSorted[selectedPolicy]);

    List polParties = [];
    Map<String, double> polMap = {};
    for (int x = 0; x < policyBillsSorted[selectedPolicy].length; x++) {
      // print(policyBillsSorted[selectedPolicy][x]['sponsors']);
      for (int y = 0;
          y < policyBillsSorted[selectedPolicy][x]['sponsors'].length;
          y++) {
        // print(policyBillsSorted[selectedPolicy][x]['sponsors'][y][0]);
        polParties.add(policyBillsSorted[selectedPolicy][x]['sponsors'][y][0]);
      }
    }

    polParties.forEach(
        (x) => polMap[x] = !polMap.containsKey(x) ? (1) : (polMap[x]! + 1.0));

    if (polMap.isNotEmpty) {
      if (polMap.containsKey('D') == false) {
        polMap.addAll({'D': 0.0});
      }
    }

    var sortedByKeyMap = Map.fromEntries(
        polMap.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
    return sortedByKeyMap;
  }

  filterPolicy(String selectedPolicy) {
    if (policyBillsSorted[selectedPolicy] != []) {
      _loading = false;
    }

    partyData = polFilter(selectedPolicy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 244, 255, 246),
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Container(
              // color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 8.0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.green)),

              child: Text(
                "Bills Passed from $formattedDate to $formattedEndDate",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: (chartExists == false || chartData.isEmpty || chartData == null)
                  ? const Center(
                      child: Text(
                      "No bills found yet!",
                      style: TextStyle(fontSize: 16),
                    ))
                  :
                  // THIS IS USING THE PIE_CHART.dart VERSION OF PIE CHART
                  PieChart(
                      dataMap: chartData,
                      legendOptions: const LegendOptions(
                          legendPosition: LegendPosition.top,
                          legendTextStyle: TextStyle(fontSize: 16)),
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValuesInPercentage: true,
                      ),
                      colorList: colorsChart,
                    ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.green)),
              child: const Center(
                  child: Text(
                "Parties that Propose Bills:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green),
              )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: (partyData.isEmpty == true)
                  ? const Center(
                      child: Text(
                      "Select an existing policy area first!",
                      style: TextStyle(fontSize: 16),
                    ))
                  : PieChart(
                      dataMap: partyData,
                      colorList: [Colors.blue.shade300, Colors.red.shade300],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                color: dropdownvalue == "none" ? Color.fromARGB(255, 144, 181, 162) : Colors.green[50],
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton(
                  // Initial Value
                  // value: dropdownvalue,
            
                  value: dropdownvalue,
                  // dropdownColor: dropdownvalue == "none" ? Colors.grey : Colors.deepPurple[50],
            
                  // Down Arrow Icon
                  icon: const Icon(Icons.keyboard_arrow_down),
                  // isExpanded: true,
            
                  // Array list of items
                  items: dropdownPolicyList,
                  // After selecting the desired option,it will
                  // change button value to selected value
                  onChanged: (newValue) {
                    dropdownvalue = newValue!;
                    // if (returnedBills != []) {
                    partyData = polFilter(dropdownvalue);
                    print(partyData);
                    // }
                    setState(() {});
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
              child: TextField(
                textAlign: TextAlign.center,
                controller: rangeController,
                decoration: const InputDecoration(
                    hintText: 'Select a date range. Ex: 7 days'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  print("THIS IS DROPDOWN VALUE: $value");
                  if (value != "") {
                                      durationDays = int.parse(value);

                  }
                  // durationDays = int.parse(value);
                  setState(() {});
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
            
                  controller:
                      dateController, //editing controller of this TextField
                  decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today), //icon of text field
                      labelText: "Enter Date" //label text of field
                    
                      ),
                  readOnly: true, // when true user cannot edit text
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(), //get today's date
                        firstDate: DateTime(
                            2020), //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime.now());
                    if (pickedDate != null) {
                      formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                      DateTime endDate = pickedDate.add(Duration(
                          days: durationDays)); // YO. I CHANGED IT TO 7 DAYS.
                      formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
            
                      setState(() {
                        dateController.text =
                            formattedDate; //set foratted date to TextField value.
                      });
                    } else {
                      print("Date is not selected");
                    }
                    //when click we have to show the datepicker
                  }),
            ),
            ElevatedButton(
              onPressed: dropdownvalue == "none"
                  ? null
                  : () async {
                      print(formattedDate);
                      buttonCounter++;
                      billAndTime[buttonCounter] = formattedDate;
                      print(
                          '${billAndTime[buttonCounter]} ${billAndTime[buttonCounter - 1]}');
                      print(formattedEndDate);
                      if (billAndTime[buttonCounter] ==
                          billAndTime[buttonCounter - 1]) {
                        const Text('Choose a new date range!');
                        dateSame = true;
                      } else {
                        dateSame = false;
                        offset = 0;
                        var checkResult = await getBills(
                            formattedDate, formattedEndDate, offset);
                        print('HELLO');
                        if (checkResult == false) {
                          print("Oops! no bills");
                        } else {
                          returnedBills = checkResult[0];
                          chartGenerator(checkResult[1]);
                          print(
                              "this isreturned bill length ${returnedBills.length}");

                          setState(() {});
                        }
                        filterPolicy(dropdownvalue);
                        // politicalDivide(dropdownvalue);
                      }
                    },
              child: const Text("Find Bills"),
            ),
            (policyBillsSorted[dropdownvalue] == null) || _loading == true
                // || _billsExist == false
                ? const LinearProgressIndicator()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    // itemExtent: 20.0,
                    padding: const EdgeInsets.all(8),
                    itemCount: policyBillsSorted[dropdownvalue].length,
                    // itemCount: 2,
                    itemBuilder: (BuildContext context, int index) {
                      return ExpansionTile(
                        title: Text(
                          policyBillsSorted[dropdownvalue][index]['title'],
                          textAlign: TextAlign.center,
                          selectionColor: Colors.green[500],
                        ),
                        children: <Widget>[
                          // Text(policyBillsSorted[dropdownvalue][index]
                          //         ['summaries']
                          //     .toString()),
                          // Text(policyBillsSorted[dropdownvalue][index]
                          //         ['sponsors']
                          //     .toString()),
                          GestureDetector(
                            child: Text(
                              "URL of Bill: ${policyBillsSorted[dropdownvalue][index]['url']}",
                              textAlign: TextAlign.center,
                            ),
                            onTap: () async {
                              if (policyBillsSorted[dropdownvalue][index]
                                      ['url'] !=
                                  "No URL Found") {
                                await launchUrl(Uri.parse(
                                    policyBillsSorted[dropdownvalue][index]
                                        ['url']));
                              }

                              // catch(e) {

                              // }
                            },
                          ),
                          for (var j in policyBillsSorted[dropdownvalue][index]
                              ['sponsors'])
                            Text('Political Party: ${j[0].toString()}'),
                          for (var j in policyBillsSorted[dropdownvalue][index]
                              ['sponsors'])
                            Text('State of Representative: ${j[1].toString()}'),
                          for (var j in policyBillsSorted[dropdownvalue][index]
                              ['sponsors'])
                            Text('Sponsor Name: ${j[2].toString()}'),
                          // for ( var i in policyBillsSorted[dropdownvalue][index]['summaries'] ) Center(child: Text(Bidi.stripHtmlIfNeeded(i.toString()),)),
                          for (var i in policyBillsSorted[dropdownvalue][index]
                              ['summaries'])
                            Center(
                                child: Text(
                              i
                                  .toString()
                                  .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '\n'),
                              textAlign: TextAlign.center,
                            )),

                          // TODO: FIGURE OUT HOW TO GET NESTED LISTVIEWBUILDER TO WORK, RUN LIST ON SUMMARIES AND SPONSORS
                          // ListView.builder(
                          //     // scrollDirection: Axis.vertical,
                          //     shrinkWrap: true,
                          //     itemCount:
                          //         returnedBills[index]['sponsors'].length,
                          //     itemBuilder:
                          //         ((BuildContext context2, int index2) {
                          //       Text(returnedBills[index2]['sponsors'][index]
                          //           [0]);
                          //       Text(returnedBills[index2]['sponsors'][index]
                          //           [1]);
                          //       Text(returnedBills[index2]['sponsors'][index]
                          //           [2]);
                          //     })),
                        ],
                      );
                    },
                  ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: getBills,
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
