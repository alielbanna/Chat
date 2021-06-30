import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_starter/widgets/recent_chats.dart';
import 'package:flutter_chat_ui_starter/widgets/recent_news.dart';
import 'package:flutter_chat_ui_starter/widgets/recent_sections.dart';

class CategorySelector extends StatefulWidget {
  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  int selectedIndex = 0;
  final List<String> categories = ['Lectures', 'Sections', 'News'];

  Widget whichCategory() {
    if (selectedIndex == 0) {
      return RecentChats();
    } else if (selectedIndex == 1) {
      return RecentSections();
    } else
      return RecentNews();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0),
            ),
          ),
          height: 70.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 8.5,
                    top: 17.0,
                    bottom: 13.0,
                    left: 8.5,
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.29,
                    decoration: BoxDecoration(
                      color: index == selectedIndex ? Colors.white : null,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          categories[index],
                          style: TextStyle(
                              color: index == selectedIndex
                                  ? Color(0xFF125589)
                                  : Colors.white,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        whichCategory(),
      ],
    );
  }
}
