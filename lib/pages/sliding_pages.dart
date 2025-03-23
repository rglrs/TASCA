import 'package:flutter/material.dart';

class SlidingPages extends StatelessWidget {
  final PageController pageController = PageController();

  SlidingPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: pageController,
          physics: AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            _buildPageOne(),
            _buildPageTwo(),
            _buildPageThree(),
          ],
        ),
        _buildBackButton(context),
        _buildContinueButton(),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: 30),
        onPressed: () {
          if (pageController.page!.toInt() > 0) {
            pageController.previousPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  // Halaman 1 
  Widget _buildPageOne() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, 
        children: [
          SizedBox(height: 100),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Done! Combine all the features to make your productivity experience easier!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4D4D4D)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30),
          Image.asset(
            'images/halaman1.png',
            width: 500,
            height: 500,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  // Halaman 2
  Widget _buildPageTwo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, 
        children: [
          SizedBox(height: 100), 
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20), 
            child: Text(
              'Enable your notifications to get the most out of it!', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4D4D4D)), 
              textAlign: TextAlign.center, 
            ),
          ),
          SizedBox(height: 30),
          Image.asset(
            'images/halaman2.png', 
            width: 500, 
            height: 500, 
            fit: BoxFit.contain, 
          ),
        ],
      ),
    );
  }

  // Halaman 3
  Widget _buildPageThree() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, 
        children: [
          SizedBox(height: 100), 
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20), 
            child: Text(
              'Pomodoro & Relaxation Music to learn more effectively & create cozy atmosphere', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4D4D4D)), 
              textAlign: TextAlign.center, 
            ),
          ),
          SizedBox(height: 20), 
          Image.asset(
            'images/halaman3.png', 
            width: 500, 
            height: 500, 
            fit: BoxFit.contain, 
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ElevatedButton(
        onPressed: () {
          if (pageController.page!.toInt() < 1) { 
            pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            pageController.jumpToPage(0); 
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 15),
          textStyle: TextStyle(fontSize: 20),
        ),
        child: Center(child: Text('Continue')),
      ),
    );
  }
}