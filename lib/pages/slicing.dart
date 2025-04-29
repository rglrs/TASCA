import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tasca_mobile1/pages/todo.dart';
import 'package:tasca_mobile1/pages/login_page.dart';

// Custom PageRouteBuilder untuk animasi slide
class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final AxisDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = AxisDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Set offset berbeda berdasarkan arah
            late Offset begin;
            
            switch (direction) {
              case AxisDirection.right:
                begin = const Offset(1.0, 0.0); // Dari kanan (continue)
                break;
              case AxisDirection.left:
                begin = const Offset(-1.0, 0.0); // Dari kiri (back)
                break;
              case AxisDirection.up:
                begin = const Offset(0.0, 1.0); // Dari bawah
                break;
              case AxisDirection.down:
                begin = const Offset(0.0, -1.0); // Dari atas
                break;
            }
            
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            // Terapkan animasi slide sesuai arah
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

// Fungsi helper untuk navigasi dengan animasi slide
void navigateWithSlide(BuildContext context, Widget page, {AxisDirection direction = AxisDirection.right}) {
  Navigator.of(context).push(
    SlidePageRoute(page: page, direction: direction),
  );
}

// Fungsi helper untuk navigasi dengan replacement dan animasi slide
void navigateReplaceWithSlide(BuildContext context, Widget page, {AxisDirection direction = AxisDirection.right}) {
  Navigator.of(context).pushReplacement(
    SlidePageRoute(page: page, direction: direction),
  );
}

class SlicingScreen extends StatefulWidget {
  final int initialPage;
  
  const SlicingScreen({
    super.key, 
    this.initialPage = 0,
  });

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

  // Fungsi untuk pergi ke halaman berikutnya dengan animasi slide
  void _goToNextPage(BuildContext context) {
    if (_currentPage == 0) {
      navigateReplaceWithSlide(context, const SlicingScreen(initialPage: 1), direction: AxisDirection.right);
    } else if (_currentPage == 1) {
      navigateReplaceWithSlide(context, const SlicingScreen(initialPage: 2), direction: AxisDirection.right);
    } else if (_currentPage == 2) {
      navigateReplaceWithSlide(context, const SlicingScreen(initialPage: 3), direction: AxisDirection.right);
    }
  }
  
  // Fungsi untuk kembali ke halaman sebelumnya dengan animasi slide
  void _goBack(BuildContext context) {
    if (_currentPage == 1) {
      navigateReplaceWithSlide(context, const SlicingScreen(initialPage: 0), direction: AxisDirection.left);
    } else if (_currentPage == 2) {
      navigateReplaceWithSlide(context, const SlicingScreen(initialPage: 1), direction: AxisDirection.left);
    } else if (_currentPage == 3) {
      navigateReplaceWithSlide(context, const SlicingScreen(initialPage: 2), direction: AxisDirection.left);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menampilkan halaman berdasarkan _currentPage
    if (_currentPage == 0) {
      return _buildFeaturesPage(context);
    } else if (_currentPage == 1) {
      return _buildNextPage(context);
    } else if (_currentPage == 2) {
      return _buildThirdPage(context);
    } else {
      return _buildFourthPage(context);
    }
  }

  // Halaman fitur (halaman pertama)
  Widget _buildFeaturesPage(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8E2FF), // Ungu muda di bagian atas
              Color(0xFFF5F3FF), // Ungu sangat muda di bagian bawah
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                      MediaQuery.of(context).padding.top - 
                      MediaQuery.of(context).padding.bottom - 48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 60),
                    
                    // Title Text
                    Text(
                      'Done! Combine all the features',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    Text(
                      'to make your productivity',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    Text(
                      'experience easier!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    // Semua Feature Chips dalam satu gambar
                    const SizedBox(height: 100),
                    
                    // Image chip.png yang berisi semua fitur
                    Center(
                      child: Image.asset(
                        'images/chip.png',
                        width: 280,
                      ),
                    ),
                    
                    // MENAMBAH JARAK UNTUK MENURUNKAN BUTTON
                    const SizedBox(height: 300),
                    
                    // Continue Button dengan shadow ungu yang lebih terlihat
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Shadow bulat di belakang tombol
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
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        // Button Continue
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 50),
                          child: ElevatedButton(
                            onPressed: () => _goToNextPage(context),  // Gunakan fungsi untuk pergi ke halaman berikutnya
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 5, // Menambah elevasi untuk efek shadow tambahan
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Halaman kedua yang akan ditampilkan setelah tombol Continue diklik
  Widget _buildNextPage(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8E2FF), // Ungu muda di bagian atas (sama dengan halaman sebelumnya)
              Color(0xFFF5F3FF), // Ungu sangat muda di bagian bawah (sama dengan halaman sebelumnya)
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Tombol Back
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                    onPressed: () => _goBack(context),
                  ),
                  
                  const SizedBox(height: 20), // Diubah dari 30 ke 20 untuk menaikkan judul
                  
                  // Title Text
                  Center(
                    child: Text(
                      'Enable your notifications to get',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  
                  Center(
                    child: Text(
                      'the most out of it!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Menggunakan image halaman2.png
                  Center(
                    child: Image.asset(
                      'images/halaman2.png',
                      width: 340, // Diperbesar dari 320 ke 340
                    ),
                  ),
                  
                  // MENAMBAH JARAK UNTUK MENURUNKAN BUTTON
                  const SizedBox(height: 120),
                  
                  // Continue Button dengan shadow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shadow bulat di belakang tombol
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
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      // Button Continue
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 40),
                        child: ElevatedButton(
                          onPressed: () => _goToNextPage(context), // Pergi ke halaman ketiga
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
                  const SizedBox(height: 20), // Extra space at bottom to avoid overflow
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Halaman ketiga yang akan ditampilkan setelah tombol Continue pada halaman kedua diklik
  Widget _buildThirdPage(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8E2FF), // Ungu muda di bagian atas (sama dengan halaman sebelumnya)
              Color(0xFFF5F3FF), // Ungu sangat muda di bagian bawah (sama dengan halaman sebelumnya)
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Tombol Back
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                    onPressed: () => _goBack(context),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title Text
                  Center(
                    child: Text(
                      'Pomodoro & Relaxation Music',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  
                  Center(
                    child: Text(
                      'to learn more effectively & create',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  
                  Center(
                    child: Text(
                      'cozy atmosphere',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Menggunakan image halaman3.png dengan ukuran lebih besar
                  Center(
                    child: Image.asset(
                      'images/halaman3.png',
                      width: 280, // Ukuran gambar diperbesar
                    ),
                  ),
                  
                  // MENAMBAH JARAK UNTUK MENURUNKAN BUTTON
                  const SizedBox(height: 150),
                  
                  // Continue Button dengan shadow
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shadow bulat di belakang tombol
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
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      // Button Continue
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 40),
                        child: ElevatedButton(
                          onPressed: () => _goToNextPage(context), // Pergi ke halaman keempat
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
                  const SizedBox(height: 20), // Extra space at bottom to avoid overflow
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Halaman keempat (Welcome page)
  Widget _buildFourthPage(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8E2FF), // Ungu muda di bagian atas (sama dengan halaman sebelumnya)
              Color(0xFFF5F3FF), // Ungu sangat muda di bagian bawah (sama dengan halaman sebelumnya)
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Tombol Back
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                      onPressed: () => _goBack(context),
                    ),
                  ],
                ),
                
                // Spacer untuk mendorong content ke tengah
                const Spacer(flex: 1),
                
                // Ilustrasi orang membaca
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Image.asset(
                    'images/get.png',
                    width: 280,
                  ),
                ),
                
                // MENAMBAH JARAK UNTUK MENURUNKAN CARD
                const Spacer(flex: 2),
                
                // Card Welcome
                Container(
                  margin: const EdgeInsets.only(bottom: 40),
                  width: double.infinity,
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
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Judul Welcome
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
                          'Making management',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        
                        Text(
                          'experience easier.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Button Get Started
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigasi ke halaman utama aplikasi (to_do.dart)
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => TodoPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007BFF), // Warna biru #007BFF
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Radius lebih besar agar lebih melengkung
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
                            // Navigasi ke halaman sign in (login_page.dart)
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF3F3CAC), // Warna ungu #3F3CAC
                            ),
                          ),
                        ),
                      ],
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