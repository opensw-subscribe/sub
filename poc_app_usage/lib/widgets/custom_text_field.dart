import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller; // 텍스트 컨트롤러 추가
  final bool showError; // 에러 시 테두리와 흔들림
  final ValueChanged<String>? onChanged; // 입력 변경 알림

  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.showError = false,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true; // 비밀번호 숨김/표시 상태
  bool _wasError = false; // 최초 showError true 감지용
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  late final AnimationController _controller;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword; // 초기값 설정
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -2.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // showError가 true일 때마다 애니메이션 재생
    if (widget.showError) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 최초 마운트 후 showError가 true면 바로 애니메이션
    if (widget.showError && !_wasError) {
      _controller.forward(from: 0.0);
      _wasError = true;
    } else if (!widget.showError) {
      _wasError = false;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(12.0); // 앱 테마와 통일
    final defaultBorderColor = Colors.grey.shade300;
    final errorColor = const Color(0xFFEC221F); // 요청한 빨간색
    final Color baseBg = theme.inputDecorationTheme.fillColor ?? const Color(0xFFF6F6F6);
    final Color focusBg = const Color(0xFFE9E9E9); // 더 어두운 배경

    return AnimatedBuilder(
      key: ValueKey('shake_${widget.showError}_${DateTime.now().millisecondsSinceEpoch}_${widget.key ?? ''}'),
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isFocused ? focusBg : baseBg,
          borderRadius: borderRadius,
        ),
        child: TextField(
          focusNode: _focusNode,
          controller: widget.controller,
          obscureText: widget.isPassword && _obscureText, // 비밀번호 숨김 여부
          onChanged: widget.onChanged,
          style: const TextStyle(
            color: Colors.black, // 입력 텍스트 색상을 검은색으로
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.transparent, // AnimatedContainer에서 배경 처리
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: widget.showError ? errorColor : (theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? defaultBorderColor),
                width: widget.showError ? 1.3 : 1.0, // 에러 시 1.3px
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: widget.showError ? errorColor : (theme.inputDecorationTheme.focusedBorder?.borderSide.color ?? theme.primaryColor),
                width: widget.showError ? 1.3 : 1.5, // 에러 시 1.3px
              ),
            ),
            hintStyle: theme.inputDecorationTheme.hintStyle,
            // [디자인 반영] 비밀번호 필드에만 '보기' 텍스트 버튼 추가
            suffixIcon: widget.isPassword
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText; // 상태 토글
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '보기',
                        style: TextStyle(
                          color: const Color(0xFF1A237E), // 남색
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : null, // 일반 텍스트 필드는 버튼 없음
          ),
        ),
      ),
    );
  }
}