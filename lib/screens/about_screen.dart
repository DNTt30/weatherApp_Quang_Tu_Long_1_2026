import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shared_widgets.dart';

// ============================================================
// AboutScreen — Màn hình About / Profile (Tú's screen)
// Theo mockup Figma: fbjspFedt90T1p34Ty2xPI node-id=4368-321106
// Layout: Dark blue header → Avatar overlap → Tên/MSSV → Settings rows
// ============================================================
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── HEADER ảnh nhóm (Giữ nguyên theo Framework nhóm) ───
        const GroupPhotoHeader(screenLabel: 'Tú_About'),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Navigation Row (Dựa trên World Peas Navbar)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weather App',
                        style: GoogleFonts.lora(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1565C0), // Chuyển sang xanh Blue của app thời tiết
                          letterSpacing: -0.5,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Row(
                            children: [
                              _buildNavLink('Home'),
                              _buildNavLink('Forecast'),
                              _buildNavLink('About Me'),
                              _buildNavLink('Team'),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1565C0),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'App v1.0',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),

                  // 2. Hero Text (Dựa trên "We're farmers...")
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.lora(
                            fontSize: 46,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                          children: [
                            const TextSpan(text: "I am "),
                            TextSpan(
                              text: "Dương Ngọc Tú",
                              style: GoogleFonts.lora(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: ", a "),
                            TextSpan(
                              text: "developer",
                              style: GoogleFonts.lora(fontStyle: FontStyle.italic),
                            ),
                            const TextSpan(text: " of\nthis amazing weather app."),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 3. Button
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'View Github Repo',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),

                  // 4. Images Row (Ảnh cá nhân/coding thay vì rau củ)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          // Ảnh mô tả lập trình/thời tiết
                          child: Image.network(
                            'https://images.unsplash.com/photo-1555099962-4199c345e5dd?q=80&w=600&auto=format&fit=crop',
                            fit: BoxFit.cover,
                            height: 450,
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 100), // Push image down
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              // Ảnh mô tả thời tiết
                              child: Image.network(
                                'https://images.unsplash.com/photo-1534088568595-a066f410cbda?q=80&w=600&auto=format&fit=crop',
                                fit: BoxFit.cover,
                                height: 280,
                              ),
                            ),
                            const SizedBox(height: 12),
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Phenikaa University — ',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(
                                    text:
                                        'The developer who built this screen is currently studying Software Engineering at Phenikaa University, Class SE06.2, Cohort 2022.',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),

                  // 5. WHAT WE BELIEVE Section -> WHO I AM Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'WHO I AM',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello! I am Dương Ngọc Tú. MSSV: 22010052.',
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.6,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'I am passionate about mobile development and creating beautiful, responsive user interfaces. This screen represents the culmination of our UI/UX design studies, translating complex Figma mockups into functional Flutter code.',
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.6),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'My Role in the Team:',
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.6,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'In this Weather App project (Group 1), I took on the responsibility of managing the project repository, structuring the README.md documentation, and developing this comprehensive About screen. By utilizing modern Flutter widgets like Stack, ConstrainedBox, and RichText, I was able to faithfully recreate the structural requirements while infusing it with our project\'s identity.',
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),

        // ─── FOOTER thành viên (Giữ nguyên theo Framework nhóm) ───
        const MemberInfoFooter(),
      ],
    );
  }

  Widget _buildNavLink(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
