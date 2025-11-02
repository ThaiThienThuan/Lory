import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Cần add vào pubspec.yaml

class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Trợ giúp & Hỗ trợ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF06b6d4).withOpacity(0.2),
                    Color(0xFFec4899).withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 64,
                    color: Color(0xFF06b6d4),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chúng tôi luôn sẵn sàng hỗ trợ bạn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Chọn phương thức liên hệ phù hợp với bạn',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Contact Methods
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Liên hệ với chúng tôi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildContactCard(
                    context: context,
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: 'support@lory.com',
                    color: Color(0xFF06b6d4),
                    onTap: () => _launchEmail(context),
                  ),
                  _buildContactCard(
                    context: context,
                    icon: Icons.phone,
                    title: 'Hotline',
                    subtitle: '1900-xxxx (8h-22h)',
                    color: Color(0xFF10b981),
                    onTap: () => _launchPhone(context),
                  ),
                  _buildContactCard(
                    context: context,
                    icon: Icons.chat_bubble,
                    title: 'Live Chat',
                    subtitle: 'Trò chuyện trực tiếp với chúng tôi',
                    color: Color(0xFFec4899),
                    onTap: () => _showLiveChatDialog(context),
                  ),
                  _buildContactCard(
                    context: context,
                    icon: Icons.facebook,
                    title: 'Facebook',
                    subtitle: 'Fanpage Lory',
                    color: Color(0xFF1877F2),
                    onTap: () => _launchFacebook(context),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // FAQ Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Câu hỏi thường gặp (FAQ)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildFAQItem(
                    context: context,
                    question: 'Làm sao để đọc truyện offline?',
                    answer:
                        'Bạn có thể tải truyện về máy bằng cách nhấn vào biểu tượng download ở trang chi tiết truyện. Sau khi tải xong, truyện sẽ có trong mục "Tải xuống" của bạn.',
                  ),
                  _buildFAQItem(
                    context: context,
                    question: 'Làm sao để theo dõi truyện yêu thích?',
                    answer:
                        'Nhấn vào biểu tượng bookmark/tim ở trang chi tiết truyện để theo dõi. Truyện sẽ xuất hiện trong mục "Theo dõi" của bạn.',
                  ),
                  _buildFAQItem(
                    context: context,
                    question: 'Làm sao để đăng truyện?',
                    answer:
                        'Chỉ tài khoản được cấp quyền "Nhóm dịch" mới có thể đăng truyện. Vào phần Cài đặt > Yêu cầu trở thành nhóm dịch để gửi đơn đăng ký.',
                  ),
                  _buildFAQItem(
                    context: context,
                    question: 'Làm sao để báo cáo nội dung không phù hợp?',
                    answer:
                        'Nhấn vào biểu tượng 3 chấm (...) ở truyện hoặc bài đăng, sau đó chọn "Báo cáo". Chúng tôi sẽ xem xét và xử lý trong 24-48 giờ.',
                  ),
                  _buildFAQItem(
                    context: context,
                    question: 'Tài khoản của tôi bị khóa, phải làm sao?',
                    answer:
                        'Liên hệ với chúng tôi qua email support@lory.com kèm theo thông tin tài khoản. Đội ngũ hỗ trợ sẽ xem xét và phản hồi trong 1-2 ngày làm việc.',
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Quick Actions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hành động nhanh',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          context: context,
                          icon: Icons.bug_report,
                          title: 'Báo lỗi',
                          onTap: () => _showReportBugDialog(context),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          context: context,
                          icon: Icons.lightbulb,
                          title: 'Góp ý',
                          onTap: () => _showFeedbackDialog(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          context: context,
                          icon: Icons.description,
                          title: 'Điều khoản',
                          onTap: () => _showTermsDialog(context),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          context: context,
                          icon: Icons.policy,
                          title: 'Chính sách',
                          onTap: () => _showPrivacyDialog(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        iconColor: Color(0xFF06b6d4),
        collapsedIconColor: Theme.of(context).textTheme.bodyMedium?.color,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Color(0xFF06b6d4), size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ===== HELPER FUNCTIONS =====

  void _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@lory.com',
      query: 'subject=Hỗ trợ từ ứng dụng Lory',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở ứng dụng email')),
      );
    }
  }

  void _launchPhone(BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '1900xxxx');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể gọi điện thoại')),
      );
    }
  }

  void _launchFacebook(BuildContext context) async {
    final Uri facebookUri = Uri.parse('https://facebook.com/lory.app');

    if (await canLaunchUrl(facebookUri)) {
      await launchUrl(facebookUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở Facebook')),
      );
    }
  }

  void _showLiveChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Row(
          children: [
            Icon(Icons.chat_bubble, color: Color(0xFFec4899)),
            SizedBox(width: 12),
            Text('Live Chat',
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color)),
          ],
        ),
        content: Text(
          'Tính năng Live Chat đang được phát triển. Hiện tại bạn có thể liên hệ qua Email hoặc Hotline.',
          style:
              TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đã hiểu', style: TextStyle(color: Color(0xFF06b6d4))),
          ),
        ],
      ),
    );
  }

  void _showReportBugDialog(BuildContext context) {
    final TextEditingController bugController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text('Báo lỗi',
            style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color)),
        content: TextField(
          controller: bugController,
          maxLines: 4,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: 'Mô tả lỗi bạn gặp phải...',
            hintStyle: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Cảm ơn bạn đã báo lỗi! Chúng tôi sẽ xem xét sớm nhất.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF06b6d4),
              foregroundColor: Colors.white,
            ),
            child: Text('Gửi'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text('Góp ý',
            style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color)),
        content: TextField(
          controller: feedbackController,
          maxLines: 4,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: 'Chia sẻ ý kiến của bạn về ứng dụng...',
            hintStyle: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cảm ơn góp ý của bạn!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF06b6d4),
              foregroundColor: Colors.white,
            ),
            child: Text('Gửi'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text('Điều khoản sử dụng',
            style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color)),
        content: SingleChildScrollView(
          child: Text(
            '1. Chấp nhận điều khoản\nBằng cách sử dụng ứng dụng Lory, bạn đồng ý với các điều khoản này.\n\n2. Quyền và nghĩa vụ người dùng\n- Bạn phải từ đủ 13 tuổi trở lên\n- Không đăng tải nội dung vi phạm pháp luật\n- Tôn trọng bản quyền và tác giả\n\n3. Nội dung\nLory không chịu trách nhiệm về nội dung do người dùng đăng tải.',
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: TextStyle(color: Color(0xFF06b6d4))),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Text('Chính sách bảo mật',
            style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color)),
        content: SingleChildScrollView(
          child: Text(
            '1. Thu thập thông tin\nChúng tôi thu thập thông tin cơ bản: email, tên, avatar.\n\n2. Sử dụng thông tin\n- Cải thiện trải nghiệm người dùng\n- Gửi thông báo quan trọng\n- Phân tích và thống kê\n\n3. Bảo mật\nThông tin của bạn được mã hóa và bảo vệ an toàn.',
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: TextStyle(color: Color(0xFF06b6d4))),
          ),
        ],
      ),
    );
  }
}
