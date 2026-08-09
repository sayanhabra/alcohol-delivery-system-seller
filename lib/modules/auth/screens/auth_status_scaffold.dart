// core/shared/widgets/auth_status_scaffold.dart

import 'package:adm_seller/core/shared/styles/app_style.dart';
import 'package:flutter/material.dart';

class AuthStatusScaffold extends StatelessWidget {
  final Widget child;
  final bool showBanner;

  const AuthStatusScaffold({
    super.key,
    required this.child,
    this.showBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (showBanner) _buildBanner(context),
              Transform.translate(
                offset: const Offset(0, -25),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height * 0.60,
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppStyle.spaceXLarge,
                    AppStyle.spaceXLarge,
                    AppStyle.spaceXLarge,
                    AppStyle.spaceXLarge,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppStyle.radiusXLarge),
                    ),
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 0.35,
          child: Image.asset(
            'assets/png/logobanner.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        Container(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 0.35,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.6),
                Colors.white,
              ],
              stops: const [0.0, 0.5, 0.8, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
