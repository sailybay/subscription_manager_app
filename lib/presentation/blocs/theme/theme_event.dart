abstract class ThemeEvent {
  const ThemeEvent();
}

class ThemeChanged extends ThemeEvent {
  final bool isDark;
  const ThemeChanged(this.isDark);
}
