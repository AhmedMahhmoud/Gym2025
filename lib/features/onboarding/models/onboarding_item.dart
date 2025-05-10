class OnboardingItem {
  final String title;
  final String subtitle;
  final String imagePath;
  final bool hasButton;
  final String? buttonText;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.hasButton = false,
    this.buttonText,
  });
}
