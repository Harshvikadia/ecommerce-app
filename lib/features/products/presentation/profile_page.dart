import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app_task/core/utils/app_string.dart';
import 'package:ecommerce_app_task/features/products/provider/profile_provider.dart';
import 'package:ecommerce_app_task/features/products/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app_task/core/utils/size_config.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sc = SizeConfig.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sc.hPadding),
          child: Column(
            children: [
              // Upar: photo + username (bachi hui jagah le leta hai)
              Expanded(child: getUserInfo(sc, theme)),

              // Niche: settings + logout
              getSettings(sc, theme),
              getLogoutButton(context, sc),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Photo + Username ----------------

  Widget getUserInfo(SizeConfig sc, ThemeData theme) {
    return Consumer<ProfileProvider>(
      builder: (context, profile, _) {
        final name = profile.username ??AppStrings.guest;
        final image = profile.image;
        final hasImage = image != null && image.isNotEmpty;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: sc.shortest * 0.16,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage:
                hasImage ? CachedNetworkImageProvider(image) : null,
                child: hasImage
                    ? null
                    : Text(
                  name[0].toUpperCase(),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: sc.gap),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- Settings (dark theme toggle) ----------------

  Widget getSettings(SizeConfig sc, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: sc.gap * 0.5),
          child: Text(
            AppStrings.settings,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => SwitchListTile(
              secondary: Icon(
                themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
              ),
              title: const Text(AppStrings.darkTheme),
              value: themeProvider.isDark,
              onChanged: themeProvider.setDark,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- Logout (settings ke niche) ----------------

  Widget getLogoutButton(BuildContext context, SizeConfig sc) {
    return Padding(
      padding: EdgeInsets.only(top: sc.gap, bottom: sc.gap),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () async {
            await context.read<ProfileProvider>().logout();

            // TODO: logout ke baad apni Login screen par bhejo:
            // if (!context.mounted) return;
            // Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            //   MaterialPageRoute(builder: (_) => const LoginPage()),
            //   (route) => false,
            // );
          },
          icon: const Icon(Icons.logout),
          label: const Text(AppStrings.logout),
        ),
      ),
    );
  }
}