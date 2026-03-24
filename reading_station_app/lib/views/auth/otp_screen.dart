import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/auth_controller.dart';
import 'reset_password_screen.dart';
import 'dart:async';

class OtpScreen extends StatefulWidget {
  final String email;
  final OtpType type;
  const OtpScreen({super.key, required this.email, this.type = OtpType.signup});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  final _authController = AuthController();
  
  Timer? _timer;
  int _timeRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _timeRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_timeRemaining > 0) return;
    
    // Call AuthController to resend OTP
    try {
      if (widget.type == OtpType.recovery) {
        await _authController.sendPasswordResetEmail(widget.email);
      } else {
        await Supabase.instance.client.auth.resend(
          type: OtpType.signup,
          email: widget.email,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã xác minh mới đã được gửi!')),
        );
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ 6 chữ số')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authController.verifyOTP(
        email: widget.email, 
        token: otp, 
        type: widget.type,
      );
      
      if (mounted) {
        if (widget.type == OtpType.recovery) {
          // Navigate to Reset Password screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(email: widget.email),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xác thực thành công!')),
          );
          // Navigate to main screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF4A745B);
    const Color bgBeige = Color(0xFFF9F7F2);
    const Color inputBg = Color(0xFFEFECE5);

    return Scaffold(
      backgroundColor: bgBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E35)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Xác minh Email',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2C3E35), fontFamily: 'Serif'),
              ),
              const SizedBox(height: 10),
              Text(
                'Chúng tôi đã gửi mã xác minh 6 chữ số đến email của bạn: ${widget.email}',
                style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => Container(
                    width: 45,
                    decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E35)),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (otp.length == 6) {
                           _verifyOtp();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'Xác nhận',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: _timeRemaining == 0 ? _resendOtp : null,
                  child: Text(
                    _timeRemaining > 0 ? 'Gửi lại mã (${_timeRemaining}s)' : 'Gửi lại mã',
                    style: TextStyle(
                      color: _timeRemaining > 0 ? Colors.grey : primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get otp => _controllers.map((c) => c.text).join();
}
