import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'register_page.dart';

// Custom PageRouteBuilder for slide animations
class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final AxisDirection direction;

  SlidePageRoute({required this.page, this.direction = AxisDirection.right})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Set different offsets based on direction
          late Offset begin;
          late Offset beginSecondary;

          switch (direction) {
            case AxisDirection.right:
              begin = const Offset(1.0, 0.0); // From right (continue)
              beginSecondary = const Offset(-0.3, 0.0); // Current page slides slightly left
              break;
            case AxisDirection.left:
              begin = const Offset(-1.0, 0.0); // From left (back)
              beginSecondary = const Offset(0.3, 0.0); // Current page slides slightly right
              break;
            case AxisDirection.up:
              begin = const Offset(0.0, 1.0); // From bottom
              beginSecondary = const Offset(0.0, -0.3);
              break;
            case AxisDirection.down:
              begin = const Offset(0.0, -1.0); // From top
              beginSecondary = const Offset(0.0, 0.3);
              break;
          }

          const end = Offset.zero;
          // Using cubic curves for more natural motion
          const curve = Curves.easeOutCubic;
          const secondaryCurve = Curves.easeInCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var secondaryTween = Tween(begin: end, end: beginSecondary).chain(CurveTween(curve: secondaryCurve));

          // Add subtle scale effect for depth
          var scaleTween = Tween(begin: 0.95, end: 1.0).chain(CurveTween(curve: curve));
          var secondaryScaleTween = Tween(begin: 1.0, end: 0.95).chain(CurveTween(curve: secondaryCurve));

          // Subtle fade for smoothness
          var fadeTween = Tween(begin: 0.5, end: 1.0).chain(CurveTween(curve: curve));

          // For the current page (the one being replaced)
          Widget currentPage = SlideTransition(
            position: secondaryAnimation.drive(secondaryTween),
            child: ScaleTransition(
              scale: secondaryAnimation.drive(secondaryScaleTween),
              child: child,
            ),
          );

          // For the new page coming in
          Widget newPage = SlideTransition(
            position: animation.drive(tween),
            child: ScaleTransition(
              scale: animation.drive(scaleTween),
              child: child,
            ),
          );

          if (secondaryAnimation.status == AnimationStatus.reverse) {
            return currentPage;
          } else {
            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: newPage,
            );
          }
        },
      );
}

// Helper function for navigation with slide animation
void navigateWithSlide(
  BuildContext context,
  Widget page, {
  AxisDirection direction = AxisDirection.right,
}) {
  Navigator.of(context).push(SlidePageRoute(page: page, direction: direction));
}

// Helper function for navigation with replacement and slide animation
void navigateReplaceWithSlide(
  BuildContext context,
  Widget page, {
  AxisDirection direction = AxisDirection.right,
}) {
  Navigator.of(context).pushReplacement(SlidePageRoute(page: page, direction: direction));
}

class SlicingScreen extends StatefulWidget {
  final int initialPage;

  const SlicingScreen({super.key, this.initialPage = 0});

  @override
  State<SlicingScreen> createState() => _SlicingScreenState();
}

class _SlicingScreenState extends State<SlicingScreen> {
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
  }

  // Function to go to the next page with slide animation
  void _goToNextPage(BuildContext context) {
    if (_currentPage < 3) {
      navigateReplaceWithSlide(
        context,
        SlicingScreen(initialPage: _currentPage + 1),
        direction: AxisDirection.right,
      );
    }
  }

  // Function to go back to the previous page with slide animation
  void _goBack(BuildContext context) {
    if (_currentPage > 0) {
      navigateReplaceWithSlide(
        context,
        SlicingScreen(initialPage: _currentPage - 1),
        direction: AxisDirection.left,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display page based on _currentPage
    switch (_currentPage) {
      case 0:
        return _buildFeaturesPage(context);
      case 1:
        return _buildNextPage(context);
      case 2:
        return _buildThirdPage(context);
      case 3:
        return _buildFourthPage(context);
      default:
        return _buildFeaturesPage(context);
    }
  }

  // Features page (first page)
  Widget _buildFeaturesPage(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8E2FF), // Light purple at top
              Color(0xFFF5F3FF), // Very light purple at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.07),
                
                // Title Text
                Text(
                  'Done! Combine all the features\nto make your productivity\nexperience easier!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.06),
                
                // Image with all feature chips
                Expanded(
                  child: Center(
                    child: Image.asset('images/halaman1.png', width: 280),
                  ),
                ),
                
                // Continue Button with purple shadow
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.05),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shadow circle behind button
                      Container(
                        width: 280,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 80,
                              spreadRadius: 30,
                            ),
                          ],
                        ),
                      ),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _goToNextPage(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          child: Text(
                            'Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Second page
  Widget _buildNextPage(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8E2FF), // Light purple at top
              Color(0xFFF5F3FF), // Very light purple at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                
                // Back button
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                  ),
                  onPressed: () => _goBack(context),
                ),
                
                SizedBox(height: screenHeight * 0.02),
                
                // Title Text
                Center(
                  child: Text(
                    'Enable your notifications to get\nthe most out of it!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.03),
                
                // Main image
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'images/halaman2.png',
                      width: 340,
                    ),
                  ),
                ),
                
                // Continue Button with shadow
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.04),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shadow circle behind button
                      Container(
                        width: 280,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 80,
                              spreadRadius: 30,
                            ),
                          ],
                        ),
                      ),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _goToNextPage(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          child: Text(
                            'Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Third page
  Widget _buildThirdPage(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8E2FF), // Light purple at top
              Color(0xFFF5F3FF), // Very light purple at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                
                // Back button
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black87,
                  ),
                  onPressed: () => _goBack(context),
                ),
                
                SizedBox(height: screenHeight * 0.02),
                
                // Title Text
                Center(
                  child: Text(
                    'Pomodoro & Relaxation Music\nto learn more effectively & create\ncozy atmosphere',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.03),
                
                // Main image
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'images/halaman3.png',
                      width: 280,
                    ),
                  ),
                ),
                
                // Continue Button with shadow
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.04),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shadow circle behind button
                      Container(
                        width: 280,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 80,
                              spreadRadius: 30,
                            ),
                          ],
                        ),
                      ),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _goToNextPage(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          child: Text(
                            'Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fourth page (Welcome page) - FIXED OVERFLOW
  Widget _buildFourthPage(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8E2FF), // Light purple at top
              Color(0xFFF5F3FF), // Very light purple at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                
                // Back button row
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black87,
                      ),
                      onPressed: () => _goBack(context),
                    ),
                  ],
                ),
                
                // Empty space before image
                SizedBox(height: screenHeight * 0.04),
                
                // Image centered vertically more
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Image.asset(
                      'images/get.png', 
                      width: 280,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                // Welcome Card - positioned more towards the bottom
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: screenHeight * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  // Using ConstrainedBox to control height without overflow
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: screenHeight * 0.35, // Limit maximum height
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Welcome Title
                          Text(
                            'Welcome',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Subtitle
                          Text(
                            'Making management\nexperience easier.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Get Started Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to the main app screen (register_page.dart)
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => RegisterPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007BFF), // Blue #007BFF
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              child: Text(
                                'Get Started',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Sign In link
                          InkWell(
                            onTap: () {
                              // Navigate to sign in page (login_page.dart)
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF3F3CAC), // Purple #3F3CAC
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}